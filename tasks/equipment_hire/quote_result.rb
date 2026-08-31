class QuoteResult
  attr_reader :subtotal,
              :total,
              :delivery_charge,
              :requested_products,
              :unavailable_products,
              :time,
              :request
  def initialize(
    subtotal:,
    total:,
    delivery_charge:,
    requested_products:,
    unavailable_products:,
    time:,
    request:
  )
    @subtotal = subtotal
    @total = total
    @delivery_charge = delivery_charge
    @requested_products = requested_products
    @unavailable_products = unavailable_products

    @time = time
    @request = request
    freeze
  end

  def can_be_confirmed?
    @unavailable_products.empty?
  end
end
