require 'test_helper'

class ArticleAuthorTest < ActiveSupport::TestCase
  test "article author" do
    author_1 = create(:author)
    author_2 = create(:author)
    author_3 = create(:author)
    article = create(:article)
    article.update author_ids: [author_1.id, author_2.id]

    assert article.authors.include?(author_1)
    assert article.authors.include?(author_2)
    assert_not article.authors.include?(author_3)
  end
end
