require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  self.use_transactional_tests = true

  test "slug generation, special characters" do
    article = create(:article)
    article.title = 'Council Briefs: The New City Park, Affordable Homes in O’Devaney, and More'
    article.issue = Issue.create!(issue_date: Date.new(2019,1,23))
    article.save

    assert_equal article.slug, '/2019/01/23/council-briefs-the-new-city-park-affordable-homes-in-o-devaney-and-more'
  end
end
