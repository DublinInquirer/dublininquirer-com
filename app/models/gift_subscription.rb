# Gift subscriptions:
# - charges card
# - creates user
# - creates fixed subscription

class GiftSubscription < ApplicationRecord
  belongs_to :subscription
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

  attribute :stripe_token, :string

  before_validation :set_redemption_code, if: -> (gs) { gs.redemption_code.blank? }
  after_initialize :setup_subscription, if: -> (gs) { !gs.subscription }
  after_save :save_subscription, if: -> (gs) { !gs.subscription.changed? }

  validates :plan_id, presence: true

  validates :giver_given_name, presence: true
  validates :giver_surname, presence: true
  validates :giver_email_address, presence: true

  validates :recipient_given_name, presence: true
  validates :recipient_surname, presence: true
  validates :recipient_email_address, presence: true

  validates :duration, presence: true, numericality: { only_integer: true }

  validate :user_is_not_subscribed

  scope :by_date, -> { order('created_at asc') }

  def requires_address?
    return false unless self.plan.present?
    self.plan.requires_address?
  end

  def price # plan.amount * duration = full price
    (self.plan.amount * self.duration)
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

  def stripe_charge
    return nil unless self.stripe_id
    @charge ||= Stripe::Charge.retrieve(self.stripe_id)
  end

  def capture_charge!
    return nil unless self.stripe_token.present?
    create_stripe_charge
    self.save
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

  def create_stripe_charge
    charge = Stripe::Charge.create(
      amount: self.price,
      currency: "eur",
      source: self.stripe_token,
      description: "Gift Subscription: #{ self.product_name }"
    )

    self.stripe_id = charge.id

    if !charge['failure_code']
      self.charged_at = Time.zone.now
    end
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

  def user_is_not_subscribed
    return unless self.user
    if (self.subscription.persisted? && self.user.subscriptions.paid.where.not(id: self.subscription.id).any?) || (!self.subscription.persisted? && self.user.subscriptions.paid.any?)
      errors.add(:recipient_email_address, "is already subscribed")
    end
  end
end
