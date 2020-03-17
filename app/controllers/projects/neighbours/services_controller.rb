class Projects::Neighbours::ServicesController < ApplicationController
  layout 'projects/neighbours/layouts/neighbours'

  def index
    @services = get_services
    @areas = @services.map { |s| s['areas'] }.flatten.uniq.sort
    @categories = @services.map { |s| s['categories'] }.flatten.uniq.sort
    @scope = get_scope(params)
  end

  def new
  end

  def create
    raise params.inspect
  end

  private

  def get_scope(params)
    {
      area: params[:area],
      category: params[:category]
    }
  end

  def get_services
    url = Rails.env.production? ? "https://helpers.civictech.ie/api/services.json" : "http://0.0.0.0:5001/api/services.json"
    begin
      Oj.load(HTTP.get(url).body)
    rescue HTTP::ConnectionError, OpenSSL::SSL::SSLError, NoMethodError
      []
    end
  end
end
