require_relative "quote_result"
require_relative "inventory"
require_relative "catalog"

class QuoteCalculator
  def initialize(pricingModel:, deliveryModel:)
    unless pricingModel.respond_to?("calculate")
      raise ArgumentError, "pricingModel must respond to :calculate"
    end
    unless deliveryModel.respond_to?("cost")
      raise ArgumentError, "deliveryModel must respond to :cost"
    end
    @pricingModel = pricingModel
    @deliveryModel = deliveryModel
  end

  def quote(hire_request, catalog:, inventory:)
    unavailable_products = []
    subtotal = 0
    hire_request.items.each do |item|
      catalog_item = catalog.find { |c| c.id == item.product_id }
      unless catalog_item
        raise ArgumentError,
              "Product with id #{item.product_id} not found in catalog"
      end
      unless inventory.available?(
               product_id: item.product_id,
               quantity: item.quantity,
               starts_on: hire_request.starts_on,
               days: hire_request.days
             )
        unavailable_products << item.product_id
        next
      end
      subtotal += @pricingModel.calculate(item, catalog_item, hire_request.days)
    end

    QuoteResult.new(
      subtotal: subtotal,
      total: subtotal + @deliveryModel.cost(),
      delivery_charge: @deliveryModel.cost(),
      requested_products: hire_request.items,
      unavailable_products: unavailable_products,
      time: Time.now,
      request: hire_request
    )
  end
end
