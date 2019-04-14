class AddFullNameToUser < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :full_name, :text
    execute "create index users_full_name on users using gin(to_tsvector('english', full_name))"

    User.find_each(&:save!)
  end

  def down
    remove_column :users, :full_name
    execute "drop index users_full_name"
  end
end
