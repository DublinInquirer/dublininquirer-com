namespace :stripe do
  task update_all: :environment do
    Subscription.mark_as_lapsed!

    StripeImporter.import_invoices

    Invoice.where('created_on > ?', (Date.current - 1.week).to_date).each { |i| i.update_from_stripe! }
  end
end
