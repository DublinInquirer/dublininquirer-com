class StripeImporter
  def self.import_all
    import_products
    import_plans
    import_customers
  end

  def self.update
    import_products
    import_plans
    import_invoices
  end

  def self.import_stragglers
    import_customers
    import_subscriptions
  end

  def self.import_products
    still_importing = true
    last_product_id = nil
    while still_importing do
      still_importing = false
      Stripe::Product.list(limit: 50, starting_after: last_product_id).each do |product|
        last_product_id = product['id']
        still_importing = true

        import_product(product)
      end
    end
  end

  def self.import_product(product)
    p = Product.find_or_initialize_by(stripe_id: product['id'])
    p.update!(name: product['name'])
  rescue
    raise product.inspect
  end

  def self.import_plans
    still_importing = true
    last_plan_id = nil
    while still_importing do
      still_importing = false
      Stripe::Plan.list(limit: 50, starting_after: last_plan_id).each do |plan|
        last_plan_id = plan['id']
        still_importing = true

        import_plan(plan)
      end
    end
  end

  def self.import_plan(plan)
    p = Plan.find_or_initialize_by(stripe_id: plan['id'])
    p.update!(
      amount:  plan['amount'],
      interval: plan['interval'],
      interval_count: plan['interval_count'],
      product: Product.find_by(stripe_id: plan['product'])
    )
  rescue
    raise plan.inspect
  end

  def self.import_subscriptions
    still_importing = true
    last_sub_id = nil
    while still_importing do
      still_importing = false
      Stripe::Subscription.list(limit: 50, starting_after: last_sub_id).each do |subscription|
        last_sub_id = subscription['id']
        still_importing = true

        import_subscription_from_subscription(subscription)
      end
    end
  end

  def self.import_invoices
    still_importing = true
    last_invoice_id = nil
    while still_importing do
      still_importing = false
      Stripe::Invoice.list(limit: 50, starting_after: last_invoice_id).each do |invoice|
        last_invoice_id = invoice['id']
        still_importing = !Invoice.where(stripe_id: invoice['id']).any?

        import_invoice_from_invoice(invoice)
      end
    end
  end

  def self.import_invoice_from_invoice(stripe_invoice)
    return true if Invoice.where(stripe_id: stripe_invoice['id']).any?
    return true unless stripe_invoice['date'].present? && stripe_invoice['due_date'].present?
    invoice = Invoice.new(stripe_id: stripe_invoice['id'])
    invoice.assign_attributes(invoice_attributes_from_stripe_invoice(stripe_invoice))
    invoice.save_without_timestamping!
  end

  def self.import_customers
    still_importing = true
    last_cust_id = nil
    while still_importing do
      still_importing = false
      Stripe::Customer.list(limit: 50, starting_after: last_cust_id).each do |customer|
        last_cust_id = customer['id']
        still_importing = true

        import_user_from_customer(customer)
      end
    end
  end

  def self.import_customer(id)
    customer = Stripe::Customer.retrieve(id)
    import_user_from_customer(customer)
  end

  def self.import_user_from_customer(customer)
    return if customer.nil?
    return if User.where(stripe_id: customer['id']).any?

    unique_email = if !customer['email_address'].present?
      customer['id']
    elsif User.where(email_address: customer['email'].downcase.strip).any?
      "#{ customer['email'].downcase.strip }---#{ customer['id'] }"
    else
      customer['email'].downcase.strip
    end

    u = User.find_or_initialize_by(email_address: unique_email)
    u.assign_attributes(
      password: SecureRandom.hex(10),
      full_name: customer['metadata']['Shipping Name'],
      stripe_id: customer['id'],
      set_password_at: nil,
      created_at: Time.zone.at(customer['created']),
      updated_at: Time.zone.at(customer['created'])
    )

    if !u.valid?
      Raven.capture_message 'Invalid user from customer',
        extra: {
          user_errors: u.errors.full_messages.to_json,
          stripe_user: customer.to_json,
          stripe_id: customer['id']
        }
    end

    u.save_without_timestamping!
  end

  def self.import_subscription_from_subscription(subscription)
    return if Subscription.where(stripe_id: subscription['id']).any?

    s = Subscription.new(stripe_id: subscription['id'])
    u = User.where(stripe_id: subscription['customer'])
    plan = Plan.find_by(stripe_id: subscription['plan']['id'])

    if u.nil?
      raise "Active subscription without user: #{ subscription['id'] }"
    end

    canceled_at = if subscription['canceled_at'].present?
      Time.zone.at(subscription['canceled_at'])
    else
      nil
    end

    ended_at = if subscription['ended_at'].present?
      Time.zone.at(subscription['ended_at'])
    else
      nil
    end

    s.assign_attributes(
      plan: plan,
      current_period_ends_at: Time.zone.at(subscription['current_period_end']),
      status: subscription['status'],
      metadata: subscription['metadata'],
      canceled_at: canceled_at,
      ended_at: ended_at,
      created_at: Time.zone.at(subscription['created']),
      updated_at: Time.zone.at(subscription['start'])
    )

    if !s.valid?
      Raven.capture_message 'Invalid subscription from stripe',
        extra: {
          sub_errors: s.errors.full_messages.to_json,
          subscription: subscription.to_json,
          stripe_id: subscription['id']
        }
    end

    s.save_without_timestamping!
  end

  def self.update_invoice_from_stripe(invoice)
    stripe_invoice = invoice.stripe_invoice
    invoice.assign_attributes(invoice_attributes_from_stripe_invoice(stripe_invoice))
    invoice.save_without_timestamping!
  end

  def self.invoice_attributes_from_stripe_invoice(stripe_invoice)
    subscription = Subscription.find_by(stripe_id: stripe_invoice['subscription'])
    user = User.find_by(stripe_id: stripe_invoice['customer'])

    lines = stripe_invoice['lines'].map do |line|
      {
        stripe_id: line['id'],
        amount: line['amount'],
        quantity: line['quantity'],
        plan_id: line['plan'].present? ? Plan.find_or_create_by(stripe_id: line['plan']['id']).id : nil,
        type: line['type']
      }
    end

    {
      stripe_id: stripe_invoice['id'],
      number: stripe_invoice['number'],
      receipt_number: stripe_invoice['receipt_number'],
      total: stripe_invoice['total'],
      closed: stripe_invoice['closed'],
      paid: stripe_invoice['paid'],
      attempted: stripe_invoice['attempted'],
      forgiven: stripe_invoice['forgiven'],
      created_on: Time.zone.at(stripe_invoice['date']).to_date,
      due_on: stripe_invoice['due_date'].present? ? Time.zone.at(stripe_invoice['due_date']).to_date : nil,
      period_starts_at: Time.zone.at(stripe_invoice['period_start']),
      period_ends_at: Time.zone.at(stripe_invoice['period_end']),
      next_payment_attempt_at: stripe_invoice['next_payment_attempt'].present? ? Time.zone.at(stripe_invoice['next_payment_attempt']) : nil,
      lines: lines,
      user_id: user.try(:id),
      subscription_id: subscription.try(:id),
      created_at: Time.zone.at(stripe_invoice['date']),
      updated_at: Time.zone.at(stripe_invoice['date'])
    }
  end
end
