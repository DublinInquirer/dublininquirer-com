class CreateContactMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_messages do |t|
      t.text :body
      t.text :regarding
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :contact_messages, :regarding, unique: false
  end
end
