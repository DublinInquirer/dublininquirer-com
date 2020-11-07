require 'csv'

class Subscription < ApplicationRecord
  belongs_to :plan
  belongs_to :user, optional: true

  has_many :invoices
  has_many :gift_subscriptions

  attribute :given_name, :string
  attribute :surname, :string
  attribute :email_address, :string
  attribute :password, :string

  attribute :price, :integer
  attribute :interval, :string

  # request address only
  attribute :address_line_1, :string
  attribute :address_line_2, :string
  attribute :city, :string
  attribute :county, :string
  attribute :post_code, :string
  attribute :country, :string
  attribute :country_code, :string
  attribute :hub, :string

  # fixed only:
  attribute :duration_months, :integer

  validates :subscription_type, presence: true
  validates :stripe_id, uniqueness: true, allow_blank: true
  # validates :stripe_id, presence: true, if: -> { is_stripe? } // rejigger sub creation sequence to do this

  after_validation :sync_stripe_subscription, :set_status
  before_validation :set_ended_at_for_fixed, if: -> (s) { s.is_fixed? && s.duration_months.present? }

  before_destroy :orphan_gift_subscriptions
  before_destroy :orphan_invoices

  scope :paid, -> { where(status: %w(trialing active)) }
  scope :active, -> { where(status: %w(trialing incomplete active past_due unpaid)) }
  scope :delinquent, -> { where(status: %w(past_due unpaid)) }
  scope :is_stripe, -> { where(subscription_type: 'stripe') }
  scope :is_fixed, -> { where(subscription_type: 'fixed') }
  scope :includes_print, -> { joins(:plan).merge( Plan.includes_print ).distinct }
  scope :needs_shipping, -> { active.includes_print }
  scope :churning, -> { is_stripe.delinquent }
  scope :churned, -> { where(status: %w(unpaid canceled)) }

  def self.searchable_columns
    [:stripe_id]
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << %w(name email status address_line_1 address_line_2 city county post_code country hub)
      all.includes(:plan, :user).find_each do |s|
        u = s.user
        csv << {
          name: u.try(:full_name),
          email: u.try(:email_address),
          status: s.status,
          address_line_1: u.try(:address_line_1),
          address_line_2: u.try(:address_line_2),
          city: u.try(:city),
          county: u.try(:county),
          post_code: u.try(:post_code),
          country: u.try(:country_name),
          hub: u.try(:hub)
        }.values
      end
    end
  end

  def self.mark_as_lapsed!
    is_fixed.active.each do |s|
      s.mark_as_lapsed_if_lapsed!
    end
  end

  def self.cancel_missing_stripe_subscriptions!
    is_stripe.each(&:cancel_if_subscription_is_missing!)
  end

  def remove_sensitive_information_from_stripe!
    return unless self.stripe_id.present?
    subsc = self.stripe_subscription
    return unless subsc.present?

    subsc.metadata = {}

    begin
      subsc.save
    rescue Stripe::InvalidRequestError
      return
    end
  end

  def normalise_plan!
    return if !self.is_stripe? # return if non-stripe sub
    return if self.product.is_active? # return if normal already
    return if !(self.status.try(:downcase) == 'active') # return if not active

    if self.digital_only?
      change_product_to! :digital, true
    else
      change_product_to! :print, true
    end
  end

  def full_name
    if self.given_name.present? or self.surname.present?
      "#{ given_name } #{ surname }".strip
    elsif user.present?
      self.user.full_name
    else
      nil
    end
  end

  def delete_completely!
    remove_sensitive_information_from_stripe! if is_stripe?
    cancel_subscription_now! if is_stripe?

    reload

    self.destroy
  end

  def human_status
    return 'cancelling' if is_cancelling?
    self.status
  end

  def mrr
    return nil unless is_stripe?
    return nil unless self.plan.present?
    return 0 unless self.plan.amount

    divisor = (self.plan.interval == 'month') ? 1 : 12

    (self.plan.amount / divisor.to_f)
  end

  def product_name
    self.product.try(:name)
  end

  def product
    self.plan.try(:product)
  end

  def requires_address?
    self.product.try(:requires_address?)
  end

  def digital_only?
    !self.requires_address?
  end

  def has_address?
    self.address_lines.many?
  end

  def print?
    self.requires_address?
  end

  def is_delinquent?
    return false unless self.status
    %w(past_due unpaid).include? self.status.downcase
  end

  def is_cancelling?
    ((self.cancel_at_period_end) && (self.status != 'canceled'))
  end

  def is_cancelled?
    (self.status == 'canceled') or ((self.status == 'lapsed') && self.is_fixed?)
  end

  def is_base_price?
    (self.plan.amount == self.product.base_price)
  end

  def stripe_subscription
    return nil unless self.stripe_id.present?
    @stripe_subscription ||= Stripe::Subscription.retrieve({
      id: self.stripe_id, 
      expand: ['latest_invoice.payment_intent']
    })
  end

  def is_stripe?
    (self.subscription_type == 'stripe')
  end

  def is_fixed?
    (self.subscription_type == 'fixed')
  end

  def lapsed?
    (self.status == 'lapsed')
  end

  def patron?
    (self.plan.is_friend? or self.plan.is_patron?)
  end
  
  def latest_invoice
    @latest_invoice ||= self.stripe_subscription.latest_invoice
  end

  # users can only change their sub if they're paying the base price on the active products
  def changeable?
    (self.is_stripe? && self.product.is_active? && self.is_base_price?)
  end

  def change_product_to!(product_sym, maintain_price=false) # affects stripe
    new_product = Product.find_by_slug(product_sym.to_sym)
    old_plan = self.plan

    old_amount = if self.stripe_subscription.tax_percent && self.stripe_subscription.tax_percent > 0
      (old_plan.amount + ((self.stripe_subscription.tax_percent * 0.01) * old_plan.amount)).round
    else
      old_plan.amount
    end

    new_plan = Plan.find_or_create_by(
      product_id: new_product.id,
      amount: maintain_price ? old_amount : new_product.base_price,
      interval: (self.plan.interval || 'month'),
      interval_count: self.plan.interval_count || 1
    )

    str_sub = self.stripe_subscription
    str_sub.prorate = false
    str_sub.tax_percent = 0
    str_sub.items = [{
      id: str_sub.items.data[0].id,
      plan: new_plan.stripe_id,
    }]

    str_sub.save && update_from_stripe_object!(str_sub)
  end

  def change_price_and_interval_to!(amount, interval) # affects stripe
    new_plan = Plan.find_or_create_by!(
      amount: amount.to_i,
      product_id: self.product.id,
      interval: interval,
      interval_count: self.plan.interval_count || 1
    )

    str_sub = self.stripe_subscription

    str_sub.prorate = false
    str_sub.tax_percent = 0
    str_sub.items = [{
      id: str_sub.items.data[0].id,
      plan: new_plan.stripe_id,
    }]

    str_sub.save && update_from_stripe_object!(str_sub)
  end

  def change_price_to!(amount) # affects stripe
    new_plan = Plan.find_or_create_by!(
      amount: amount.to_i,
      product_id: self.product.id,
      interval: (self.plan.interval || 'month'),
      interval_count: self.plan.interval_count || 1
    )

    str_sub = self.stripe_subscription

    str_sub.prorate = false
    str_sub.tax_percent = 0
    str_sub.items = [{
      id: str_sub.items.data[0].id,
      plan: new_plan.stripe_id,
    }]

    str_sub.save && update_from_stripe_object!(str_sub)
  end

  def change_billing_date_to!(date) # affects stripe
    trial_ends_at = Date.parse(date).beginning_of_day
    str_sub = self.stripe_subscription
    str_sub.prorate = false
    str_sub.trial_end = trial_ends_at.to_i

    str_sub.save && update_from_stripe_object!(str_sub)
  end

  def toggle_cancellation!
    if (self.subscription_type == 'fixed') && (self.status != 'canceled')
      self.ended_at = Time.zone.now
      self.status = 'canceled'
      save! && return
    end

    raise "Can't cancel cancelled subscription" if (self.status == 'canceled')

    if is_cancelling?
      uncancel_subscription!
    else
      cancel_subscription!
    end
  end

  def cancel_subscription! # affects stripe
    str_sub = self.stripe_subscription

    # if there's an unpaid or overdue invoice, cancel immediately so it doesn't keep trying to charge the card
    if is_delinquent?
      str_sub.delete
    else # otherwise cancel at period end
      str_sub.cancel_at_period_end = true
    end
    str_sub.save

    update_from_stripe_object!(str_sub)
  end

  def cancel_subscription_now! # affects stripe
    str_sub = self.stripe_subscription

    begin
      str_sub.delete
    rescue Stripe::InvalidRequestError
      return
    end

    update_from_stripe_object!(str_sub)
  end

  def uncancel_subscription! # affects stripe
    str_sub = self.stripe_subscription
    str_sub.cancel_at_period_end = false
    str_sub.save
    
    update_from_stripe_object!(str_sub)
  end

  def mark_as_lapsed_if_lapsed!
    set_status
    save!
  end

  def cancel_if_subscription_is_missing!
    return true if self.is_fixed?
    begin
      str_sub = self.stripe_subscription
      if str_sub.status == 'canceled'
        self.canceled_at = str_sub.canceled_at ? Time.zone.at(str_sub.canceled_at) : nil
        self.ended_at = str_sub.ended_at ? Time.zone.at(str_sub.ended_at) : nil
        self.status = str_sub.status
        self.save!
      end
    rescue Stripe::InvalidRequestError => e
      if (e.code&.to_s == 'resource_missing')
        self.update status: 'canceled'
      end
    end
  end

  def update_from_stripe_object!(str_obj)
    self.stripe_id = str_obj.id
    self.current_period_ends_at = str_obj.current_period_end ? Time.zone.at(str_obj.current_period_end) : nil
    self.cancel_at_period_end = str_obj.cancel_at_period_end ? true : false
    self.canceled_at = str_obj.canceled_at ? Time.zone.at(str_obj.canceled_at) : nil
    self.trial_ends_at = str_obj.trial_end ? Time.zone.at(str_obj.trial_end) : nil
    self.ended_at = str_obj.ended_at ? Time.zone.at(str_obj.ended_at) : nil
    self.status = str_obj.status
    self.plan_id = Plan.find_by!(stripe_id: str_obj.plan.id).id
    self.user_id = User.find_by!(stripe_id: str_obj.customer).id
    self.product_id = Product.find_by!(stripe_id: str_obj.plan.product).id

    self.save!
  end

  private

  def orphan_gift_subscriptions
    self.gift_subscriptions.update_all(subscription_id: nil)
  end

  def orphan_invoices
    self.invoices.update_all(subscription_id: nil)
  end

  def set_ended_at_for_fixed
    return true if self.subscription_type != 'fixed'

    self.ended_at = ([self.created_at, Time.zone.now].compact.sort.first + self.duration_months.months)
  end

  def set_status
    return true if self.subscription_type != 'fixed'

    self.status = if self.ended_at.nil? || (self.ended_at > (Time.zone.now + 1.day))
      'active'
    else
      'lapsed'
    end
  end

  def sync_stripe_subscription
    return unless self.subscription_type == 'stripe'
    return if self.stripe_id.present? && self.persisted?

    if !self.stripe_id.present? && !self.persisted?
      create_stripe_subscription # create if the stripe sub doesn't exist yet
    end
  end

  def create_stripe_subscription
    # landing page sign ups are hardcoded here for a free month
    # adding that logic to the landing page model is as straightforward
    # as you'd guess it'd be – add an integer of free_days to landing_page
    # and use it here
    str_subscription = if self.landing_page_slug.present?
      Stripe::Subscription.create(
        customer: user.stripe_id,
        items: [{ plan: plan.stripe_id }],
        trial_end: (Time.zone.now + 1.month).to_i,
        expand: ['latest_invoice.payment_intent'] # TODO: does this happen if there's a trial?
      )
    elsif self.user.stripe_customer.sources.any?
      Stripe::Subscription.create(
        customer: user.stripe_id,
        items: [{ plan: plan.stripe_id }],
        expand: ['latest_invoice.payment_intent'] # Return the created payment intent.
      )
    else # if there's no card, free day
      Stripe::Subscription.create(
        customer: user.stripe_id,
        items: [{ plan: plan.stripe_id }],
        trial_end: (Time.zone.now + 1.day).to_i,
        expand: ['latest_invoice.payment_intent']
      )
    end

    self.update_from_stripe_object!(str_subscription)
  end
end
