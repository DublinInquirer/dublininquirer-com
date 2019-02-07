class Admin::LandingPagesController < Admin::ApplicationController
  def index
    @sort = params[:sort].try(:downcase) || 'name'
    @landing_pages = case @sort
    when 'name'
      LandingPage.order('name desc').page(params[:p]).per(25)
    else
      raise "Unsupported sort option: #{ @sort }"
    end
  end

  def show
    @landing_page = LandingPage.find_by(slug: params[:id])
  end

  def new
    @landing_page = LandingPage.new
  end

  def create
    @landing_page = LandingPage.new(landing_page_params)
    if @landing_page.save
      redirect_to [:admin, @landing_page]
    else
      render :new
    end
  end

  def edit
    @landing_page = LandingPage.find_by(slug: params[:id])
  end

  def update
    @landing_page = LandingPage.find_by(slug: params[:id])
    if @landing_page.update(landing_page_params)
      redirect_to [:admin, @landing_page]
    else
      render :edit
    end
  end

  private

  def landing_page_params
    params.require(:landing_page).permit(:name, :slug)
  end
end
