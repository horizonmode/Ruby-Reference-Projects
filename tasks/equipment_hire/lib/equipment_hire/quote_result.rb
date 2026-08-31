require_relative "hire_request"

module EquipmentHire
  class QuoteResult
    attr_reader :created_at,
                :delivery_charge,
                :equipment_subtotal,
                :request,
                :total,
                :unavailable_product_ids

    def initialize(
      request:,
      equipment_subtotal:,
      delivery_charge:,
      unavailable_product_ids:,
      created_at:
    )
      unless request.is_a?(HireRequest)
        raise ArgumentError, "request must be a HireRequest"
      end
      validate_money(equipment_subtotal, :equipment_subtotal)
      validate_money(delivery_charge, :delivery_charge)
      unless unavailable_product_ids.is_a?(Array)
        raise ArgumentError, "unavailable_product_ids must be an array"
      end
      unless created_at.is_a?(Time)
        raise ArgumentError, "created_at must be a Time"
      end

      @request = request
      @equipment_subtotal = equipment_subtotal
      @delivery_charge = delivery_charge
      @total = equipment_subtotal + delivery_charge
      @unavailable_product_ids = unavailable_product_ids.dup.freeze
      @created_at = created_at.dup.freeze
      freeze
    end

    def confirmable?
      unavailable_product_ids.empty?
    end

    private

    def validate_money(value, name)
      unless value.is_a?(Integer) && value >= 0
        raise ArgumentError,
              "#{name} must be a non-negative integer number of pence"
      end
    end
  end
end
