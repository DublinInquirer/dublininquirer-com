class AddPortraitToAuthor < ActiveRecord::Migration[5.2]
  def change
    add_column :authors, :portrait, :text
  end
end
