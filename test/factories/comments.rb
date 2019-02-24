FactoryBot.define do
  factory :comment do
    user
    article
    content { Faker::Books::Lovecraft.paragraph(2) }
    nickname { Faker::Name.name }
    email_address { Faker::Internet.email }
  end
end