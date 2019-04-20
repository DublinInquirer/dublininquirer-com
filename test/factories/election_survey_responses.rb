FactoryBot.define do
  factory :election_survey_response do
    election_survey_question
    election_candidate
    body { Faker::Books::Lovecraft.paragraph }
  end
end
