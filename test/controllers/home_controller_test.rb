require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    stub_request(:get, "https://www.counciltracker.ie/motions.json").
      to_return(status: 200, body: "{}")
  end

  test "show" do
    get root_url
    assert_response :success
  end

  test "contact" do
    get contact_url
    assert_response :success
  end

  test "imprint" do
    get imprint_url
    assert_response :success
  end
end
