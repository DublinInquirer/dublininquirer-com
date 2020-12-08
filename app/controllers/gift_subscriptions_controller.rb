class GiftSubscriptionsController < ApplicationController
  include ApplicationHelper
  layout 'modal'

  def index
    if is_christmastime?
      render :christmas
    else
      render :index
    end
  end

  def show
    duration = duration_from_id(params[:id])
    product = Product.active.find_by_slug(slug_from_id(params[:id]))

    @gift_subscription = if logged_in?
      GiftSubscription.new(giver_given_name: current_user.given_name, giver_surname: current_user.surname, giver_email_address: current_user.email_address, plan: product.base_plan, duration: duration)
    else
      GiftSubscription.new(plan: product.base_plan, duration: duration)
    end

    @gift_subscription_data = gift_subscription_data(@gift_subscription)
  end
  
  def create # validates sub + creates the intent
    @gift_subscription = GiftSubscription.new(gift_subscription_params)

    validate_gift_subscription(@gift_subscription) { return }
    @payment_intent = setup_payment_intent(@gift_subscription)

    render json: {status: :ok, gift_subscription: gift_subscription_data(@gift_subscription), payment_intent: @payment_intent.to_hash.slice(:status, :client_secret)}
  end

  def confirm # TODO this seems very janky
    @gift_subscription = GiftSubscription.new(gift_subscription_params)

    # TODO: the gift sub itself should handle all this
    @subscription = @gift_subscription.subscription

    @user = if User.where(email_address: @subscription.try(:email_address)).any?
      User.find_by(email_address: @subscription.try(:email_address))
    else
      User.new(
        email_address: @subscription.try(:email_address),
        given_name: @subscription.try(:given_name),
        surname: @subscription.try(:surname),
        password: SecureRandom.hex(12)
      )
    end

    @subscription.user = @user
    
    if @gift_subscription.save && (@user.persisted? || @user.save)
      render json: {status: :ok, gift_subscription: gift_subscription_data(@gift_subscription)}
    else
      render json: {status: :error, gift_subscription: gift_subscription_data(@gift_subscription)}
    end
  end

  def address
    @gift_subscription = GiftSubscription.find_by!(redemption_code: params[:id])
    @user = @gift_subscription.user

    case request.request_method.downcase.to_sym
    when :get
      if @user.has_address?
        redirect_to [:thanks, :gift_subscriptions]
      else
        render :address
      end
    when :put
      if @user.update(address_params)
        redirect_to [:thanks, :gift_subscriptions]
      else
        render :address
      end
    end
  end

  def thanks; end

  private

  def gift_subscription_data(gift_subscription)
    { attributes: gift_subscription.attributes.slice('giver_given_name', 'giver_surname', 'giver_email_address', 'plan_id', 'duration', 'recipient_given_name', 'recipient_surname', 'recipient_email_address', 'redemption_code').merge(price: gift_subscription.price, address_required: gift_subscription.requires_address?), errors: gift_subscription.errors.messages }
  end

  def validate_gift_subscription(gift_subscription)
    if !gift_subscription.valid?
      render(json: {status: :error, gift_subscription: gift_subscription_data(gift_subscription)}) and yield
    end
  end

  def setup_payment_intent(gift_subscription)
    Stripe::PaymentIntent.create({
      amount: gift_subscription.price,
      currency: 'eur',
    })
  end

  def duration_from_id(id)
    return nil unless id.present?
    return 6 if id.downcase.include? 'half'
    return 12 if id.downcase.include? 'full'
    raise 'No valid duration.'
  end

  def slug_from_id(id)
    return nil unless id.present?
    return :print if id.downcase.include? 'print'
    return :digital if id.downcase.include? 'digital'
    raise 'No valid slug.'
  end

  def gift_subscription_params
    params.require(:gift_subscription).permit(:giver_given_name, :giver_surname, :giver_email_address, :recipient_given_name, :recipient_surname, :recipient_email_address, :plan_id, :payment_method_id, :duration)
  end

  def address_params
    params.require(:user).permit(:address_line_1, :address_line_2, :city, :county, :post_code, :country_code)
  end
end
