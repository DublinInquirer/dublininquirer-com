require 'stripe_mock'
require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  test "monthly and yearly" do
    mplan = build(:plan, interval: 'month')
    yplan = build(:plan, interval: 'year')

    assert mplan.monthly?
    assert yplan.yearly?
    assert_not mplan.yearly?
    assert_not yplan.monthly?
  end

  test "friends and patrons" do
    product = build(:product, base_price: 6_00)
    rplan = build(:plan, amount: 6_00, product: product)
    fplan = build(:plan, amount: 20_00, product: product)
    pplan = build(:plan, amount: 50_00, product: product)

    assert rplan.is_base_plan?
    assert_not rplan.is_friend?
    assert fplan.is_friend?
    assert_not fplan.is_patron?
    assert_not pplan.is_friend?
    assert pplan.is_patron?
  end

  test "update from stripe object" do
    StripeMock.start

    plan = create(:plan)

    stripe_product = Stripe::Product.create(name: 'test product')
    stripe_plan = Stripe::Plan.create(
      name: 'test plan',
      amount: 499,
      product: stripe_product.id,
      currency: 'EUR',
      interval: 'month'
    )

    assert_not_equal plan.stripe_id, stripe_plan.id

    plan.update_from_stripe_object!(stripe_plan)

    assert_equal plan.stripe_id, stripe_plan.id

    StripeMock.stop
  end
end