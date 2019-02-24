FactoryBot.define do
  factory :author do
    full_name { Faker::Name.unique.name }
    bio { "#{ Faker::Name.unique.name } is a reporter" }
  end
end
