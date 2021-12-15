namespace :subscribers do
  task update_prices_for_batch: :environment do
    SubscriptionPriceUpdater.update_prices(
      limit: 10,
      digital_before: 5_00,
      digital_after: 6_00,
      print_before: 8_00,
      print_after: 9_00
    )
  end
end
