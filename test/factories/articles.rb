FactoryBot.define do
  factory :article do
    issue

    title {  Faker::Book.unique.title }
    excerpt { Faker::Books::Lovecraft.sentences }
    content { Faker::Books::Lovecraft.paragraphs }
    template { 'standard' }
    category { 'city-desk' }
  end
end
