require 'test_helper'

class AuthorTest < ActiveSupport::TestCase
  self.use_transactional_tests = true

  test "slug generation" do
    author = create(:author)
    author.full_name = 'Lois Whelan'
    author.save

    assert author.slug == 'lois-whelan'
  end
end
