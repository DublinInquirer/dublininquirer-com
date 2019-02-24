FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
  end
end
