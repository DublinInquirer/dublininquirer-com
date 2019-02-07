class RemoveUniqueIndexOnUser < ActiveRecord::Migration[5.2]
  def change
    remove_index :users, :nickname
    add_index :users, :nickname, unique: false
  end
end
