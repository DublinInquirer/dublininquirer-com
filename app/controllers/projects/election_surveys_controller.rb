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
    @questions = @survey.question_objects
    @blue = true
  end

  def party
    @survey = ElectionSurvey.find_by!(slug: params[:id])
    @party = @survey.find_party(params[:party_id])
    @candidates = @survey.candidates_for_party(@party)
  end

  def candidate
    @survey = ElectionSurvey.find_by!(slug: params[:id])
    @candidate = @survey.find_candidate(params[:candidate_id])
    @party = @survey.find_party(@candidate.party)
    @area = @survey.find_area(@candidate.area)
    @responses = @survey.responses_for_candidate(@candidate)
  end

  def question
    @survey = ElectionSurvey.find_by!(slug: params[:id])
    @question = @survey.find_question(params[:question_id])
    @responses = @survey.responses_for_question(@question)
  end
end
