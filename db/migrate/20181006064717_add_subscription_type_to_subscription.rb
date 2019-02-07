class AddSubscriptionTypeToSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :subscription_type, :text, default: 'stripe'
    add_index :subscriptions, :subscription_type
  end
end
