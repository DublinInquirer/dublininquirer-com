class SubscriptionsController < ApplicationController
  before_action :require_login, only: [:upgrade, :thanks]
  layout 'modal', only: [:upgrade, :create, :thanks]

  def upgrade
    @subscription = current_user.subscription
    if request.put?
      case params[:id].downcase.to_sym
      when :friend
        @subscription.change_price_to!(20_00)
      when :patron
        @subscription.change_price_to!(50_00)
      end

      redirect_to [:thanks, :subscriptions]
    end
  end

  def thanks
    @subscription = current_user.subscription
  end

  private

  def subscription_params
    params.require(:subscription).permit(:email_address, :given_name, :surname, :plan_id, :address_line_1, :address_line_2, :city, :county, :post_code, :country_code, :password, :landing_page_slug)
  end
end
