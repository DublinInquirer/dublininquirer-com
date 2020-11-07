# Plans always should have an associated Stripe plan

class Plan < ApplicationRecord
  belongs_to :product
  has_many :subscriptions

  validates :interval, presence: true, if: -> (p) { p.stripe_id.blank? }
  validates :interval_count, presence: true, if: -> (p) { p.stripe_id.blank? }

  after_save :sync_to_stripe

  scope :includes_print, -> { joins(:product).merge( Product.includes_print ).distinct }

  def human_name
    self.product.name.gsub('subscription','').strip
  end

  def stripe_plan
    return nil unless self.stripe_id.present?
    @stripe_plan ||= Stripe::Plan.retrieve(self.stripe_id)
  rescue Stripe::InvalidRequestError
    nil
  end

  def monthly?
    (self.interval == 'month')
  end

  def yearly?
    (self.interval == 'year')
  end
  
  def monthly_amount
    case self.interval
    when 'month'
      self.amount
    when 'year'
      (self.amount / 12)
    end
  end

  def is_friend?
    return false unless amount.present?
    ((self.monthly_amount > self.product.base_price) && !self.is_patron?)
  end

  def is_patron?
    return false unless amount.present?
    (self.monthly_amount >= 50_00)
  end

  def requires_address?
    self.product.try(:requires_address?)
  end

  def is_print?
    self.product.try(:is_print?)
  end

  def is_digital?
    self.product.try(:is_digital?)
  end

  def self.find_by_slug_and_interval(slug, interval)
    product = Product.find_by_slug(slug)
    find_by(product_id: product.id, interval: interval.to_s)
  end

  def is_base_plan?
    (self.product.base_price == self.amount)
  end

  # TODO more fields could be updated from stripe
  def update_from_stripe_object!(stripe_object)
    self.update!(stripe_id: stripe_object.id)
  end

  private

  def sync_to_stripe
    if !self.stripe_id.present? # if already exists, it already exists
      potential_id = "#{ self.product.slug }-#{ self.interval.first }-#{ self.amount }"
      begin
        str_plan = Stripe::Plan.retrieve(potential_id)
      rescue Stripe::InvalidRequestError
        str_plan = Stripe::Plan.create(
          amount: self.amount,
          interval: self.interval,
          interval_count: self.interval_count,
          product: self.product.stripe_id,
          currency: "eur",
          id: potential_id
        )
      end

      self.update_from_stripe_object!(str_plan)
    end
  end
end
