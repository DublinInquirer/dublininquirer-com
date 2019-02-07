FactoryBot.define do
  factory :article do
    issue

    title { "In Rialto, Local Residents Feel Overwhelmed By Outsiders Parking" }
    slug { "2018/07/24/in-rialto-local-residents-feel-overwhelmed-by-outsiders-parking" }
    excerpt { "A ballot to see if a pay-and-display should be brought in on streets in the area hasn’t gone too smoothly" }
    content { "<p>Meanwhile, a ballot to see if a pay-and-display should be brought in on streets in the area hasn’t gone <em>too smoothly</em>.</p>" }
    text { "Meanwhile, a ballot to see if a pay-and-display should be brought in on streets in the area hasn’t gone too smoothly." }
    tag_ids { [] }
    categories { ['citydesk'] }
    author_ids { [] }
    status { 'published' }
    wp_id { nil }
    template { 'standard' }
    category { 'city-desk' }

    after(:create) do |article|
      article.author_ids << Author.find_or_create_by!(full_name: 'Sam Tranum')
    end
  end
end
