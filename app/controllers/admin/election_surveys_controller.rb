class Admin::ElectionSurveysController < Admin::ApplicationController
  def index
    @filter = {}
    @sort = nil
    @election_surveys = ElectionSurvey.order('election_year desc').page(params[:p]).per(25)
  end

  def show
    @election_survey = ElectionSurvey.find_by(slug: params[:id])
  end

  def new
    @election_survey = ElectionSurvey.new(election_year: Date.current.year)
  end

  def create
    @election_survey = ElectionSurvey.new(election_survey_params)
    if @election_survey.save
      redirect_to [:admin, @election_survey]
    else
      render :new
    end
  end

  def edit
    @election_survey = ElectionSurvey.find_by(slug: params[:id])
  end

  def update
    @election_survey = ElectionSurvey.find_by(slug: params[:id])
    if @election_survey.update(election_survey_params)
      redirect_to [:admin, @election_survey]
    else
      render :edit
    end
  end

  private

  def election_survey_params
    params.require(:election_survey).permit(:election_type, :election_year)
  end
end