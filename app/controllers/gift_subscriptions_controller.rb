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
  end

  def create
    @gift_subscription = GiftSubscription.new(gift_subscription_params)
    @gift_subscription.payment_method_id = params[:payment_method_id]
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
    if @gift_subscription.save &&
       (@user.persisted? || @user.save) &&
      @gift_subscription.capture_charge!
      respond_to do |format|
        format.html { redirect_to [:thanks, :gift_subscriptions] }
        format.js do
          render json: {
            status: @gift_subscription.charge_object.status,
            payment_intent_client_id: @gift_subscription.charge_object.id,
            payment_intent_client_secret: @gift_subscription.charge_object.client_secret
          }
        end
      end
    else
      render :show
    end
  end

  def confirm
    begin
      if params['paymentIntentId'].present?

        subscription = GiftSubscription.find_by_stripe_id(params['paymentIntentId'])
        intent = Stripe::PaymentIntent.confirm(params['paymentIntentId'])
        if intent.status == 'succeeded'
          subscription.charged_at = Time.zone.now
          subscription.save
          return redirect_to %I[thanks gift_subscriptions]
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
    redirect_to %I[thanks gift_subscriptions]
  end

  private

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
    params.require(:gift_subscription).permit(:giver_given_name, :giver_surname, :giver_email_address, :recipient_given_name, :recipient_surname, :recipient_email_address, :recipient_address_line_1, :recipient_address_line_2, :recipient_city, :recipient_county, :recipient_post_code, :recipient_country_code, :first_address_line_1, :first_address_line_2, :first_city, :first_county, :first_post_code, :first_country_code, :plan_id, :payment_method_id, :duration)
  end
end
