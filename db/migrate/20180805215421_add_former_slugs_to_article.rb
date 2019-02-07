class AddFormerSlugsToArticle < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :former_slugs, :text, array: true, default: []
    add_index :articles, :former_slugs
  end
end
