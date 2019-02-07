class AddNicknameToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :nickname, :text
    add_column :users, :portrait, :text

    add_index :users, :nickname, unique: true
  end
end
