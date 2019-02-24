class Product < ApplicationRecord
  has_many :plans
  has_many :subscriptions, through: :plans
  has_many :users, through: :subscriptions

  validates :name, presence: true

  scope :active, -> { where(name: ['Digital + Print subscription', 'Digital subscription']) }
  scope :includes_print, -> { where('name ILIKE ?', '%print%') }

  def update_from_stripe!
    str_product = self.stripe_product
    self.name = str_product['name']
    self.save!
  end

  def requires_address?
    self.name.downcase.include?('print')
  end

  def is_active?
    (is_active_digital? || is_active_print?)
  end

  def is_print?
    self.name.downcase.include?('print')
  end

  def is_digital?
    !self.is_print?
  end

  def is_active_digital?
    (name == 'Digital subscription')
  end

  def is_active_print?
    (name == 'Digital + Print subscription')
  end

  def base_plan
    self.plans.find_or_create_by(amount: self.base_price, interval: 'month')
  end

  def slug
    return 'print' if self.name == 'Digital + Print subscription'
    return 'digital' if self.name == 'Digital subscription'
    return self.name.parameterize
  end

  def self.find_by_slug(slug)
    case slug.downcase.to_sym
    when :print
      find_by_name('Digital + Print subscription')
    when :digital
      find_by_name('Digital subscription')
    else
      raise "Invalid product slug: #{ slug }"
    end
  end

  def stripe_product
    return nil unless self.stripe_id.present?
    @stripe_product ||= Stripe::Product.retrieve(self.stripe_id)
  end
end
