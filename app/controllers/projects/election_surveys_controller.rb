class Projects::ElectionSurveysController < ApplicationController
  def show
    @survey = ElectionSurvey.find_by!(slug: params[:id])
    @candidates = @survey.election_candidates
    @areas = @candidates.pluck(:area_name).uniq
    @parties = @candidates.pluck(:party_name).uniq
  end
end
