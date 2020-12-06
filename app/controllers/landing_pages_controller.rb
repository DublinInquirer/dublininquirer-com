class LandingPagesController < ApplicationController
  layout 'landing'

  def show
    @landing_page = LandingPage.find_by(slug: params[:id].try(:downcase))
    
    if !@landing_page
      raise ActiveRecord::RecordNotFound
    end
    
    session[:landing_page] = @landing_page.slug

    if @landing_page.template.present?
      render @landing_page.template
    else
      redirect_to product_path(id: 'digital')
    end
  end
end
