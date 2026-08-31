require_relative "quote_result"

module EquipmentHire
  class QuoteCalculator
    def initialize(catalog:, inventory:, pricing:, delivery:, clock:)
      validate_dependency(catalog, :fetch, :catalog)
      validate_dependency(inventory, :unavailable_product_ids_for, :inventory)
      validate_dependency(pricing, :calculate, :pricing)
      validate_dependency(delivery, :cost, :delivery)
      validate_dependency(clock, :now, :clock)

      @catalog = catalog
      @inventory = inventory
      @pricing = pricing
      @delivery = delivery
      @clock = clock
    end

    def quote(request)
      unavailable_product_ids = inventory.unavailable_product_ids_for(request)
      equipment_subtotal = pricing.calculate(request: request, catalog: catalog)
      delivery_charge = delivery.cost

      QuoteResult.new(
        request: request,
        equipment_subtotal: equipment_subtotal,
        delivery_charge: delivery_charge,
        unavailable_product_ids: unavailable_product_ids,
        created_at: clock.now
      )
    end

    private

    attr_reader :catalog, :clock, :delivery, :inventory, :pricing

    def validate_dependency(object, message, name)
      return if object.respond_to?(message)

      raise ArgumentError, "#{name} must respond to #{message}"
    end
  end
end
