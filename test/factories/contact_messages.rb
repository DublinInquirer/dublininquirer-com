FactoryBot.define do
  factory :contact_message do
    body { Faker::Books::Lovecraft.paragraph(2) }
    regarding { Faker::Name.name }
  end
end