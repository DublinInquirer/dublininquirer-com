require 'csv'
require 'namae'

class User < ApplicationRecord
  mount_uploader :portrait, PortraitUploader

  authenticates_with_sorcery!

  validates :email_address, uniqueness: true, presence: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, length: { minimum: 6 }, on: :password_reset
  validates :nickname, uniqueness: true, allow_blank: true
  validates :rss_key, uniqueness: true

  has_many :comments
  has_many :subscriptions
  has_many :plans, through: :subscriptions
  has_many :invoices
  has_many :user_notes

  attribute :referral_required, :string # for spam trap only
  attribute :stripe_token, :string

  before_save :create_stripe_customer, unless: :stripe_id?
  before_save :generate_rss_key, unless: :rss_key?
  before_save :reset_hub, if: :will_save_change_to_address?
  before_validation :normalise_email, :figure_out_country_code, :normalise_name

  before_destroy :orphan_comments, :orphan_invoices, :orphan_visitors

  scope :unmigrated, -> { where(set_password_at: nil) }
  scope :wants_newsletter, -> { where(subscribed_weekly: true) }
  scope :migrated, -> { where.not(set_password_at: nil) }
  scope :subscribed, -> { joins(:subscriptions).merge( Subscription.active ).distinct }
  scope :needs_shipping, -> { joins(:subscriptions).merge( Subscription.needs_shipping ).distinct }
  scope :admin, -> { where(role: %w(admin superadmin)) }
  scope :superadmin, -> { where(role: 'superadmin') }

  def self.is_valid_key?(key)
    return false unless key.present?
    user = User.where(rss_key: key.strip.downcase).take
    return false unless user.present?
    return false unless user.subscriber?
    true
  end

  def slug
    self.id # TODO hashed?
  end

  def has_password?
    self.set_password_at.present?
  end

  def schedule_for_deletion! # paranoid
    self.deleted_at = Time.now + 1.day
    self.email_address = "#{ self.email_address }///#{ self.deleted_at.to_i }"
    save!
  end

  def cancel_deletion! # unschedule for deletion
    self.deleted_at = nil
    self.email_address = self.email_address.split('///').try(:first)
    save!
  end

  def scheduled_for_deletion?
    self.deleted_at.present?
  end

  def delete_completely!
    return false unless self.scheduled_for_deletion? # probably stupid but i'm scared
    self.comments.each(&:destroy)
    self.user_notes.each(&:destroy)
    self.subscriptions.each(&:delete_completely!)
    if !self.stripe_customer.deleted?
      self.remove_sensitive_information_from_stripe!
      self.remove_sources_from_stripe!
      self.stripe_customer.delete
    end

    reload
    
    self.destroy
  end

  def is_banned?
    self.banned_at.present?
  end

  def ban!
    return true if self.is_banned?
    self.banned_at = Time.zone.now
    save!
  end

  def remove_sources_from_stripe!
    return unless self.stripe_id.present?
    
    cus = self.stripe_customer

    return unless cus.present? and !cus.deleted?

    cus.sources.each do |src|
      src.delete
    end

    cus.save
  end

  def remove_sensitive_information_from_stripe!
    return unless self.stripe_id.present?
    
    cus = self.stripe_customer

    return unless cus.present? and !cus.deleted?

    cus.email = nil
    cus.name = nil
    cus.phone = nil
    cus.metadata = {}
    cus.description = nil

    cus.save
  end

  def update_from_stripe_object!(stripe_object)
    return unless stripe_object.is_a?(Stripe::Customer)

    src = stripe_object.default_source

    self.sources_count = stripe_object.sources.total_count

    src = if stripe_object.default_source.is_a?(String)
      Stripe::Customer.retrieve_source(
        stripe_object.id,
        stripe_object.default_source
      )
    elsif stripe_object.default_source.is_a?(Stripe::Card)
      stripe_object.default_source
    elsif stripe_object.default_source.nil?
      nil
    else
      raise "Can't understand source: #{ stripe_object.default_source.inspect }"
    end

    if src
      self.card_last_4 = src.last4
      self.card_brand = src.brand
    end

    self.save!
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
    return false if self.sources_count > 0
    return false if self.subscriptions.empty?

    most_recent = self.subscriptions.order('created_at desc').first

    return true if (most_recent.subscription_type == 'stripe') && [:active, :past_due, :unpaid, :trialing].include?(most_recent.status.downcase.to_sym)

    false
  end

  def delinquent?
    self.subscriptions.each do |s|
      return true if [:unpaid, :past_due].include?(s.status.downcase.to_sym)
      return true if (s.status.downcase.to_sym == :trialing) && (self.sources_count == 0)
    end
    false
  end

  def lapsed? # mostly for gift subs
    return false if self.subscription.present? # false if an active sub
    return false if self.subscriptions.empty? # false if they've never had one
    true
  end

  def patron? # pays more than base price
    return false unless self.subscription
    self.subscription.patron?
  end

  def subscription
    return nil unless self.subscriptions.active.any?
    subscriptions.active.order('created_at desc').first
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
    @source ||= self.stripe_customer.default_source
  end

  def stripe_sources
    return [] unless self.stripe_id.present?
    @sources ||= self.stripe_customer.sources
  end

  def stripe_customer
    return nil unless self.stripe_id.present?
    @stripe_customer ||= Stripe::Customer.retrieve(id: self.stripe_id, expand: ['default_source', 'sources'])
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
      UserMailer.welcome_email(self.id, self.subscription.id).deliver_later
    else
      UserMailer.welcome_email(self.id, self.subscription.id).deliver_now
    end
  end

  def send_dunning_email!
    # don't send too many emails
    return if self.payment_failed_email_sent_at && (self.payment_failed_email_sent_at > 48.hours.ago)

    touch :payment_failed_email_sent_at
    
    if Rails.env.production?
      UserMailer.payment_failed_email(self.id).deliver_later
    else
      UserMailer.payment_failed_email(self.id).deliver_now
    end
  end

  def country_name
    return nil unless self.country_code
    c = ISO3166::Country[self.country_code]
    return nil if c.nil?
    c.translations['en']
  end

  def add_stripe_source(stripe_token)
    c = self.stripe_customer
    new_source = c.sources.create(source: stripe_token)
    c.default_source = new_source
    c.save && update_from_stripe_object!(c)
  end

  def pay_outstanding_invoice # TODO: forgive all previous invoices
    return unless self.stripe_customer.present?
    return unless self.delinquent?
    if self.stripe_invoices.any? && !self.stripe_invoices.first['paid']
      self.stripe_invoices.first.pay
    end
  end

  def generate_rss_key!
    generate_rss_key
    save!
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << %w(name email_address)
      all.find_each do |u|
        csv << {
          name: u.full_name,
          email: u.email_address
        }.values
      end
    end
  end

  def self.searchable_columns
    [:email_address, :full_name, :nickname, :stripe_id, :address_line_1, :address_line_2, :city, :county, :post_code, :country, :country_code, :hub]
  end

  private

  def generate_rss_key
    self.rss_key = SecureRandom.hex(24).downcase
  end

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
    if will_save_change_to_email_address?
      self.email_address = self.email_address.downcase.strip
    end

    true
  end

  def orphan_comments
    self.comments.each do |comment|
      comment.user = nil
      comment.nickname = self.comment_name
      comment.email_address = self.email_address
      comment.save!
    end
  end

  def orphan_invoices
    self.invoices.update_all(user_id: nil)
  end

  def orphan_visitors
    Visitor.where(user_id: self.id).update_all(user_id: nil)
  end

  def create_stripe_customer
    customer = if self.stripe_token.present?
      Stripe::Customer.create(source: self.stripe_token)
    else
      Stripe::Customer.create
    end

    self.stripe_id = customer.id

    self.sources_count = customer.sources.total_count
    if customer.sources.total_count > 0
      self.card_last_4 = customer.sources.first.last4
      self.card_brand = customer.sources.first.brand
    end
  end
end
