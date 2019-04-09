require 'test_helper'

class ContactMessageTest < ActiveSupport::TestCase
  test "is anonymous" do
    contact_message = build(:contact_message, full_name: nil, email_address: nil)
    assert contact_message.is_anonymous?

    contact_message = build(:contact_message, full_name: Faker::Name.name, email_address: nil)
    assert !contact_message.is_anonymous?
  end
end