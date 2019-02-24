FactoryBot.define do
  factory :user do
    given_name { Faker::Name.first_name }
    surname { Faker::Name.unique.last_name }
    email_address { Faker::Internet.unique.email }
    nickname { Faker::Internet.unique.username }
    password { Faker::Internet.password }
    sequence(:stripe_id)
  end
end
