FactoryBot.define do
  factory :contact_message do
    body { Faker::Books::Lovecraft.paragraphs }
    regarding { Faker::Name.name }
  end
end