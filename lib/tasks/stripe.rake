namespace :stripe do
  task update_all: :environment do
    Plan.all.each { |pl| pl.update_from_stripe! }
    Subscription.all.each { |s| s.update_from_stripe! }
    User.all.each { |u| u.update_from_stripe! }
    Subscription.mark_as_lapsed!

    StripeImporter.import_invoices

    Invoice.where('created_on > ?', (Date.current - 1.week).to_date).each { |i| i.update_from_stripe! }
  end
end
