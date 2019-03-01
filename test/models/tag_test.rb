require 'test_helper'

class TagTest < ActiveSupport::TestCase
  test "merge" do
    tag1 = create(:tag, name: 'Fish')
    tag2 = create(:tag, name: 'Wildlife')

    article1 = create(:article, tag_ids: [tag1.id])

    assert tag1.articles.include?(article1)

    tag1.merge_into!(tag2)

    assert tag2.articles.include?(article1)
  end
end