FactoryBot.define do
  factory :issue do
    sequence(:issue_date) { |n| n.weeks.ago.beginning_of_week.advance(days: 2) }
  end
end
