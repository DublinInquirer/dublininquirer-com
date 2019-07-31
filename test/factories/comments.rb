FactoryBot.define do
  factory :comment do
    user
    article
    content { Faker::Books::Lovecraft.paragraphs }
    nickname { Faker::Name.name }
    email_address { Faker::Internet.email }
  end
end