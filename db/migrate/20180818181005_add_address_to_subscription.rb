class AddAddressToSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :address_line_1, :text
    add_column :subscriptions, :address_line_2, :text
    add_column :subscriptions, :city, :text
    add_column :subscriptions, :county, :text
    add_column :subscriptions, :post_code, :text
    add_column :subscriptions, :country_code, :text

    add_index :subscriptions, :city, unique: false
    add_index :subscriptions, :county, unique: false
    add_index :subscriptions, :post_code, unique: false
    add_index :subscriptions, :country_code, unique: false
  end
end
