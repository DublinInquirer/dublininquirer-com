Rails.configuration.stripe = if Rails.env.production?
  {
    publishable_key: Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :stripe, :publishable_key),
    secret_key: Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :stripe, :secret_key)
  }
else
  {
    publishable_key: Rails.application.credentials.dig(:development, :stripe, :publishable_key),
    secret_key: Rails.application.credentials.dig(:development, :stripe, :secret_key)
  }
end

Stripe.api_key = Rails.configuration.stripe[:secret_key]
Stripe.api_version = "2019-05-16"
