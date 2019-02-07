class AddHubToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :hub, :text
    add_index :users, :hub, unique: false

    User.all.each do |u|
      next unless u.metadata.present? && u.metadata.is_a?(Hash)
      next unless u.metadata.keys.include?('Hub') or u.metadata.keys.include?('hub')
      u.hub = [u.metadata['Hub'], u.metadata['hub']].compact.reject(&:blank?).first
      u.save!
    end
  end
end
