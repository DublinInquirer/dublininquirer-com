class AddArticleToArtwork < ActiveRecord::Migration[5.2]
  def change
    add_reference :artworks, :article, foreign_key: true
  end
end
