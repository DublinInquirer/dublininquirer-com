class Projects::ElectionSurveysController < ApplicationController
  layout 'projects/election_surveys/layouts/elections'

  def show
    @survey = ElectionSurvey.find_by!(slug: params[:id])
    @areas = survey_cache(@survey, "areas") do
      @survey.area_objects
    end
    @parties = survey_cache(@survey, "parties") do
      @survey.party_objects
    end
    @candidates = survey_cache(@survey, "candidates") do
      @survey.candidate_objects
    end
  end

  def area
    @survey = ElectionSurvey.find_by!(slug: params[:id])

    @areas = survey_cache(@survey, "areas") do
      @survey.area_objects
    end
    @area = survey_cache(@survey, "areas/#{ params[:area_id] }") do
      @survey.find_area!(params[:area_id])
    end
    @candidates = survey_cache(@survey, "areas/#{ @area.slug }/candidates") do
      @survey.candidates_for_area(@area)
    end
    @nonresponders = survey_cache(@survey, "areas/#{ @area.slug }/nonresponders") do
      ElectionSurvey.filter_nonresponders(@survey, @candidates)
    end
    @questions = survey_cache(@survey, "questions") do
      @survey.question_objects
    end
  end

  def party
    @survey = ElectionSurvey.find_by!(slug: params[:id])

    @parties = survey_cache(@survey, "parties") do
      @survey.party_objects
    end
    @party = survey_cache(@survey, "parties/#{ params[:party_id] }") do
      @survey.find_party!(params[:party_id])
    end
    @candidates = survey_cache(@survey, "parties/#{ @party.slug }/candidates") do
      @survey.candidates_for_party(@party)
    end
    @nonresponders = survey_cache(@survey, "parties/#{ @party.slug }/nonresponders") do
      ElectionSurvey.filter_nonresponders(@survey, @candidates)
    end
    @questions = survey_cache(@survey, "questions") do
      @survey.question_objects
    end
  end

  def candidate
    @survey = ElectionSurvey.find_by!(slug: params[:id])

    @candidate = survey_cache(@survey, "candidates/#{ params[:candidate_id] }") do
      @survey.find_candidate!(params[:candidate_id])
    end
    @questions = survey_cache(@survey, "questions") do
      @survey.question_objects
    end
    @party = survey_cache(@survey, "parties/#{ @candidate.party }") do
      @survey.find_party!(@candidate.party)
    end
    @area = survey_cache(@survey, "areas/#{ @candidate.area }") do
      @survey.find_area!(@candidate.area)
    end
  end

  private

  def survey_cache(survey, key)
    Rails.cache.fetch([cache_key(survey), key].join('/')) { yield }
  end

  def cache_key(survey)
    @cache_key ||= [survey.id, survey.updated_at].join('-')
  end
end
