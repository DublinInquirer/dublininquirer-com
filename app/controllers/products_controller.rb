class ProductsController < ApplicationController
  layout 'modal'

  def index
    if logged_in? and current_user.subscriptions.active.any?
      redirect_to(:root) && return
    end

    @digital = Product.find_by(name: 'Digital subscription')
    @print = Product.find_by(name: 'Digital + Print subscription')
  end

  def show
    if logged_in? and current_user.subscriptions.active.any?
      redirect_to(:root) && return
    end

    @products = Product.active
    @plans = Plan.where(product: @products, interval: 'month')

    @plan = case params[:id].try(:downcase).try(:to_sym)
    when :digital
      Product.find_by_slug('digital').base_plan
    when :print
      Product.find_by_slug('print').base_plan
    when :friend
      Product.find_by_slug('print').plans.find_or_create_by(amount: 20_00, interval: 'month')
    when :patron
      Product.find_by_slug('print').plans.find_or_create_by(amount: 50_00, interval: 'month')
    else
      raise ActiveRecord::RecordNotFound
    end

    @product = @plan.product

    @subscription = if logged_in?
      Subscription.new(
        user: current_user,
        plan: @plan,
        given_name: current_user.given_name,
        surname: current_user.surname)
    else
      Subscription.new(plan: @plan)
    end

    @landing_page = if session[:landing_page]
      LandingPage.find_by(slug: session[:landing_page])
    else
      nil
    end
    if @landing_page
      @subscription.trial_ends_at = (Time.zone.now + 1.month)
      @subscription.landing_page_slug = @landing_page.slug
    end
  end
end
