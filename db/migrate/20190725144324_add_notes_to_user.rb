class AddNotesToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :notes, :jsonb, default: {}
    add_index :users, :notes, using: :gin
  end
end
