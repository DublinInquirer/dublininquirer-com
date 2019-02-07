class AddBannedAtToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :banned_at, :datetime
    add_index :users, :banned_at

    User.where(email_address: 'brajesh27@gmail.com').each do |u|
      u.ban!
    end
  end
end
