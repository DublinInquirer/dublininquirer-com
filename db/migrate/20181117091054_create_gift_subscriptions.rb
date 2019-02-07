class CreateGiftSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :gift_subscriptions do |t|
      t.references :subscription, foreign_key: true
      t.references :plan
      t.integer :duration
      t.text :giver_given_name
      t.text :giver_surname
      t.text :giver_email_address
      t.text :first_address_line_1
      t.text :first_address_line_2
      t.text :first_city
      t.text :first_county
      t.text :first_post_code
      t.text :first_country_code
      t.text :notes
      t.text :redemption_code

      t.timestamps
    end

    add_index :gift_subscriptions, :redemption_code, unique: true
  end
end
