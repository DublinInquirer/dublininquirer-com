class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.text :stripe_id
      t.text :number
      t.text :receipt_number
      t.integer :total
      t.boolean :closed
      t.boolean :paid
      t.boolean :attempted
      t.boolean :forgiven
      t.date :created_on
      t.date :due_on
      t.datetime :period_starts_at
      t.datetime :period_ends_at
      t.datetime :next_payment_attempt_at
      t.jsonb :lines, default: {}
      t.references :user, foreign_key: true
      t.references :subscription, foreign_key: true

      t.timestamps
    end

    add_index :invoices, :stripe_id, unique: true
    add_index :invoices, :number
    add_index :invoices, :receipt_number
    add_index :invoices, :created_on
    add_index :invoices, :due_on
  end
end
