require "application_system_test_case"

class ElectionSurveyTest < ApplicationSystemTestCase
  test 'browse by candidate' do
    survey = create(:election_survey)
    visit projects_election_survey_path(survey)
  end
end
