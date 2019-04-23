require 'test_helper'

class ElectionSurveysControllerTest < ActionDispatch::IntegrationTest
  test "show" do
    survey = create(:election_survey)
    question = create(:election_survey_question, election_survey: survey)
    candidate = create(:election_candidate, election_survey: survey)
    response = create(:election_survey_response,
      election_survey_question: question,
      election_candidate: candidate)
    get projects_election_survey_path(survey)
    
    assert_response :success
  end
end
