class CreateUserNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :user_notes do |t|
      t.references :user, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end