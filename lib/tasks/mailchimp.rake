namespace :mailchimp do
  task upsert_subscribers: :environment do
    User.wants_newsletter.each do |user|
      Newsletter.upsert_subscriber(user)
    end
  end

  task sync_from_mailchimp: :environment do
    Newsletter.sync_from_mailchimp!
  end
end
