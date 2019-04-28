class Projects::ElectionSurveysController < ApplicationController
  layout 'elections'

  def show
    @survey = ElectionSurvey.find_by!(slug: params[:id])
    @areas = @survey.area_objects
    @parties = @survey.party_objects
    @candidates = @survey.candidate_objects
    @questions = @survey.question_objects
  end

  def area
    @survey = ElectionSurvey.find_by!(slug: params[:id])
    @area = @survey.find_area(params[:area_id])
  end

  def party
    @survey = ElectionSurvey.find_by!(slug: params[:id])
    @party = @survey.find_party(params[:party_id])
  end

  def candidate
    @survey = ElectionSurvey.find_by!(slug: params[:id])
    @candidate = @survey.find_candidate(params[:candidate_id])
    @responses = @survey.responses_for_candidate(@candidate)
  end

  def question
    @survey = ElectionSurvey.find_by!(slug: params[:id])
    @question = @survey.find_question(params[:question_id])
    @responses = @survey.responses_for_question(@question)
  end
end
