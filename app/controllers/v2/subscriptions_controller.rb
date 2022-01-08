class V2::SubscriptionsController < ApplicationController
  layout "modal"

  def new
    product_slug = params[:product_slug]&.downcase&.to_sym
    amount = params[:amount].to_i

    @product = case product_slug
    when :digital
      Product.find_by_slug('digital')
    when :print
      Product.find_by_slug('print')
    when :student
      Product.find_by_slug('digital')
    else
      raise ActiveRecord::RecordNotFound
    end

    @plan = Plan.find_or_create_by!(
      amount: 500 || amount,
      product_id: @product.id,
      interval: "month",
      interval_count: 1
    )

    @user = logged_in? ? current_user : User.new(subscribed_weekly: true)
    @subscription = Subscription.new(user: @user, plan: @plan)
  end

  def validate
    raise params.inspect
  end
end
