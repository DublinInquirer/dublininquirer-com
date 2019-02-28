require 'test_helper'

class VatCalculatorTest < ActiveSupport::TestCase
  test "rate for 2018" do
    assert_equal VatCalculator.rate_for(:digital, 2018), 0.23
  end

  test "rate for 2019, onward" do
    assert_equal VatCalculator.rate_for(:digital, 2019), 0.09
    assert_equal VatCalculator.rate_for(:digital, 2020), 0.09
  end

  # test "net from gross, 2018" do
  # end

  # def "vat from gross, 2018" do
  # end

  # test "net from gross, 2019" do
  # end

  # def "vat from gross, 2019" do
  # end
end
