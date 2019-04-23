require "application_system_test_case"

class ElectionSurveyTest < ApplicationSystemTestCase
  test 'browse by candidate' do
    survey = create(:election_survey)
    candidate = create(:election_candidate,
      election_survey: survey,
      full_name: 'Alison Lurie')
    response = create(:election_survey_response,
      election_candidate: candidate)

    visit projects_election_survey_path(survey)

    assert_selector 'a', text: 'Alison Lurie'

    click_link 'Alison Lurie', match: :first

    assert_content candidate.area_name
    assert_content response.body
  end

  test 'browse by area' do
    survey = create(:election_survey)
    candidate = create(:election_candidate,
      election_survey: survey,
      area_name: 'The Liberties')
    response = create(:election_survey_response,
      election_candidate: candidate)

    visit projects_election_survey_path(survey)

    assert_selector 'a', text: 'The Liberties'

    click_link 'The Liberties', match: :first

    assert_content candidate.full_name
    assert_content response.body
  end

  test 'browse by party' do
    survey = create(:election_survey)
    candidate = create(:election_candidate,
      election_survey: survey,
      party_name: 'Podemos')
    response = create(:election_survey_response,
      election_candidate: candidate)

    visit projects_election_survey_path(survey)

    assert_selector 'a', text: 'Podemos'

    click_link 'Podemos', match: :first

    assert_content candidate.area_name
    assert_content response.body
  end
end
