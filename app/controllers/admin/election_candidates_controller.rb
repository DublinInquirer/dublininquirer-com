class Admin::ElectionCandidatesController < Admin::ApplicationController
  def show
    @election_survey = ElectionSurvey.find_by(slug: params[:election_survey_id])
    @election_candidate = @election_survey.election_candidates.find_by(slug: params[:id])
    @election_survey_questions = @election_candidate.election_survey_questions.order('position asc')
  end
end
