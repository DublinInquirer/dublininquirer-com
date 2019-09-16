require 'stripe_mock'
require 'test_helper'

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  test "normalise plan" do
    # todo
  end

  test "full name" do
    user = create(:user, given_name: 'Undine', surname: 'Spragg')
    subscription = create(:subscription, user: user)
    assert_equal 'Undine Spragg', subscription.full_name
  end

  test "delete completely" do
    subscription = create(:subscription)
    assert subscription.delete_completely!
  end
  
  test "status" do
    subscription = build(:subscription, status: 'active')
    assert_equal 'active', subscription.status

    subscription = build(:subscription, status: 'canceled')
    assert subscription.is_cancelled?

    subscription = build(:subscription, status: 'past_due')
    assert subscription.is_delinquent?
  end

  test "stripiness" do
    subscription = build(:subscription, subscription_type: 'fixed')

    assert subscription.is_fixed?
    assert_not subscription.is_stripe?
  end

  test "product" do
    product = build(:product, name: 'Print Edition')
    plan = build(:plan, product: product)
    subscription = build(:subscription, plan: plan)

    assert_equal 'Print Edition', subscription.product_name
    assert_equal product, subscription.product
  end

  test "mrr" do
    # todo
  end

  test "requires address" do
    print_product = build(:product, name: 'Print Edition')
    print_plan = build(:plan, product: print_product)
    print_sub = build(:subscription, plan: print_plan)

    digital_product = build(:product, name: 'Digital Edition')
    digital_plan = build(:plan, product: digital_product)
    digital_sub = build(:subscription, plan: digital_plan)

    assert print_sub.requires_address?
    assert_not digital_sub.requires_address?
    assert print_sub.print?
    assert_not digital_sub.print?
  end

  # TODO: this is unwieldy and verbose!
  test "change product" do
  end

  test "change price" do
  end

  test "change billing date" do
  end

  test "cancel subscription" do
    # toggle cancellation
    # cancel_subscription!
    # cancel_subscription_now!
    # uncancel subscription
  end

  test "mark as lapsed" do
  end

  # TODO: unweildy as hell!
  test "update from stripe object" do
    StripeMock.start
    str_helper = StripeMock.create_test_helper

    str_product = Stripe::Product.create(name: 'Digital subscription')
    product = create(:product, stripe_id: str_product.id)
    product.update_from_stripe_object!(str_product)

    str_plan = Stripe::Plan.create(
      amount: 500,
      product: str_product.id,
      currency: 'EUR',
      interval: 'month'
    )
    plan = create(:plan, stripe_id: str_plan.id)
    plan.update_from_stripe_object!(str_plan)

    str_customer = Stripe::Customer.create(
      currency: 'EUR',
      source: str_helper.generate_card_token({})
    )
    
    user = create(:user, stripe_id: str_customer.id)
    user.update_from_stripe_object!(str_customer)

    str_sub = Stripe::Subscription.create(customer: str_customer, plan: str_plan.id)
    
    subscription = create(:subscription, user: user, subscription_type: 'stripe', stripe_id: str_sub.id, duration_months: nil)

    assert_nil subscription.status

    subscription.update_from_stripe_object!(str_sub)

    assert_equal 'active', subscription.status
    
    StripeMock.stop
  end
end