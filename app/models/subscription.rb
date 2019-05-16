require 'csv'

class Subscription < ApplicationRecord
  belongs_to :plan
  belongs_to :user, optional: true

  has_many :invoices

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

  scope :paid, -> { where(status: %w(trialing active)) }
  scope :active, -> { where(status: %w(trialing active past_due unpaid)) }
  scope :delinquent, -> { where(status: %w(past_due unpaid)) }
  scope :is_stripe, -> { where(subscription_type: 'stripe') }
  scope :includes_print, -> { joins(:plan).merge( Plan.includes_print ).distinct }
  scope :needs_shipping, -> { active.includes_print }

  def update_from_stripe!
    return unless self.stripe_id && self.stripe_subscription.present?

    subs = self.stripe_subscription
    u = User.where(stripe_id: subs['customer']).first

    self.user = if u.present?
      u
    else
      raise "No user for #{ self.id }: #{ self.stripe_id }"
    end

    self.plan = if subs['plan'].present?
      Plan.find_or_create_by(stripe_id: subs['plan']['id'])
    else
      raise "No plan for subscription: #{ self.stripe_id }"
    end

    self.metadata = subs['metadata']
    self.status = subs['status']
    self.cancel_at_period_end = subs['cancel_at_period_end']

    self.current_period_ends_at = if subs['current_period_end'].present?
      Time.zone.at(subs['current_period_end'])
    else
      nil
    end

    self.canceled_at = if subs['canceled_at'].present?
      Time.zone.at(subs['canceled_at'])
    else
      nil
    end

    self.ended_at = if subs['ended_at'].present?
      Time.zone.at(subs['ended_at'])
    else
      nil
    end

    save!
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

  def human_status
    return 'cancelling' if is_cancelling?
    self.status
  end

  def product_name
    self.product.name
  end

  def product
    self.plan.product
  end

  def requires_address?
    return false unless self.product.present?
    self.product.requires_address?
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
    @stripe_subscription ||= Stripe::Subscription.retrieve(self.stripe_id)
  end

  def is_stripe?
    (self.subscription_type == 'stripe')
  end

  def is_fixed?
    (self.subscription_type == 'fixed')
  end

  def patron?
    (self.plan.is_friend? or self.plan.is_patron?)
  end

  def changeable?
    (self.is_stripe? && self.product.is_active? && self.is_base_price?)
  end

  def change_product_to!(product_sym, maintain_price=false) # affects stripe
    new_product = Product.find_by_slug(product_sym.to_sym)
    old_plan = self.plan

    old_amount = if self.stripe_subscription.tax_percent && self.stripe_subscription.tax_percent > 0
      (old_plan.amount + ((self.stripe_subscription.tax_percent * 0.01) * old_plan.amount))
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

    str_sub.save

    update_from_stripe!
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

    str_sub.save

    update_from_stripe!
  end

  def change_billing_date_to!(date) # affects stripe
    str_sub = self.stripe_subscription
    str_sub.prorate = false
    str_sub.trial_end = Date.parse(date).beginning_of_day.to_i

    str_sub.save

    update_from_stripe!
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
      str_sub.save
    end

    update_from_stripe!
  end

  def uncancel_subscription! # affects stripe
    str_sub = self.stripe_subscription
    str_sub.cancel_at_period_end = false
    str_sub.save

    update_from_stripe!
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << %w(id name address_line_1 address_line_2 city county post_code country hub)
      all.includes(:plan).find_each do |s|
        u = s.user
        csv << {
          id: s.id,
          name: u.try(:full_name),
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

  def self.recent_split_percentage
    all_recent = all.is_stripe.where(created_at: ((Time.zone.now - 1.month)..Time.zone.now))

    return ((all_recent.includes_print.count * 100.0) / all_recent.count)
  end

  def set_address_from_user!
    return false unless self.user.present?
    set_address_from_user(self.user)
    save!
  end

  def self.searchable_columns
    [:stripe_id]
  end

  private

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
      create_stripe_subscription # create if the sub doesn't exist yet
    end
  end

  def create_stripe_subscription
    subscription = if self.landing_page_slug.present? # if there's a landing_page_slug, free month
      Stripe::Subscription.create(
        customer: user.stripe_id,
        items: [{ plan: plan.stripe_id }],
        trial_end: (Time.zone.now + 1.month).to_i
      )
    elsif self.user.stripe_customer.sources.any? # if there's a card, charge
      Stripe::Subscription.create(
        customer: user.stripe_id,
        items: [{ plan: plan.stripe_id }]
      )
    else # if there's no card, free day
      Stripe::Subscription.create(
        customer: user.stripe_id,
        items: [{ plan: plan.stripe_id }],
        trial_end: (Time.zone.now + 1.day).to_i
      )
    end
    self.stripe_id = subscription.id
    self.current_period_ends_at = Time.zone.at(subscription['current_period_end'])
    self.status = subscription['status']
  end
end
