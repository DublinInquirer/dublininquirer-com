class ProductsController < ApplicationController
  layout 'modal'
  before_action :require_no_subscription

  def index
    @digital = Product.find_by(name: 'Digital subscription')
    @print = Product.find_by(name: 'Digital + Print subscription')
  end

  def show
    @product = case params[:id].try(:downcase).try(:to_sym)
    when :digital
      Product.find_by_slug('digital')
    when :print
      Product.find_by_slug('print')
    else
      raise ActiveRecord::RecordNotFound
    end
    @plan = @product.base_plan
    @user = logged_in? ? current_user : User.new

    @user_data = { attributes: @user.attributes.slice('created_at', 'given_name','surname','email_address'), errors: @user.errors.messages }
  end

  private

  def require_no_subscription
    return unless logged_in?
    return unless current_user.subscriptions.active.any? or current_user.is_banned?

    redirect_to(:root)
  end
end
