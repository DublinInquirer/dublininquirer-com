class Projects::ElectionCandidatesController < ApplicationController
  def show
    @survey = ElectionSurvey.find_by!(slug: params[:election_survey_id])
    @candidate = @survey.election_candidates.find_by!(slug: params[:id])
    @questions = @survey.election_survey_questions
  end
end
