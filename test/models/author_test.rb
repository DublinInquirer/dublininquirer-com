require 'test_helper'

class AuthorTest < ActiveSupport::TestCase
  self.use_transactional_tests = true

  test "slug generation" do
    author = create(:author, full_name: 'Lois Whelan')
    assert author.slug == 'lois-whelan'
  end

  test "slug collision-avoiding" do
    author1 = create(:author, full_name: 'Lois Whelan')
    author2 = create(:author, full_name: 'Lois Whelan')
    assert author1.slug == 'lois-whelan'
    assert author2.slug == 'lois-whelan-2'
  end
end
