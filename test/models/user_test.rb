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
end
