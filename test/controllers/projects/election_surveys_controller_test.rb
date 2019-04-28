require 'test_helper'

class ElectionSurveysControllerTest < ActionDispatch::IntegrationTest
  test "show" do
    survey = create(:election_survey)
    get projects_election_survey_path(survey)
    
    assert_response :success
  end
end
