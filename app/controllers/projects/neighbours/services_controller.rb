class Projects::Neighbours::ServicesController < ApplicationController
  layout 'projects/neighbours/layouts/neighbours'

  def index
    @services = get_services
  end

  def new

  end

  def create

  end

  private

  def get_services
    url = Rails.env.production? ? "https://helpers.civictech.ie/api/services.json" : "http://0.0.0.0:5001/api/services.json"
    begin
      Oj.load(HTTP.get(url).body)
    rescue HTTP::ConnectionError, OpenSSL::SSL::SSLError, NoMethodError
      []
    end
  end
end
