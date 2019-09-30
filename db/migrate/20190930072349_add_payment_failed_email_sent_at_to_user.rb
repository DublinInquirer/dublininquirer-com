class AddPaymentFailedEmailSentAtToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :payment_failed_email_sent_at, :datetime
  end
end
