FactoryBot.define do
  factory :election_survey_question do
    election_survey
    slug { Faker::Books::Lovecraft.words.join.parameterize }
    body { Faker::Books::Lovecraft.sentence }
  end
end
