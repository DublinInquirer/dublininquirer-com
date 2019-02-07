class AddTrialEndToSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :trial_ends_at, :datetime
    add_column :subscriptions, :coupon_code, :text

    add_index :subscriptions, :trial_ends_at, unique: false
    add_index :subscriptions, :coupon_code, unique: false
  end
end
