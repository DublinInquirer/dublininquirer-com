require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  self.use_transactional_tests = true

  test "slug generation, special characters" do
    article = build(:article, title: 'Council Briefs: The New City Park, Affordable Homes in O’Devaney, and More')
    date_string = article.issue_date.strftime('%Y/%m/%d')

    assert_equal article.path, "/#{ date_string }/council-briefs-the-new-city-park-affordable-homes-in-o-devaney-and-more"
  end

  test "remember past slugs" do
    article = create(:article, title: 'Council Briefs: The New City Park, Affordable Homes in O’Devaney, and More')
    article.title = 'The New City Park, Affordable Homes in O’Devaney, and More'
    article.save!

    date_string = article.issue_date.strftime('%Y/%m/%d')

    assert_equal article.path, "/#{ date_string }/the-new-city-park-affordable-homes-in-o-devaney-and-more"
    assert article.former_slugs.include?("/#{ date_string }/council-briefs-the-new-city-park-affordable-homes-in-o-devaney-and-more")
  end

  test "from the same issue" do
    issue = create(:issue)
    article1 = create(:article, issue: issue)
    article2 = create(:article, issue: issue)

    assert article1.from_the_same_issue.include?(article2)
  end
end