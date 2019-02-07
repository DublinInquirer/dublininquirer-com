class Admin::SubscriptionsController < Admin::ApplicationController
  def index
    @filter = {query: params[:query]}

    @subscriptions = if @filter[:query].present?
      @sort = nil
      Subscription.
        joins(:user).
        advanced_search(
            {users: {given_name: @filter[:query], surname: @filter[:query], email_address: @filter[:query]}}, false
        ).
        page(params[:p]).
        per(25)
    else
      @sort = params[:sort].try(:downcase) || 'date'
      case @sort
      when 'date'
        Subscription.order('subscriptions.created_at desc').page(params[:p]).per(25)
      when 'name'
        Subscription.joins(:user).order('users.surname asc, users.given_name asc, users.email_address asc').page(params[:p]).per(25)
      else
        raise "Unsupported sort option: #{ @sort }"
      end
    end

    respond_to do |format|
      format.html
      format.csv do
        send_data @subscriptions.needs_shipping.to_csv, filename: "subscriptions-#{Date.today}.csv"
      end
    end
  end

  def change_product
    @subscription = Subscription.find(params[:id])
    maintain = (product_params[:maintain_price].present? && product_params[:maintain_price] == 'true') ? true : false
    @subscription.change_product_to!(product_params[:product_slug], maintain)
    redirect_to [:admin, @subscription]
  end

  def change_price
    @subscription = Subscription.find(params[:id])
    if request.put?
      @subscription.change_price_to!(price_params[:price])
      redirect_to [:admin, @subscription]
    end
  end

  def change_day
    @subscription = Subscription.find(params[:id])
    if request.put?
      @subscription.change_billing_date_to!(date_params[:date])
      redirect_to [:admin, @subscription]
    end
  end

  def cancel
    @subscription = Subscription.find(params[:id])
    @subscription.toggle_cancellation!
    redirect_to [:admin, @subscription]
  end

  def show
    @subscription = Subscription.find(params[:id])
    @user = @subscription.user
  end

  def new # nested
    @user = User.find(params[:user_id])
    @subscription = @user.subscriptions.new(subscription_type: params[:subscription_type], duration_months: 12)
  end

  def create # nested
    @user = User.find(params[:user_id])
    @subscription = @user.subscriptions.new(fixed_params)
    if @subscription.save
      redirect_to [:admin, @subscription]
    else
      render :new
    end
  end

  def edit
    @subscription = Subscription.find(params[:id])
  end

  def update
    @subscription = Subscription.find(params[:id])
    if @subscription.update(fixed_params)
      redirect_to [:admin, @subscription]
    else
      render :edit
    end
  end

  private

  def fixed_params
    params.require(:subscription).permit(:plan_id, :duration_months, :subscription_type)
  end

  def import_params
    params.permit(:file)
  end

  def price_params
    params.permit(:price)
  end

  def product_params
    params.permit(:product_slug, :maintain_price)
  end

  def date_params
    params.permit(:date)
  end
end
