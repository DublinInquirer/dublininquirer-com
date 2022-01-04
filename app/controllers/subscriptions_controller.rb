class SubscriptionsController < ApplicationController
  before_action :require_login, only: [:upgrade, :thanks]
  before_action :require_no_subscription, only: [:create]
  layout 'modal', only: [:upgrade, :create, :address, :thanks]

  def create
    @user = logged_in? ? current_user : User.new(subscribed_weekly: true)
    @user.assign_attributes(user_params)

    # if the user is invalid, return here
    validate_user(@user) { return }

    # if the card is invalid, return here
    setup_user_with_card(@user, payment_params) { return }
    @subscription = setup_subscription(@user, subscription_params)
    auto_login(@user) # login regardless as the user has been created/saved
    @user.send_welcome! # welcome the user, even if they're possibly incomplete

    case @subscription.status.to_sym # TODO: 3??
    when :incomplete # 2
      payment_intent = @subscription.latest_invoice.payment_intent
      add_source_to_payment_intent(payment_intent, @user)
      render json: {status: :incomplete, invoice: {
        status: payment_intent.status,
        payment_intent_client_id: payment_intent.id,
        payment_intent_client_secret: payment_intent.client_secret
      }}
    when :active # 1
      render json: {status: :ok}
    end
  end

  def confirm # TODO: pls refactor me
    payment_intent_id = params['payment_intent_id']
    begin
      if payment_intent_id
        intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
        invoice = Stripe::Invoice.retrieve(intent.invoice)
        
        if intent.status != 'succeeded'
          intent = Stripe::PaymentIntent.confirm(payment_intent_id)
        end
        
        subscription = Subscription.find_by(stripe_id: invoice.lines.data[0]["subscription"])
        subscription.status = "active"
        subscription.save
      end

      if intent && (intent.status == 'succeeded')
        render(json: {
          status: :ok
        }) and return # exit
      else
        render(json: {
          status: :error,
          payment: {error: 'No payment id'}
        }) and return # exit
      end
    rescue Stripe::CardError => e
      render(json: {
        status: :error,
        payment: {error: e.message}
      }) and return # exit
    end
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

  def address
    @user = current_user

    case request.request_method.downcase.to_sym
    when :get
      render :address
    when :put
      if @user.update(address_params)
        redirect_to [:thanks, :subscriptions]
      else
        render :address
      end
    end
  end

  def thanks
    @subscription = current_user.subscription
  end

  private

  # valid? or return attributes + errors
  def validate_user(user)
    if !user.valid?
      render(json: {status: :error, user: user_data(user)}) and yield
    end
  end

  # save user
  def setup_user_with_card(user, payment_params)
    begin
      if user.stripe_id.present? # if customer exists, add a source
        user.add_stripe_source(payment_params[:stripe_token])
      else # if no customer exists, add the token to the user
        user.stripe_token = payment_params[:stripe_token]
        user.save
      end
    rescue Stripe::CardError => e
      render(json: {
          status: :error,
          user: user_data(user),
          payment: {error: e.message}
        }) and yield
    end
  end

  # set up subscription or return attributes + errors
  def setup_subscription(user, subscription_params)
    plan = Plan.find_by!(stripe_id: subscription_params[:plan_id])
    if user.subscriptions.where(status: 'incomplete', plan_id: plan.id).any?
      user.subscriptions.where(status: 'incomplete', plan_id: plan.id).take
    else
      Subscription.create!(plan: plan, user: user)
    end
  end

  def add_source_to_payment_intent(payment_intent, user)
    return unless (payment_intent.status == 'requires_payment_method')
    payment_intent.payment_method = user.stripe_customer.default_source
    payment_intent.save
  end

  def require_no_subscription
    return unless logged_in?
    return unless current_user.subscriptions.active.any? or current_user.is_banned?

    redirect_to(:root)
  end

  def user_data(user)
    {
      attributes: user.attributes.slice('created_at', 'given_name','surname','email_address'),
      errors: user.errors.messages
    }
  end

  def user_params
    params.require(:user).permit(:email_address, :given_name, :surname,:address_line_1, :address_line_2, :city, :county, :post_code, :country_code, :password)
  end

  def payment_params
    params.require(:payment).permit(:stripe_token)
  end

  def subscription_params
    params.require(:subscription).permit(:plan_id)
  end

  def address_params
    params.require(:user).permit(:address_line_1, :address_line_2, :city, :county, :post_code, :country_code)
  end
end
