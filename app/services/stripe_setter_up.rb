class StripeSetterUp
  def self.setup_products # move to a rake task
    create_product(
      name: 'Digital subscription',
      statement_descriptor: 'DUBINQ',
      type: 'service')

    create_product(
      name: 'Digital + Print subscription',
      statement_descriptor: 'DUBINQ',
      type: 'service')
  end

  def self.setup_plans # move this to a rake task
    digital_product = Product.find_by(name: "Digital subscription")
    create_plan(
      amount: 5_00,
      interval: 'month',
      interval_count: 1,
      product: digital_product.stripe_id,
      currency: 'eur',
      id: 'digital-m-082018')

    print_product = Product.find_by(name: "Digital + Print subscription")
    create_plan(
      amount: 8_00,
      interval: 'month',
      interval_count: 1,
      product: print_product.stripe_id,
      currency: 'eur',
      id: 'print-m-082018')
  end

  def self.create_product(params)
    sp = find_or_create_product(params)
    Product.find_or_create_by!(
      stripe_id: sp['id'],
      name: sp['name'])
  end

  def self.find_or_create_product(params)
    Stripe::Product.list.each do |product|
      next if product['name'] != params[:name]
      return product
    end

    Stripe::Product.create(params)
  end

  def self.create_plan(params)
    sp = find_or_create_plan(params)
    Plan.find_or_create_by!(
      stripe_id: sp['id'],
      amount:  params[:amount],
      interval: params[:interval],
      interval_count: params[:interval_count],
      product: Product.find_by(stripe_id: params[:product])
    )
  end

  def self.find_or_create_plan(params)
    return Stripe::Plan.retrieve(params[:id])
  rescue Stripe::InvalidRequestError
    return Stripe::Plan.create(params)
  end
end
