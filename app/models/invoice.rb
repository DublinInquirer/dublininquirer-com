class Invoice < ApplicationRecord
  validates :stripe_id, presence: true, uniqueness: true

  belongs_to :user, optional: true
  belongs_to :subscription, optional: true

  def to_param
    self.number
  end

  def update_from_stripe!
    StripeImporter.update_invoice_from_stripe(self)
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

  private

  def line_item_for_digital(amount, quantity)
    {
      title: 'Digital access',
      unit_price: VatCalculator.net_from_gross(amount,:digital),
      quantity: quantity,
      vat_rate: VatCalculator.rate_for(:digital),
      net: VatCalculator.net_from_gross(amount,:digital),
      gross: amount
    }
  end

  def line_item_for_print(amount, quantity)
    {
      title: 'Print edition',
      unit_price: VatCalculator.net_from_gross(amount,:print),
      quantity: quantity,
      vat_rate: VatCalculator.rate_for(:print),
      net: VatCalculator.net_from_gross(amount,:print),
      gross: amount
    }
  end
end
