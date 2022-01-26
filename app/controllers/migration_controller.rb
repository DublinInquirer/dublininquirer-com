class MigrationController < ApplicationController
  before_action :require_login, only: [:payment, :welcome, :plan, :plan_save]

  layout 'modal'

  def new; end

  def create
    @legacy_user = User.find_by(email_address: params[:email_address].strip.downcase)

    if !@legacy_user
      @failure = true
      render :new
    elsif @legacy_user.has_password?
      @legacy_user.deliver_reset_password_instructions!
      redirect_to(root_path, notice: 'Instructions have been sent to your email.')
    else
      setup_legacy_account(@legacy_user)
    end
  end

  def hold; end

  def show
    @token = params[:token]
    @user = User.load_from_reset_password_token(@token)

    if @user.blank?
      not_authenticated
      return
    end
  end

  def set_password
    @token = params[:token]
    @user = User.load_from_reset_password_token(@token)

    if @user.blank?
      not_authenticated
      return
    end

    @user.assign_attributes(password_reset_params)
    if @user.valid?(:password_reset) && @user.change_password!(password_reset_params[:password])
      @user.touch(:set_password_at)
      auto_login(@user, true)

      if @user.needs_to_confirm_plan?
        redirect_to :migrate_plan
      elsif @user.delinquent?
        redirect_to [:payment, :user]
      else
        redirect_to :migrate_welcome
      end
    else
      render action: "show"
    end
  end

  def payment # req login
    @user = current_user
    raise "Attempt to use the migration payment form: #{current_user.inspect}"

    case request.request_method.downcase.to_sym
    when :get
      render :payment
    when :put
      @user.stripe_token = payment_params[:stripe_token]
      if @user.save
        redirect_to :migrate_welcome
      else
        render :payment
      end
    end
  end

  def welcome; end # req login

  def plan # req login
    @user = current_user
    @subscription = @user.subscription
  end

  def plan_save # req login
    @user = current_user
    product = Product.active.find_by_slug(params[:plan])
    plan = Plan.find_by(product: product, interval: 'month')
    subscription = @user.subscription

    subscription.change_product_to!(product.slug)

    if @user.delinquent?
      redirect_to [:payment, :user]
    else
      redirect_to :migrate_welcome
    end
  end

  private

  def payment_params
    params.permit(:stripe_token)
  end

  def password_reset_params
    params.require(:user).permit(:password)
  end
end
