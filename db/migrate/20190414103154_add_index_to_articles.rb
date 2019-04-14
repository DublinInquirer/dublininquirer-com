class AddIndexToArticles < ActiveRecord::Migration[5.2]
  def up
    execute "create index articles_title on articles using gin(to_tsvector('english', title))"
    execute "create index articles_excerpt on articles using gin(to_tsvector('english', excerpt))"
    execute "create index articles_text on articles using gin(to_tsvector('english', text))"
  end

  def down
    execute "drop index articles_title"
    execute "drop index articles_excerpt"
    execute "drop index articles_text"
  end
end