class RemoveOldColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :articles, :published_at
    remove_column :articles, :author_ids
    remove_column :articles, :categories
    remove_column :articles, :wp_id
    remove_column :articles, :status
    remove_column :articles, :structured_content

    remove_column :artworks, :wp_id
    remove_column :artworks, :wp_file

    remove_column :authors, :wp_id

    remove_column :comments, :wp_id
  end
end