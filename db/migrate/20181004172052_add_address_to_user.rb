class AddAddressToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :address_line_1, :text
    add_column :users, :address_line_2, :text
    add_column :users, :city, :text
    add_column :users, :county, :text
    add_column :users, :post_code, :text
    add_column :users, :country, :text
    add_column :users, :country_code, :text

    add_index :users, :city, unique: false
    add_index :users, :county, unique: false
    add_index :users, :post_code, unique: false
    add_index :users, :country_code, unique: false
  end
end
