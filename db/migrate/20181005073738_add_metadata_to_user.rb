class AddMetadataToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :metadata, :jsonb
  end
end
