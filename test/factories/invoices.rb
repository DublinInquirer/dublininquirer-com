FactoryBot.define do
  factory :invoice do
    sequence(:stripe_id)
  end
end
