require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  self.use_transactional_tests = true

  test "slug generation, special characters" do
    article = create(:article)
    article.title = 'Council Briefs: The New City Park, Affordable Homes in O’Devaney, and More'
    article.save
    date_string = article.issue_date.strftime('%Y/%m/%d')

    assert_equal article.slug, "/#{ date_string }/council-briefs-the-new-city-park-affordable-homes-in-o-devaney-and-more"
  end
end
