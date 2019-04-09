class ContactMessage < ApplicationRecord
  validates :body, presence: true

  def is_anonymous?
    email_address.blank? && full_name.blank?
  end

  def contacter_name
    return full_name if full_name.present?
    return email_address if email_address.present?
    'Anonymous'
  end
end
