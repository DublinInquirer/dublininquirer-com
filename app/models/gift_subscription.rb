# Gift subscriptions:
# - charges card
# - creates user
# - creates fixed subscription
# its stripe_id corresponds to a stripe payment intent

class GiftSubscription < ApplicationRecord
  belongs_to :subscription, optional: true
  belongs_to :plan

  attribute :recipient_given_name, :string
  attribute :recipient_surname, :string
  attribute :recipient_email_address, :string

  attribute :recipient_address_line_1, :string
  attribute :recipient_address_line_2, :string
  attribute :recipient_city, :string
  attribute :recipient_county, :string
  attribute :recipient_post_code, :string
  attribute :recipient_country_code, :string

  before_validation :set_redemption_code, if: -> (gs) { gs.redemption_code.blank? }
  after_initialize :setup_subscription, if: -> (gs) { !gs.subscription }
  after_save :save_subscription, if: -> (gs) { !gs.subscription.changed? }

  attr_accessor :charge_object

  validates :plan_id, presence: true

  validates :giver_given_name, presence: true
  validates :giver_surname, presence: true
  validates :giver_email_address, presence: true

  validates :recipient_given_name, presence: true
  validates :recipient_surname, presence: true
  validates :recipient_email_address, presence: true

  validates :duration, presence: true, numericality: { only_integer: true }

  validate :email_is_not_subscribed

  scope :by_date, -> { order('created_at desc') }

  def to_param
    redemption_code
  end

  def requires_address?
    return false unless self.plan.present?
    self.plan.requires_address?
  end

  def price # plan.amount * duration = full price, except at christmas
    date = self.persisted? ? self.created_at : Date.current
    if (date.month == 12) or (date.month == 11) && (date.day > 15)
      (self.plan.amount * (duration * (10.0/12)).round)
    else
      (self.plan.amount * self.duration)
    end
  end

  def product
    self.plan.product
  end

  def product_name
    "#{ self.product.name } - #{ self.duration } mo"
  end

  def user
    @user ||= self.subscription.try(:user)
  end

  def user_full_name
    self.user.try(:full_name)
  end

  def user_email_address
    self.user.try(:email_address)
  end

  def giver_full_name
    "#{ self.giver_given_name } #{ self.giver_surname }".strip
  end

  def stripe_payment_intent
    return nil unless self.stripe_id
    @payment_intent ||= Stripe::PaymentIntent.retrieve(self.stripe_id)
  end

  def self.searchable_columns
    [
      :giver_given_name, :giver_surname, :first_address_line_1, :first_address_line_2,
      :first_city, :first_county, :first_post_code, :first_country_code, :notes, :redemption_code, :stripe_id
    ]
  end

  def has_address?
    self.address_lines.many?
  end

  def address_lines
    [
      self.first_address_line_1,
      self.first_address_line_2,
      self.first_city,
      "#{ self.first_county } #{ self.first_post_code }".strip,
      self.first_country_name
    ].compact.reject(&:blank?)
  end

  def first_country_name
    return nil unless self.first_country_code
    c = ISO3166::Country[self.first_country_code]
    return nil if c.nil?
    c.translations['en']
  end

  private

  def save_subscription
    self.subscription.save!
  end

  def set_redemption_code
    self.redemption_code = SecureRandom.hex(4)
  end

  def setup_subscription
    self.subscription = Subscription.new(subscription_params)
  end

  def subscription_params
    {
      email_address: self.recipient_email_address,
      given_name: self.recipient_given_name,
      surname: self.recipient_surname,
      plan_id: self.plan.try(:id),
      address_line_1: self.recipient_address_line_1,
      address_line_2: self.recipient_address_line_2,
      city: self.recipient_city,
      county: self.recipient_county,
      post_code: self.recipient_post_code,
      country_code: self.recipient_country_code,
      ended_at: self.duration.present? ? (Time.zone.now.end_of_year + self.duration.months) : nil,
      subscription_type: 'fixed'
    }
  end

  def email_is_not_subscribed
    recipient_user = User.where(email_address: self.recipient_email_address).take
    return unless recipient_user
    
    if recipient_user.subscriber?
      errors.add(:recipient_email_address, "is already subscribed")
    end
  end
end
