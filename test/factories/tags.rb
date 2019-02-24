FactoryBot.define do
  factory :tag do
    name { Faker::Internet.unique.slug }
  end
end
