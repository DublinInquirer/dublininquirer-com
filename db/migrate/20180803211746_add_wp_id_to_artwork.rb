class AddWpIdToArtwork < ActiveRecord::Migration[5.2]
  def change
    add_column :artworks, :wp_id, :text
    add_index :artworks, :wp_id, unique: false
  end
end
