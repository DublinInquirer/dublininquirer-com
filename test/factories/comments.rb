FactoryBot.define do
  factory :comment do
    user
    article
    wp_id { '3142' }
    content {"<p>Okay!</p>"}
    nickname {"Crea"}
    email_address {"crea@localhost"}
    status {"approved"}
    published_at { 1.hour.ago }
  end
end
