class AddIssueToArticle < ActiveRecord::Migration[5.2]
  def change
    add_reference :articles, :issue, foreign_key: true
    add_column :articles, :position, :integer

    add_index :articles, :position, unique: false

    Article.all.each do |article|
      article.issue = Issue.find_or_create_by(issue_date: article.issue_date)
      article.save!
    end
  end
end
