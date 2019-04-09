class CreateContactMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_messages do |t|
      t.text :body
      t.text :regarding
      t.text :full_name
      t.text :email_address

      t.timestamps
    end

    add_index :contact_messages, :regarding, unique: false
    add_index :contact_messages, :email_address, unique: false
  end
end
