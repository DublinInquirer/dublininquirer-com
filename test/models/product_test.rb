require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  self.use_transactional_tests = true

  test "requires address?" do
    product = build(:product, name: 'Digital + Print subscription')
    digital = build(:product, name: 'Digital subscription')

    assert product.requires_address?
    assert_not digital.requires_address?
  end

  test "is_active?" do
    legacy = build(:product, name: 'Legacy print')
    product = build(:product, name: 'Digital + Print subscription')

    assert_not legacy.is_active?
    assert product.is_active?
  end

  test "is_print?" do
    legacy = build(:product, name: 'Legacy print')
    product = build(:product, name: 'Digital + Print subscription')
    digital = create(:product, name: 'Digital subscription')

    assert legacy.is_print?
    assert product.is_print?
    assert_not digital.is_print?
  end

  test "is_digital?" do
    product = build(:product)
  end

  test "base plan" do
    product = build(:product)
  end

  test "slugs" do
    product = create(:product, name: 'Digital subscription')

    assert (product.slug == 'digital')
    assert (Product.find_by_slug('digital') == product)
  end
end
