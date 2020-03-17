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
    begin
      Oj.load(HTTP.get("https://helpers.civictech.ie/services.json").body)
    rescue HTTP::ConnectionError, OpenSSL::SSL::SSLError, NoMethodError
      []
    end
  end
end
