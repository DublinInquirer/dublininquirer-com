if Rails.env.production?
  Sidekiq.configure_server do |config|
  config.redis = { url: ENV['QUEUE_URL'] }
end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['QUEUE_URL'] }
  end
end
