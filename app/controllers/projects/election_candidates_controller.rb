class Projects::ElectionCandidatesController < ApplicationController
  def parties
    @party_name = ElectionCandidate::PARTIES[params[:id]]
    @survey = ElectionSurvey.find_by!(slug: params[:election_survey_id])
    @candidates = @survey.election_candidates.where(party_name: @party_name)
  end

  def areas
    @area_name = ElectionCandidate::AREAS[params[:id]]
    @survey = ElectionSurvey.find_by!(slug: params[:election_survey_id])
    @candidates = @survey.election_candidates.where(area_name: @area_name)
  end

  def show
    @survey = ElectionSurvey.find_by!(slug: params[:election_survey_id])
    @candidate = @survey.election_candidates.find_by!(slug: params[:id])
    @questions = @survey.election_survey_questions
  end
end
