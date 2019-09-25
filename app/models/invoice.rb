class Invoice < ApplicationRecord
  validates :stripe_id, presence: true, uniqueness: true

  belongs_to :user, optional: true
  belongs_to :subscription, optional: true

  def to_param
    self.number
  end

  def stripe_invoice
    return nil unless self.stripe_id.present?
    @stripe_invoice ||= Stripe::Invoice.retrieve(self.stripe_id)
  end

  def display_name
    if self.product.present?
      return "#{ self.product.name } — #{ self.created_on.strftime('%m-%d-%Y') }"
    end

    "Invoice #{ self.created_on.strftime('%-d %b %Y') }"
  end

  def product
    @product ||= self.plan.product
  end

  def plan
    @plan ||= Plan.find(self.lines.map { |l| l['plan_id'] }.uniq.first)
  end

  def lines_with_vat # split into a few methods
    @lines_with_vat ||= self.lines.map do |line|
      plan = Plan.find(line['plan_id'])
      quantity = line['quantity']
      gross = line['amount']

      if plan.product.is_active_digital?
        line_item_for_digital(gross, quantity)
      else
        digital_base_price = Product.find_by_slug(:digital).base_price
        digital_amount = [digital_base_price, gross].min
        print_amount = gross - digital_amount

        [ line_item_for_digital(digital_amount, quantity),
          line_item_for_print(print_amount, quantity) ]
      end
    end.flatten
  end

  def net_amount
    self.lines_with_vat.sum do |line|
      line[:net]
    end
  end

  def vat_amount
    self.lines_with_vat.sum do |line|
      line[:gross] - line[:net]
    end
  end

  def gross_amount
    self.total
  end

  def update_from_stripe_object!(stripe_object)
    subscription = Subscription.find_by(stripe_id: stripe_object.subscription)
    user = User.find_by(stripe_id: stripe_object.customer)

    lines = stripe_object.lines.map do |line|
      {
        stripe_id: line.id,
        amount: line.amount,
        quantity: line.quantity,
        plan_id: line.plan.present? ? Plan.find_or_create_by(stripe_id: line.plan.id).id : nil,
        type: line.type
      }
    end

    self.assign_attributes({
      stripe_id: stripe_object.id,
      number: stripe_object.number,
      receipt_number: stripe_object.receipt_number,
      total: stripe_object.total,
      paid: stripe_object.paid,
      attempted: stripe_object.attempted,
      created_on: Time.zone.at(stripe_object.created).to_date,
      due_on: stripe_object.due_date.present? ? Time.zone.at(stripe_object.due_date).to_date : nil,
      period_starts_at: Time.zone.at(stripe_object.period_start),
      period_ends_at: Time.zone.at(stripe_object.period_end),
      next_payment_attempt_at: stripe_object.next_payment_attempt.present? ? Time.zone.at(stripe_object.next_payment_attempt) : nil,
      lines: lines,
      user_id: user.try(:id),
      subscription_id: subscription.try(:id),
      created_at: Time.zone.at(stripe_object.created),
      updated_at: Time.zone.at(stripe_object.created)
    })

    save_without_timestamping!
  end

  def self.create_from_stripe_object!(stripe_object)
    i = find_or_initialize_by(stripe_id: stripe_object.id)
    i.update_from_stripe_object!(stripe_object)
  end

  private

  def line_item_for_digital(amount, quantity)
    {
      title: 'Digital access',
      unit_price: VatCalculator.net_from_gross(amount,:digital, created_at.strftime('%Y')),
      quantity: quantity,
      vat_rate: VatCalculator.rate_for(:digital, created_at.strftime('%Y')),
      net: VatCalculator.net_from_gross(amount,:digital, created_at.strftime('%Y')),
      gross: amount
    }
  end

  def line_item_for_print(amount, quantity)
    {
      title: 'Print edition',
      unit_price: VatCalculator.net_from_gross(amount,:print, created_at.strftime('%Y')),
      quantity: quantity,
      vat_rate: VatCalculator.rate_for(:print, created_at.strftime('%Y')),
      net: VatCalculator.net_from_gross(amount,:print, created_at.strftime('%Y')),
      gross: amount
    }
  end
end
