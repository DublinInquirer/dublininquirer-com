class AddWpFileToArtwork < ActiveRecord::Migration[5.2]
  def change
    add_column :artworks, :wp_file, :text
    add_index :artworks, :wp_file, unique: true
  end
end
