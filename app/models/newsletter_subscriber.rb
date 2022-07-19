class NewsletterSubscriber < ApplicationRecord
  validates :mailchimp_id, uniqueness: true, presence: true

  scope :subscribed, -> { where(status: "subscribed") }
end
