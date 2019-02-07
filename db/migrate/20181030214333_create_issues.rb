class CreateIssues < ActiveRecord::Migration[5.2]
  def change
    create_table :issues do |t|
      t.date :issue_date
      t.boolean :published, default: false

      t.timestamps
    end

    add_index :issues, :issue_date, unique: true
    add_index :issues, :published, unique: false

    Issue.create_all_for_articles
  end
end
