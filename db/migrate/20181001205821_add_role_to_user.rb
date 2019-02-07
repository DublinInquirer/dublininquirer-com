class AddRoleToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :role, :string, default: 'user'
    add_index :users, :role, unique: false
  end
end
