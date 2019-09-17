class SubscriptionsController < ApplicationController
  before_action :require_login, only: [:upgrade, :thanks]
  layout 'modal', only: [:upgrade, :create, :thanks]

  def create # not for gifts
    if logged_in? and (current_user.subscriptions.active.any? or current_user.is_banned?)
      redirect_to(:user) && return
    end

    @subscription = Subscription.new(subscription_params)

    if logged_in?
      @user = current_user
      @subscription.email_address = @user.email_address
      @user.assign_attributes(
        given_name: @subscription.given_name,
        surname: @subscription.surname,
        stripe_token: params[:stripe_token],
        sources_count: 1
      )
    else
      @user = User.new(
        email_address: @subscription.email_address,
        given_name: @subscription.given_name,
        surname: @subscription.surname,
        password: @subscription.password,
        stripe_token: params[:stripe_token],
        set_password_at: Time.zone.now,
        sources_count: 1
      )
    end

    if @subscription.requires_address?
      @subscription.landing_page_slug = nil
      @user.address_line_1 = @subscription.address_line_1
      @user.address_line_2 = @subscription.address_line_2
      @user.city = @subscription.city
      @user.county = @subscription.county
      @user.post_code = @subscription.post_code
      @user.country_code = @subscription.country_code
    end

    @subscription.user = @user

    if @user.save && @subscription.save
      @user.send_welcome!
      auto_login(@user, true) unless logged_in?
      latest_invoice = @subscription.latest_invoice['payment_intent']
      respond_to do |format|
        format.html { redirect_to :thanks_subscriptions }
        format.js do
          render json: {
            status: latest_invoice['status'],
            payment_intent_client_id: latest_invoice['id'],
            payment_intent_client_secret: latest_invoice['client_secret']
          }
        end
      end
    else
      @products = Product.active
      @plans = Plan.where(product: @products, interval: 'month')

      @plan = Plan.find(subscription_params[:plan_id])
      @product = @plan.product
      render 'products/show'
    end
  end

  def confirm
    begin
      if params['paymentIntentId'].present?
        # subscription = Subscription.find_by_
        intent = Stripe::PaymentIntent.retrieve(params['paymentIntentId'])
        invoice = Stripe::Invoice.retrieve(intent.invoice)
        unless intent.status == 'succeeded'
          intent = Stripe::PaymentIntent.confirm(params['paymentIntentId'])
        end
        subscription_id = invoice.lines.data[0]["subscription"]
        subscription = Subscription.find_by_stripe_id(subscription_id)
        subscription.status = "active"
        subscription.save
        if intent.status == 'succeeded'
          return redirect_to :thanks_subscriptions 
        else 
          return render :status => 400
        end  
      else
        return render :status => 400
      end
    rescue Stripe::CardError => e
      # Display error on client
      flash[:alert] = e.message
      return render :status => 400
    end
    return redirect_to :thanks_subscriptions
  end

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
