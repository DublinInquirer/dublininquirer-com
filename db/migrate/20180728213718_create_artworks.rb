class CreateArtworks < ActiveRecord::Migration[5.2]
  def change
    create_table :artworks do |t|
      t.text :caption
      t.text :image
      t.text :hashed_id

      t.timestamps
    end

    add_index :artworks, :hashed_id, unique: true
  end
end
