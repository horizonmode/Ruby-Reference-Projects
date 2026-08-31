module EquipmentHire
  class HireItem
    attr_reader :product_id, :quantity

    def initialize(product_id:, quantity:)
      raise ArgumentError, "product_id is required" if product_id.nil?
      unless quantity.is_a?(Integer) && quantity.positive?
        raise ArgumentError, "quantity must be a positive integer"
      end

      @product_id =
        product_id.is_a?(String) ? product_id.dup.freeze : product_id
      @quantity = quantity
      freeze
    end
  end
end
