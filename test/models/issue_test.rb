require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  test "standard articles" do
    issue = create(:issue)
    article_standard = create(:article, issue: issue, category: 'city-desk')
    article_nonstandard = create(:article, issue: issue, category: 'cartoon')
    assert_equal issue.standard_articles.count, 1
  end

  test "featured_article" do
    issue = create(:issue)
    article_first = create(:article, issue: issue, category: 'city-desk', position: 1)
    article_second = create(:article, issue: issue, category: 'city-desk', position: 2)
    assert_equal issue.featured_article, article_first
  end
end