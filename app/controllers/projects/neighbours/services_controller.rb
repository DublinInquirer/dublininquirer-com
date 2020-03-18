class Projects::Neighbours::ServicesController < ApplicationController
  layout 'projects/neighbours/layouts/neighbours'

  def index
    @services = get_services
    @areas = @services.map { |s| s['areas'] }.flatten.uniq.sort
    @categories = @services.map { |s| s['categories'] }.flatten.uniq.sort
    @scope = get_scope(params)
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

  def get_scope(params)
    {
      area: params[:area],
      category: params[:category]
    }
  end

  def get_services
    begin
      Oj.load(HTTP.get("https://helpers.civictech.ie/api/services.json").body)
    rescue HTTP::ConnectionError, OpenSSL::SSL::SSLError, NoMethodError
      []
    end
  end

  def create_service(payload)
    HTTP.post('http://0.0.0.0:5001/api/services.json', json: {service: payload})
  end
end
