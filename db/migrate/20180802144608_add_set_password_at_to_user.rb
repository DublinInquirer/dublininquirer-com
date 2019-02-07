class AddSetPasswordAtToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :set_password_at, :datetime
  end
end
