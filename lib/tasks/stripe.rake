namespace :stripe do
  task setup: :environment do
    StripeSetterUp.setup_products
  end

  task import_all: :environment do
    StripeImporter.import_all
  end

  task import_stragglers: :environment do
    StripeImporter.import_stragglers
  end

  task import_invoices: :environment do
    StripeImporter.import_invoices
  end

  task import_subscriptions: :environment do
    StripeImporter.import_subscriptions
  end

  task update_all: :environment do
    Plan.all.each { |pl| pl.update_from_stripe! }
    Subscription.all.each { |s| s.update_from_stripe! }
    User.all.each { |u| u.update_from_stripe! }
    Subscription.mark_as_lapsed!

    StripeImporter.import_invoices

    Invoice.where('created_on > ?', (Date.current - 1.week).to_date).each { |i| i.update_from_stripe! }

  end
end
