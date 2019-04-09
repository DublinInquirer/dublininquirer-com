require 'test_helper'

class ContactMessageTest < ActiveSupport::TestCase
  test "marked as spam" do
    contact_message = build(:contact_message, user: nil)
    assert contact_message.is_anonymous?
  end
end