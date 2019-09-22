class SubscriptionsController < ApplicationController
  before_action :require_login, only: [:upgrade, :thanks]
  before_action :require_no_subscription, only: [:create]
  layout 'modal', only: [:upgrade, :create, :thanks]

  # user valid:
  # 1. Payment succeeds
  # 2. Payment requires SCA
  # 3. Payment fails
  # user invalid:
  # 1. Display errors client-side

  def create
    @user = logged_in? ? current_user : User.new
    @user.assign_attributes(user_params)

    # if the user is invalid, return here
    validate_user(@user) { return }
    save_user_with_card(@user, payment_params)
    @subscription = setup_subscription(@user, subscription_params)

    case @subscription.status
    when 'incomplete' # 2
      render json: {status: :incomplete}
    when 'active' # 1
      render json: {status: :ok}
    end

    auto_login(@user)
  end

  def confirm
    raise params.inspect
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

  # valid? or return attributes + errors
  def validate_user(user)
    if !user.valid?
      render(json: {status: :error, user: user_data(user)}) and yield
    end
  end

  # save user
  def save_user_with_card(user, payment_params)
    if user.stripe_id.present? # if customer exists, add a source
      user.add_stripe_source(payment_params[:stripe_token])
    else # if no customer exists, add the token to the user
      user.stripe_token = payment_params[:stripe_token]
      user.save
    end
  end

  # set up subscription or return attributes + errors
  def setup_subscription(user, subscription_params)
    plan = Plan.find_by!(stripe_id: subscription_params[:plan_id])
    Subscription.create!(plan: plan, user: user)
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
end
