class AddSubscriptionFieldsToSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :cancel_at_period_end, :boolean
  end
end
