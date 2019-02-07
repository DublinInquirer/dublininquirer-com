class AddCategoriesToArticle < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :categories, :text, default: [], array: true
    add_index :articles, :categories
  end
end
