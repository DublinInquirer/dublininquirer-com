class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.text :name
      t.text :stripe_id

      t.timestamps
    end

    add_index :products, :stripe_id, unique: true
  end
end
