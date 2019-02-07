FactoryBot.define do
  factory :gift_subscription do
    subscription nil
    giver_given_name {"MyText"}
    giver_surname {"MyText"}
    giver_email_address {"MyText"}
    first_address_line_1 {"MyText"}
    first_address_line_2 {"MyText"}
    first_city {"MyText"}
    first_county {"MyText"}
    first_country_code {"MyText"}
    product {"MyText"}
    notes {"MyText"}
  end
end
