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
  events.subscribe 'customer.created' do |event|
    user = User.where(stripe_id: event.data.object.id).take
    if user
      user.update_from_stripe_object!(event.data.object)
    end
  end

  events.subscribe 'customer.updated' do |event|
    user = User.where(stripe_id: event.data.object.id).take
    if user
      user.update_from_stripe_object!(event.data.object)
    end
  end

  events.subscribe 'customer.subscription.updated' do |event|
    subscription = Subscription.where(stripe_id: event.data.object.id).take
    if subscription
      subscription.update_from_stripe_object!(event.data.object)
    end
  end
  
  events.subscribe 'plan.updated' do |event|
    plan = Plan.where(stripe_id: event.data.object.id).take
    if plan
      plan.update_from_stripe_object!(event.data.object)
    end
  end
  
  events.subscribe 'product.updated' do |event|
    product = Product.where(stripe_id: event.data.object.id).take
    if product
      product.update_from_stripe_object!(event.data.object)
    end
  end

  events.subscribe 'invoice.payment_failed' do |event|
    customer_id = event.data.object.customer
    if customer_id && customer_id.is_a?(String)
      user = User.find_by(stripe_id: customer_id)
      user.send_dunning_email!
    end
  end

  events.subscribe 'invoice.payment_action_required' do |event|
    raise "Invoice payment action required: #{ event.to_hash.inspect }"
  end
  
  events.subscribe 'invoice.created' do |event|
    Invoice.create_from_stripe_object!(event.data.object)
  end
  
  events.subscribe 'invoice.updated' do |event|
    invoice = Invoice.where(stripe_id: event.data.object.id).take
    if invoice
      invoice.update_from_stripe_object!(event.data.object)
    end
  end
end