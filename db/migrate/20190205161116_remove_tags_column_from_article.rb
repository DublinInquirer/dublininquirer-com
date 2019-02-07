class RemoveTagsColumnFromArticle < ActiveRecord::Migration[5.2]
  def change
    remove_column :articles, :tags, :string
  end
end
