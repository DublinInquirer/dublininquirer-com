class CreateAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :authors do |t|
      t.text :full_name, null: false
      t.text :slug, null: false
      t.text :bio

      t.timestamps
    end

    add_index :authors, :slug, unique: true
  end
end
