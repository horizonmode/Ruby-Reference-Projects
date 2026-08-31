module EquipmentHire
  module Pricing
    class Standard
      def calculate(request:, catalog:)
        request.items.sum do |item|
          product = catalog.fetch(item.product_id)
          item.quantity * product.daily_rate * request.days
        end
      end
    end
  end
end
