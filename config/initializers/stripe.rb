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
  events.subscribe 'customer.updated' do |event|
    user = User.where(stripe_id: event.data.object.id),take
    if user
      user.update_from_stripe!(event.data.object)
    end
  end

  events.subscribe 'customer.subscription.updated' do |subscription|
    subscription = Subscription.where(stripe_id: event.data.object.id).take
    if subscription
      subscription.update_from_stripe!(event.data.object)
    end
  end

  events.subscribe 'invoice.payment_failed' do |event|
  end

  events.all do |event|
    Raven.capture_message 'Stripe webhook', extra: event
  end
end