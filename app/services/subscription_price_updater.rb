class SubscriptionPriceUpdater
  def self.update_prices(params)
    # {:limit=>25, :digital_before=>500, :digital_after=>600, :print_before=>800, :print_after=>900}
    old_plans = {
      digital: Product.find_by_slug(:digital).plans.find_by(amount: params[:digital_before], interval: "month"),
      print: Product.find_by_slug(:print).plans.find_by(amount: params[:print_before], interval: "month")
    }

    old_plan_ids = old_plans.values.map(&:id)
    subs = Subscription.is_stripe.where(status: %w(trialing incomplete active past_due)).where(plan_id: old_plan_ids).limit(params[:limit])
    
    subs.each do |subscription|
      if (old_plans[:digital].id == subscription.plan_id)
        subscription.change_price_to!(params[:digital_after]) # digital
      elsif (old_plans[:print].id == subscription.plan_id)
        subscription.change_price_to!(params[:print_after]) # print
      else
        raise "Unsupport subscription in updater: #{subscription.id}, plan: #{subscription.plan_id}"
      end
    end
  end
end