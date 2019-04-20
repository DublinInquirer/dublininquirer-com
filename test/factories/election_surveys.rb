FactoryBot.define do
  factory :election_survey do
    election_type { %w(local general european).sample }
    sequence :election_year do 
      |n| (Date.current - n.to_i.years).year
    end
  end
end