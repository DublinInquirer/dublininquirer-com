require 'test_helper'

class AuthorsControllerTest < ActionDispatch::IntegrationTest
  def test_show
    author = create(:author)
    get author_url(author.slug)
    assert_response :success
  end
end
