class Projects::ElectionSurveysController < ApplicationController
  layout 'elections'

  def show
    @survey = ElectionSurvey.find_by!(slug: params[:id])
    @areas = @survey.area_objects
    @parties = @survey.party_objects
    @candidates = @survey.candidate_objects
    @blue = true
  end

  def area
    @survey = ElectionSurvey.find_by!(slug: params[:id])
    @areas = @survey.area_objects
    @area = @survey.find_area(params[:area_id])
    @candidates = @survey.candidates_for_area(@area)
    @nonresponders = ElectionSurvey.filter_nonresponders(@survey, @candidates)
    @questions = @survey.question_objects
    @blue = true
  end

  def party
    @survey = ElectionSurvey.find_by!(slug: params[:id])
    @parties = @survey.party_objects
    @party = @survey.find_party(params[:party_id])
    @candidates = @survey.candidates_for_party(@party)
    @questions = @survey.question_objects
    @blue = true
  end

  def candidate
    @survey = ElectionSurvey.find_by!(slug: params[:id])
    @candidate = @survey.find_candidate(params[:candidate_id])
    @questions = @survey.question_objects
    @party = @survey.find_party(@candidate.party)
    @area = @survey.find_area(@candidate.area)
    @blue = true
  end
end
