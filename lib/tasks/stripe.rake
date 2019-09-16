namespace :stripe do
  task update_all: :environment do
    Subscription.mark_as_lapsed!
  end
end
