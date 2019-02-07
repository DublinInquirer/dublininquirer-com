class AddWpSlugToArticle < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :wp_slug, :text
    add_column :authors, :wp_slug, :text

    add_index :articles, :wp_slug, unique: true
    add_index :authors, :wp_slug, unique: true
  end
end
