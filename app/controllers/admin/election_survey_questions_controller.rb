class Admin::ElectionSurveyQuestionsController < Admin::ApplicationController
  def show
    @election_survey = ElectionSurvey.find_by(slug: params[:election_survey_id])
    @election_survey_question = @election_survey.election_survey_questions.find_by(slug: params[:id])
    @election_survey_responses = @election_survey_question.election_survey_responses
  end
end
