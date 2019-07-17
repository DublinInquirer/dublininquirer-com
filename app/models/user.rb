require 'csv'
require 'namae'

class User < ApplicationRecord
  mount_uploader :portrait, PortraitUploader

  authenticates_with_sorcery!

  validates :email_address, uniqueness: true, presence: true
  validates :password, length: { minimum: 5 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, length: { minimum: 5 }, on: :password_reset
  validates :nickname, uniqueness: true, allow_blank: true

  has_many :comments
  has_many :subscriptions
  has_many :plans, through: :subscriptions
  has_many :invoices

  attribute :stripe_token, :string

  before_save :create_stripe_customer, unless: :stripe_id?
  before_save :add_stripe_source, if: :stripe_token?
  before_save :reset_hub, if: :will_save_change_to_address?
  before_validation :normalise_email, :figure_out_country_code, :normalise_name

  before_destroy :orphan_comments

  scope :unmigrated, -> { where(set_password_at: nil) }
  scope :migrated, -> { where.not(set_password_at: nil) }
  scope :subscribed, -> { joins(:subscriptions).merge( Subscription.active ).distinct }
  scope :needs_shipping, -> { joins(:subscriptions).merge( Subscription.needs_shipping ).distinct }
  scope :admin, -> { where(role: %w(admin superadmin)) }
  scope :superadmin, -> { where(role: 'superadmin') }

  def slug
    self.id # TODO hashed?
  end

  def has_password?
    self.set_password_at.present?
  end

  def is_banned?
    self.banned_at.present?
  end

  def ban!
    return true if self.is_banned?
    self.banned_at = Time.zone.now
    save!
  end

  def update_from_stripe!
    return unless self.stripe_id.present?
    cus = self.stripe_customer

    if cus.nil?
      raise 'Missing customer for user: #{ self.id }'
    end

    self.metadata = cus['metadata']
    if self.metadata.is_a?(Hash)
      self.metadata['description'] = cus['description']
    else
      self.metadata = {'description': cus['description']}
    end

    self.sources_count = cus.respond_to?(:sources) ? cus.sources.count : 0
    if cus.default_source.present?
      cus.sources.each do |stripe_source|
        next unless stripe_source.id == cus.default_source

        self.card_last_4 = stripe_source.last4
        self.card_brand = stripe_source.brand
      end
    end

    save!
  end

  def can_comment?(article)
    return true if is_staff?
    return !(article.comments.by_user(self).not_approved.any?)
  end

  def has_address?
    self.address_lines.many?
  end

  def address_lines
    [
      self.address_line_1,
      self.address_line_2,
      (self.city == self.county) ? nil : self.city,
      "#{ self.county } #{ self.post_code }".strip,
      self.country
    ].compact.reject(&:blank?)
  end

  def comment_name
    self.nickname.present? ? self.nickname : self.full_name
  end

  def subscriber? # be more elegant about roles
    %w(free admin superadmin).include?(self.role) or
    self.subscriptions.active.any?
  end

  def is_staff?
    %w(staff admin superadmin).include?(self.role)
  end

  def is_admin?
    %w(admin superadmin).include?(self.role)
  end

  def is_superadmin?
    %w(superadmin).include?(self.role)
  end

  def special_offer_worthy?
    return false if subscribed? or delinquent?
    return false if (created_at + 1.day) > Time.zone.now

    true
  end

  def subscriber_since
    since_time = Time.zone.now

    self.subscriptions.each do |s|
      if s.created_at < since_time
        since_time = s.created_at
      end
    end

    since_time
  end

  def needs_source?
    self.subscriptions.each do |s|
      return true if (s.subscription_type == 'stripe') && [:active, :past_due, :unpaid, :trialing].include?(s.status.downcase.to_sym) && (self.sources_count == 0)
    end
    false
  end

  def delinquent?
    self.subscriptions.each do |s|
      return true if [:unpaid, :past_due].include?(s.status.downcase.to_sym)
      return true if (s.status.downcase.to_sym == :trialing) && (self.sources_count == 0)
    end
    false
  end

  def patron? # pays more than base price
    return false unless self.subscription
    self.subscription.patron?
  end

  def subscription
    return nil unless self.subscriptions.active.any?
    subscriptions.active.first
  end

  def subscription_status
    self.subscription.try(:status)
  end

  def plan_name
    plan = self.subscription.try(:plan)
    plan.try(:human_name)
  end

  def needs_setup?
    !self.set_password_at
  end

  def stripe_default_source
    return nil unless self.stripe_id.present?
    return nil unless self.stripe_customer.default_source.present?
    @source ||= self.stripe_customer.sources.retrieve(self.stripe_customer.default_source)
  end

  def stripe_sources
    return [] unless self.stripe_id.present?
    @sources ||= self.stripe_customer.sources
  end

  def stripe_customer
    return nil unless self.stripe_id.present?
    @stripe_customer ||= Stripe::Customer.retrieve(self.stripe_id)
  end

  def stripe_invoices
    return nil unless self.stripe_id.present?
    @stripe_invoices ||= Stripe::Invoice.list(customer: self.stripe_id)
  end

  def needs_to_confirm_plan?
    self.subscriptions.active.each do |subscription|
      next if subscription.product.is_active?
      next if subscription.plan.interval == 'year'
      next if (subscription.plan.amount > 7_99)

      return true # if paying less than 8/mo and monthly (except recently digital-only)
    end

    false
  end

  def requires_address?
    self.subscriptions.active.each do |s|
      return true if s.requires_address?
    end

    false
  end

  def send_welcome!
    return false unless self.subscriber?
    if Rails.env.production?
      UserMailer.welcome_email(self.id, self.subscription.id).deliver_later(wait: 72.minutes)
    else
      UserMailer.welcome_email(self.id, self.subscription.id).deliver_now
    end
  end

  def country_name
    return nil unless self.country_code
    c = ISO3166::Country[self.country_code]
    return nil if c.nil?
    c.translations['en']
  end

  def pay_outstanding_invoice # TODO: forgive all previous invoices
    return unless self.stripe_customer.present?
    return unless self.delinquent?

    if self.stripe_invoices.any? && !self.stripe_invoices.first['paid']
      self.stripe_invoices.first.pay
    end
  end

  def self.searchable_columns
    [:email_address, :full_name, :nickname, :stripe_id, :address_line_1, :address_line_2, :city, :county, :post_code, :country, :country_code, :hub]
  end

  private

  def reset_hub
    self.hub = ''
  end

  def normalise_name
    if will_save_change_to_full_name? # update name components
      self.given_name, self.surname = generate_name_components(self.full_name)
    elsif self.full_name.blank? or will_save_change_to_surname? or will_save_change_to_given_name?
      self.full_name = generate_full_name(self.given_name, self.surname)
    end

    self.given_name = self.given_name.try(:strip)
    self.surname = self.surname.try(:strip)
    self.full_name = self.full_name.try(:strip)
  end

  def generate_full_name(given, sur)
    "#{ given } #{ sur }".strip
  end

  def generate_name_components(name_str)
    namae = Namae.parse(name_str).first
    return '', '' unless namae.present?
    return namae['given'], namae['family']
  end

  def will_save_change_to_address?
    return false if will_save_change_to_hub?
    return true if will_save_change_to_address_line_1?
    return true if will_save_change_to_address_line_2?
    return true if will_save_change_to_city?
    return true if will_save_change_to_county?
    return true if will_save_change_to_post_code?
    return true if will_save_change_to_country?
    return true if will_save_change_to_country_code?
    false
  end

  def figure_out_country_code
    return true if self.country_code.present?
    return true if !self.country.present?

    if (self.country.downcase.strip == 'ireland')
      self.country_code = 'IE'
      return true
    end

    c = ISO3166::Country.find_country_by_name(self.country)

    if c.nil?
      raise "Country not found: #{ self.id }: #{ self.country }"
    end

    self.country_code = c.alpha2.upcase
    return true
  end

  def normalise_email
    self.email_address = self.email_address.downcase.strip
  end

  def orphan_comments
    self.comments.each do |comment|
      comment.user = nil
      comment.nickname = self.comment_name
      comment.email_address = self.email_address
      comment.save!
    end
  end

  def create_stripe_customer
    customer = Stripe::Customer.create
    self.stripe_id = customer.id
  end

  def add_stripe_source
    raise "Stripe customer not present for user: #{ self.id }" unless self.stripe_customer
    cus = stripe_customer
    nc = cus.sources.create(source: self.stripe_token)
    cus.default_source = nc
    cus.save
    self.stripe_token = nil

    begin
      self.pay_outstanding_invoice
    rescue Stripe::CardError
      raise "Card error" # TODO: something with this!
    end
  end
end
