class UserNote < ApplicationRecord
  belongs_to :user
  validates :body, presence: true

  scope :chronologically, -> { order('created_at asc') }
  scope :reverse_chronologically, -> { order('created_at desc') }
end
