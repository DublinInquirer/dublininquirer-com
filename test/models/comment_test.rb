require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  # test "is a child" do
  #   parent_comment = create(:comment)
  #   comment = build(:comment, parent: parent_comment)
  #   assert comment.child?

  #   comment.parent = nil
  #   assert_not comment.child?
  # end

  test "marked as spam" do
    comment = build(:comment, marked_as_spam: true)
    assert comment.is_spam?

    comment = build(:comment, marked_as_spam: false)
    assert_not comment.is_spam?
  end
end