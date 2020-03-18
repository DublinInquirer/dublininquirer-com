class Projects::Neighbours::ServicesController < ApplicationController
  layout 'projects/neighbours/layouts/neighbours'

  def index
    @all_services = Rails.cache.fetch("/projects/neighbours/services", expires_in: (3..6).to_a.sample.minutes) do
      get_all_services
    end
    @areas = Rails.cache.fetch("/projects/neighbours/services/areas", expires_in: (3..6).to_a.sample.minutes) do
      @all_services.map { |s| s['areas'] }.flatten.uniq.sort
    end
    @categories = Rails.cache.fetch("/projects/neighbours/services/categories", expires_in: (3..6).to_a.sample.minutes) do
      @all_services.map { |s| s['categories'] }.flatten.uniq.sort
    end
    @scope = get_scope(params)
    @services = Rails.cache.fetch("/projects/neighbours/services/#{@scope[:area]}/#{@scope[:category]}", expires_in: (3..6).to_a.sample.minutes) do
      get_services(@scope)
    end
  end

  def new
    @errors = {}
    @service = {}
  end

  def create
    payload = {
      organisation: params[:organisation],
      description: params[:description],
      contact_name: params[:contact_name],
      contact_email: params[:contact_email],
      contact_number: params[:contact_number],
      contact_url: params[:contact_url],
      address_line_1: params[:address_line_1],
      address_line_2: params[:address_line_2],
      address_city: params[:address_city],
      address_county: params[:address_county],
      address_postcode: params[:address_postcode]
    }
    response = create_service(payload)
    if response.status.success?
      redirect_to [:projects, :neighbours, :services]
    else
      @errors = Oj.load(response.body)['errors']
      render :new
    end
  end

  private

  def endpoint
    Rails.env.production? ? 'https://helpers.civictech.ie' : 'http://0.0.0.0:5001'
  end

  def get_scope(params)
    {
      area: params[:area],
      category: params[:category]
    }
  end

  def get_all_services
    begin
      Oj.load(HTTP.get("#{ endpoint }/api/services.json").body)
    rescue HTTP::ConnectionError, OpenSSL::SSL::SSLError, NoMethodError
      []
    end
  end

  def get_services(scope)
    begin
      Oj.load(HTTP.get("#{ endpoint }/api/services.json", params: scope).body)
    rescue HTTP::ConnectionError, OpenSSL::SSL::SSLError, NoMethodError
      []
    end
  end

  def create_service(payload)
    HTTP.post("#{ endpoint }/api/services.json", json: {service: payload})
  end
end
