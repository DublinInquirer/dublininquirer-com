class AddCustomerColumnsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :stripe_id, :text
    add_index :users, :stripe_id, unique: true
  end
end
