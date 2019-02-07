class AddTemplateToArticle < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :template, :text
  end
end
