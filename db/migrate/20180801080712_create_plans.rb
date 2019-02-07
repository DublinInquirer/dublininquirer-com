class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.text :stripe_id
      t.integer :amount
      t.text :interval
      t.integer :interval_count
      t.references :product, foreign_key: true

      t.timestamps
    end

    add_index :plans, :stripe_id, unique: true
  end
end
