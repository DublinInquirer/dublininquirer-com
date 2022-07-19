class CreateNewsletterSubscribers < ActiveRecord::Migration[7.0]
  def change
    create_table :newsletter_subscribers do |t|
      t.text :mailchimp_id, index: {unique: true}
      t.text :email_address, index: true
      t.text :given_name
      t.text :surname
      t.text :status, index: true

      t.timestamps
    end
  end
end
