class AddIndexForSearchableColumns < ActiveRecord::Migration[5.2]
  def up
    execute "create index articles_category on articles using gin(to_tsvector('english', category))"
    execute "create index artworks_caption on artworks using gin(to_tsvector('english', caption))"
    execute "create index authors_full_name on authors using gin(to_tsvector('english', full_name))"
    execute "create index authors_bio on authors using gin(to_tsvector('english', bio))"
    execute "create index tags_name on tags using gin(to_tsvector('english', name))"
    execute "create index users_given_name on users using gin(to_tsvector('english', given_name))"
    execute "create index users_surname on users using gin(to_tsvector('english', surname))"
    execute "create index users_address_line_1 on users using gin(to_tsvector('english', address_line_1))"
    execute "create index users_address_line_2 on users using gin(to_tsvector('english', address_line_2))"
  end

  def down
    execute "drop index articles_category"
    execute "drop index artworks_caption"
    execute "drop index authors_full_name"
    execute "drop index authors_bio"
    execute "drop index tags_name"
    execute "drop index users_given_name"
    execute "drop index users_surname"
    execute "drop index users_address_line_1"
    execute "drop index users_address_line_2"
  end
end
