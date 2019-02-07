class LandingPagesController < ApplicationController
  def show
    @landing_page = LandingPage.find_by!(slug: params[:id].try(:downcase))
    session[:landing_page] = @landing_page.slug

    redirect_to product_path(id: 'digital')
  end
end
