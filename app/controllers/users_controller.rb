class UsersController < ApplicationController
  before_action :require_login, except: [:new, :create]

  layout 'modal'

  def new
    if visitor_is_probable_bot?
      redirect_to(:root) && return
    end

    @user = User.new(subscribed_weekly: true)
  end

  def create
    if user_params[:referral_required].present? && !user_params[:referral_required].strip.blank?
      mark_visitor_as_probable_bot
      redirect_to(:root) && return
    end

    @legacy_user = User.unmigrated.find_or_initialize_by(email_address: user_params[:email_address].strip.downcase)

    if @legacy_user.persisted? && @legacy_user.needs_setup?
      # setup legacy account
      setup_legacy_account(@legacy_user) && return
    else
      @user = User.new(user_params.merge(set_password_at: Time.zone.now))
      if @user.save
        auto_login(@user, true)
        redirect_to :root
      else
        render :new
      end
    end
  end

  def show
    @user = current_user
    @invoices = @user.invoices.
      where('created_at > ?', Date.new(2018,10,20).beginning_of_day).
      where('total > 0').
      order('created_at desc').
      limit(12)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(details_params)
      redirect_to :user
    else
      render :edit
    end
  end

  def subscription
    @subscription = current_user.subscription
    @plan = @subscription.plan
    @product = @plan.product

    case request.request_method.downcase.to_sym
    when :get
      render :subscription
    when :put
      if @subscription.change_product_to!(params[:plan].to_sym)
        redirect_to :user
      else
        render :subscription
      end
    end
  end

  def change_subscription
    @subscription = current_user.subscription
    @plan = @subscription.plan
    @product = @plan.product
    @subscription.change_product_to!(params[:product_slug], true)
    @subscription.change_price_to!((params[:amount] * 100))
    redirect_to :user
  end

  def address
    @user = current_user

    case request.request_method.downcase.to_sym
    when :get
      render :address
    when :put
      if @user.update(address_params)
        redirect_to :user
      else
        render :address
      end
    end
  end

  def cancel_step_one
    @user = current_user
    @subscription = @user.subscription
  end

  def cancel_step_two
    @user = current_user
    @subscription = @user.subscription

    case request.request_method.downcase.to_sym
    when :get
      render :cancel_step_two
    when :delete
      @subscription.cancel_subscription!
      redirect_to [:cancelled, :user]
    end
  end

  def cancelled
    @user = current_user
    @subscription = @user.subscription
  end

  def accept_lower_offer
    @user = current_user
    @subscription = @user.subscription
    @subscription.change_product_to!(:digital) if @subscription.print?
    @subscription.change_price_and_interval_to!(300,"month")
    redirect_to [:accepted_lower_offer, :user]
  end

  def accepted_lower_offer
    @user = current_user
    @subscription = @user.subscription
  end

  def payment
    @user = current_user
  end

  def payment_submit
    @user = current_user
    @subscription = @user.subscription

    # if the card is invalid, return here
    attach_card_to_user(@user, payment_params) { return }

    render json: {status: :ok}
  end

  def payment_confirm; end

  private

  def attach_card_to_user(user, payment_params)
    begin
      user.add_stripe_source(payment_params[:stripe_token])
    rescue Stripe::CardError => e
      render(json: {
          status: :error,
          payment: {error: e.message}
        }) and yield
    end
  end

  def payment_params
    params.require(:payment).permit(:stripe_token)
  end

  def address_params
    params.require(:user).permit(:address_line_1, :address_line_2, :city, :county, :post_code, :country_code)
  end

  def details_params
    params.require(:user).permit(:email_address, :given_name, :surname, :nickname)
  end

  def user_params
    params.require(:user).permit(:email_address, :given_name, :surname, :password, :subscribed_weekly, :referral_required)
  end
end
