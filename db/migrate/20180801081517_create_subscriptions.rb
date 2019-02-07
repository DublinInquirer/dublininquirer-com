class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.text :stripe_id
      t.references :plan, foreign_key: true
      t.references :user, foreign_key: true
      t.datetime :current_period_ends_at
      t.text :status
      t.jsonb :metadata
      t.datetime :canceled_at
      t.datetime :ended_at

      t.timestamps
    end

    add_index :subscriptions, :stripe_id, unique: true
    add_index :subscriptions, :status
    add_index :subscriptions, :current_period_ends_at
  end
end
