class AddRssKeyToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :rss_key, :text, index: {unique: true}
    User.all.each do |user|
      user.generate_rss_key!
    end
  end
end
