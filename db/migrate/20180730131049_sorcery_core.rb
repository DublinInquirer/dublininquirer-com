class SorceryCore < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.text :email_address,            :null => false
      t.text :crypted_password
      t.text :salt

      t.text :given_name
      t.text :surname

      t.timestamps                :null => false
    end

    add_index :users, :email_address, unique: true
  end
end
