class AddMarkedAsSpamToComment < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :marked_as_spam, :boolean, default: false
    add_index :comments, :marked_as_spam, unique: false
  end
end
