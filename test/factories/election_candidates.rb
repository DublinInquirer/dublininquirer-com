FactoryBot.define do
  factory :election_candidate do
    election_survey
    full_name { Faker::Name.unique.name }
    area_name { Faker::Books::Lovecraft.location }
    party_name { Faker::Books::Lovecraft.deity }
  end
end