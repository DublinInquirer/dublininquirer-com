namespace :mailchimp do
  task upsert_subscribers: :environment do
    User.wants_newsletter.each do |user|
      Newsletter.upsert_subscriber(user)
    end
  end
end
