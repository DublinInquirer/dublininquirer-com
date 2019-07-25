FactoryBot.define do
  factory :user_note do
    user
    body { "Nice note" }
  end
end
