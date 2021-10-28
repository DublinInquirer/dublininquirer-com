class StripeSetterUp
  def self.setup_products # move to a rake task
    create_product(
      name: 'Digital subscription',
      base_price: 6_00)

    create_product(
      name: 'Digital + Print subscription',
      base_price: 9_00)
  end

  def self.create_product(params)
    sp = find_or_create_product(params)
    Product.find_or_create_by!(
      stripe_id: sp['id'],
      name: params[:name],
      base_price: params[:base_price])
  end

  def self.find_or_create_product(params)
    Stripe::Product.list.each do |product|
      next if product['name'] != params[:name]
      return product
    end

    Stripe::Product.create(
      name: params[:name],
      statement_descriptor: 'DUBINQ',
      type: 'service'
    )
  end
end
