class GiftSubscriptionsController < ApplicationController
  layout 'modal'

  def index
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

  def confirm
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

    if @subscription.requires_address? && !@user.persisted? # What about users who are persisted but have no address?
      @user.address_line_1 = @subscription.address_line_1
      @user.address_line_2 = @subscription.address_line_2
      @user.city = @subscription.city
      @user.county = @subscription.county
      @user.post_code = @subscription.post_code
      @user.country_code = @subscription.country_code
    end

    @subscription.user = @user
    
    @gift_subscription.save && (@user.persisted? || @user.save)

    render json: {status: :ok, gift_subscription: gift_subscription_data(@gift_subscription)}
  end

  private

  def gift_subscription_data(gift_subscription)
    { attributes: gift_subscription.attributes.slice('giver_given_name', 'giver_surname', 'giver_email_address', 'plan_id', 'duration', 'recipient_given_name', 'recipient_surname', 'recipient_email_address', 'recipient_address_line_1', 'recipient_address_line_2', 'recipient_city', 'recipient_county', 'recipient_post_code', 'recipient_country_code'), errors: gift_subscription.errors.messages }
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
    params.require(:gift_subscription).permit(:giver_given_name, :giver_surname, :giver_email_address, :recipient_given_name, :recipient_surname, :recipient_email_address, :recipient_address_line_1, :recipient_address_line_2, :recipient_city, :recipient_county, :recipient_post_code, :recipient_country_code, :plan_id, :payment_method_id, :duration)
  end
end
