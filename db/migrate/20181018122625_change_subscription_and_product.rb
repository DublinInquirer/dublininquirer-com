class ChangeSubscriptionAndProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :base_price, :integer, default: 0
    add_reference :subscriptions, :product, index: true

    remove_column :subscriptions, :address_line_1, :text
    remove_column :subscriptions, :address_line_2, :text
    remove_column :subscriptions, :city, :text
    remove_column :subscriptions, :county, :text
    remove_column :subscriptions, :post_code, :text
    remove_column :subscriptions, :country_code, :text
    remove_column :subscriptions, :hub, :text

    digital_prod = Product.find_by_slug(:digital)
    print_prod = Product.find_by_slug(:print)

    digital_prod.base_price = 500
    print_prod.base_price = 800

    digital_prod.save!
    print_prod.save!
  end
end
