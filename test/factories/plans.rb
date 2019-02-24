FactoryBot.define do
  factory :plan do
    product
    sequence(:stripe_id)
  end
end
