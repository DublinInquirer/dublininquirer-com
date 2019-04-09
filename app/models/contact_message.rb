class ContactMessage < ApplicationRecord
  belongs_to :user, optional: true # optional implies anonymous

  validates :body, presence: true

  def is_anonymous?
    !user.present?
  end

  def user_name
    return 'Anonymous' if is_anonymous?
    return user.full_name if user.full_name.present?
    return user.email_address
  end
end
