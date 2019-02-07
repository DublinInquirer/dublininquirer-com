class AddSubscribedWeeklyToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :subscribed_weekly, :boolean, default: false
  end
end
