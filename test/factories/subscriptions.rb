FactoryBot.define do
  factory :subscription do
    plan
    subscription_type { 'fixed' }
    duration_months { 6 }
  end
end
