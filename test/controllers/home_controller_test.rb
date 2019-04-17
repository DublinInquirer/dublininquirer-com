require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  def setup
  stub_request(:get, "https://counciltracker.ie/motions.json").
    to_return(status: 200, body: "")
  end

  def test_show
    get root_url
    assert_response :success
  end

  def test_contact
    get contact_url
    assert_response :success
  end

  def test_imprint
    get imprint_url
    assert_response :success
  end
end
