class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.references :user, foreign_key: true
      t.references :article, foreign_key: true
      t.bigint :parent_id
      t.text :wp_id
      t.text :content
      t.text :nickname
      t.text :email_address
      t.text :status
      t.datetime :published_at

      t.timestamps
    end

    add_index :comments, :wp_id
    add_index :comments, :parent_id
    add_index :comments, :email_address
    add_index :comments, :status
  end
end
