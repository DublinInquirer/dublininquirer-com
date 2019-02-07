if Rails.env.production?
  Raven.configure do |config|
    config.dsn = Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :sentry, :dsn)
  end
end
