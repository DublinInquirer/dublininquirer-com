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
Stripe.api_version = "2019-09-09"

StripeEvent.signing_secret = if Rails.env.production?
  Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :stripe, :signing_key)
else
  Rails.application.credentials.dig(:development, :stripe, :signing_key)
end

StripeEvent.configure do |events|
end