require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test "marked as spam" do
    comment = build(:comment, marked_as_spam: true)
    assert comment.is_spam?

    comment = build(:comment, marked_as_spam: false)
    assert_not comment.is_spam?
  end
end