class AddHubToSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :hub, :text

    Subscription.all.each do |subscription|
      subscription.set_address_from_user!
    end
  end
end
