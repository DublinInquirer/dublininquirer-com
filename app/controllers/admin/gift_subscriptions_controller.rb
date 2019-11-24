class Admin::GiftSubscriptionsController < Admin::ApplicationController
  def index
    @filter = {query: params[:query]}

    @gift_subscriptions = if @filter[:query].present?
      @sort = nil
      GiftSubscription.basic_search(@filter[:query]).page(params[:p]).per(25)
    else
      @sort = params[:sort].try(:downcase) || 'date'
      case @sort
      when 'date'
        GiftSubscription.by_date.page(params[:p]).per(25)
      else
        raise "Unsupported sort option: #{ @sort }"
      end
    end
  end

  def show
    @gift_subscription = GiftSubscription.find_by(redemption_code: params[:id])
  end
end
