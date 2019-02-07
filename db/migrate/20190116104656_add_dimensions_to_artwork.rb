class AddDimensionsToArtwork < ActiveRecord::Migration[5.2]
  def change
    add_column :artworks, :width_px, :integer
    add_column :artworks, :height_px, :integer

    # Artwork.find_each do |artwork|
    #   artwork.image.recreate_versions! if artwork.image?
    # end
  end
end
