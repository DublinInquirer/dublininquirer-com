class AddIssueDateToArticle < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :issue_date, :date
    add_column :articles, :category, :text

    add_index :articles, :issue_date, unique: false
    add_index :articles, :category, unique: false
  end
end
