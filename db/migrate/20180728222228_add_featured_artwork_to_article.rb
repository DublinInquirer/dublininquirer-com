class AddFeaturedArtworkToArticle < ActiveRecord::Migration[5.2]
  def change
    add_reference :articles, :featured_artwork, references: :artworks, index: true
    add_foreign_key :articles, :artworks, column: :featured_artwork_id
  end
end
