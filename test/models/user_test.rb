require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "name parsing" do
    user = create(:user, full_name: 'Lois Whelan')
    assert_equal 'Lois', user.given_name
    assert_equal 'Whelan', user.surname
    assert_equal 'Lois Whelan', user.full_name
  end

  test "full name generation" do
    user = create(:user, given_name: 'Lois', surname: 'Whelan')
    assert_equal 'Lois Whelan', user.full_name
  end

  test "delete completely" do
    # delete_completely!
    # schedule for deletion
  end

  test "banning" do
    # ban!
    # is_banned?
  end

  test "update from stripe" do
    # 
  end

  test "can comment" do
    # can_comment?
  end
  
  test "has address" do
    leo = build(:user, address_line_1: "7 Eccles Street", city: "Dublin")
    molly = build(:user, address_line_1: nil, address_line_2: nil, city: nil, county: nil, post_code: nil, country: nil, country_code: nil)
    assert leo.has_address?
    assert_not molly.has_address?
  end

  test "subscriber?" do
  end

  test "needs source" do
  end

  test "delinquent" do
  end

  test "lapsed" do
  end
  
  test "subscription" do
  end

  test "needs to confirm plan" do
  end
end