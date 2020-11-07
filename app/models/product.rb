class Product < ApplicationRecord
  has_many :plans
  has_many :subscriptions, through: :plans
  has_many :users, through: :subscriptions

  validates :name, presence: true

  scope :active, -> { where(name: ['Digital + Print subscription', 'Digital subscription']) }
  scope :includes_print, -> { where('name ILIKE ?', '%print%') }

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

  def is_active_digital? # TODO: hardcoded
    (name == 'Digital subscription')
  end

  def is_active_print? # TODO: hardcoded
    (name == 'Digital + Print subscription')
  end
  
  def annual_base_price
    return 0 if !base_price
    (base_price * 12)
  end

  def base_plan
    self.plans.find_or_create_by!(amount: self.base_price, interval: 'month', interval_count: 1)
  end

  def base_annual_plan
    self.plans.find_or_create_by!(amount: self.annual_base_price, interval: 'year', interval_count: 1)
  end
  
  def student_plan
    self.plans.find_or_create_by!(amount: (self.base_price / 2), interval: 'month', interval_count: 1)
  end

  def slug
    return 'print' if self.name == 'Digital + Print subscription'
    return 'digital' if self.name == 'Digital subscription'
    return self.name.parameterize
  end

  def self.find_by_slug(slug) # TODO this shouldn't be hardcoded!
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

  # TODO more fields could be updated from stripe
  def update_from_stripe_object!(stripe_object)
    self.update!(stripe_id: stripe_object.id)
  end
end
