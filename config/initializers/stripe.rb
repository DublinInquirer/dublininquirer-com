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
      user.create_from_stripe_object!(event.data.object)
    end
  end

  events.subscribe 'customer.subscription.updated' do |event|
    subscription = Subscription.where(stripe_id: event.data.object.id).take
    if subscription
      subscription.create_from_stripe_object!(event.data.object)
    end
  end
  
  events.subscribe 'plan.updated' do |event|
    plan = Plan.where(stripe_id: event.data.object.id),take
    if plan
      plan.create_from_stripe_object!(event.data.object)
    end
  end
  
  events.subscribe 'product.updated' do |event|
    product = Product.where(stripe_id: event.data.object.id),take
    if product
      product.create_from_stripe_object!(event.data.object)
    end
  end

  events.subscribe 'invoice.payment_failed' do |event|
    # do manual dunning
  end
  
  events.subscribe 'invoice.created' do |event|
    Invoice.create_from_stripe_object!(event.data.object)
  end
  
  events.subscribe 'invoice.updated' do |event|
    invoice = Invoice.where(stripe_id: event.data.object.id),take
    if invoice
      invoice.create_from_stripe_object!(event.data.object)
    end
  end

  events.all do |event|
    puts "Hello"
  end
end