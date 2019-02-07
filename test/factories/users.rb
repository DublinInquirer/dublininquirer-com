FactoryBot.define do
  factory :user do
    given_name { "Zuzia" }
    surname { "Whelan" }
    email_address { "zuzia@localhost" }
    nickname { "zoosh" }
    password { 'secret123' }
  end
end
