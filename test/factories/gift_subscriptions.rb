FactoryBot.define do
  factory :gift_subscription do
    plan

    giver_given_name { Faker::Name.first_name }
    giver_surname { Faker::Name.last_name }
    giver_email_address { Faker::Internet.email }

    recipient_given_name { Faker::Name.first_name }
    recipient_surname { Faker::Name.unique.last_name }
    recipient_email_address { Faker::Internet.unique.email }

    duration { 6 }
  end
end