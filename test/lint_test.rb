require 'test_helper'

class LintTest < ActiveSupport::TestCase
  self.use_transactional_tests = true

  test "FactoryBot definitions" do
    # create a customer
    cu = stub('customer')
    cu.stubs(:id).returns(Faker::Internet.unique.password)
    Stripe::Customer.stubs(:create).returns(cu)

    pl = stub('plan')
    pl.stubs(:product).returns(Faker::Internet.unique.password)
    pl.stubs(:amount).returns(600)
    pl.stubs(:interval).returns('month')
    pl.stubs(:interval_count).returns(1)
    Stripe::Plan.stubs(:retrieve).returns(pl)


    FactoryBot.lint
  end
end