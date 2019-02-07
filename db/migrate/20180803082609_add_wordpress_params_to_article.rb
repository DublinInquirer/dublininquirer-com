class AddWordpressParamsToArticle < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :status, :text
    add_column :articles, :wp_id, :bigint
    add_column :authors, :wp_id, :bigint

    add_index :articles, :status, unique: false
    add_index :articles, :wp_id, unique: false
    add_index :authors, :wp_id, unique: false

    remove_column :articles, :wp_slug, :text
    remove_column :authors, :wp_slug, :text
  end
end
