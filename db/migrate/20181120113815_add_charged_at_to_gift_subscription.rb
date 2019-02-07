class AddChargedAtToGiftSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :gift_subscriptions, :stripe_id, :text
    add_column :gift_subscriptions, :charged_at, :datetime
    add_index :gift_subscriptions, :stripe_id, unique: true
    add_index :gift_subscriptions, :charged_at, unique: false
  end
end
