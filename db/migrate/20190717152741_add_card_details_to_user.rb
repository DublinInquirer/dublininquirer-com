class AddCardDetailsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sources_count, :integer, default: 0
    add_column :users, :card_last_4, :text
    add_column :users, :card_brand, :text
    add_index :users, :sources_count, unique: false
  end
end
