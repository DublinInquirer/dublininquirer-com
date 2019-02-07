class CreateCoupons < ActiveRecord::Migration[5.2]
  def change
    create_table :coupons do |t|
      t.text :name
      t.text :slug, null: false

      t.timestamps
    end

    add_index :coupons, :slug, unique: true
  end
end
