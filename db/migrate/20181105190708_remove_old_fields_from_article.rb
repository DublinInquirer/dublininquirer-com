class RemoveOldFieldsFromArticle < ActiveRecord::Migration[5.2]
  def change
    remove_column :articles, :issue_date, :date
  end
end
