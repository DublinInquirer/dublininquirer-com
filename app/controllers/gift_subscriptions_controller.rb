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
    @gift_subscription.stripe_token = params[:stripe_token]
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
      redirect_to [:thanks, :gift_subscriptions]
    else
      render :show
    end
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
    params.require(:gift_subscription).permit(:giver_given_name, :giver_surname, :giver_email_address, :recipient_given_name, :recipient_surname, :recipient_email_address, :recipient_address_line_1, :recipient_address_line_2, :recipient_city, :recipient_county, :recipient_post_code, :recipient_country_code, :first_address_line_1, :first_address_line_2, :first_city, :first_county, :first_post_code, :first_country_code, :plan_id, :stripe_token, :duration)
  end
end
