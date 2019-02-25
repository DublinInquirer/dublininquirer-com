FactoryBot.define do
  factory :article do
    issue

    title {  Faker::Book.unique.title }
    excerpt { Faker::Books::Lovecraft.sentence(2) }
    content { Faker::Books::Lovecraft.paragraph(2) }
    template { 'standard' }
    category { 'city-desk' }
  end
end
