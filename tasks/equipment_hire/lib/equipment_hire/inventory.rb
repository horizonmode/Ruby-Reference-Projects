require_relative "booking"
require_relative "hire_request"
require_relative "stock_item"

module EquipmentHire
  class Inventory
    def initialize(items: [])
      unless items.is_a?(Array) && items.all? { |item| item.is_a?(StockItem) }
        raise ArgumentError, "items must be an array of StockItems"
      end

      @items = items.dup.freeze
      @bookings = []
    end

    def all_items
      items.dup.freeze
    end

    def reserve(booking)
      unless booking.is_a?(Booking)
        raise ArgumentError, "booking must be a Booking"
      end

      bookings << booking
      booking
    end

    def available_for?(request)
      quantities_for(request).all? do |product_id, quantity|
        available?(
          product_id: product_id,
          quantity: quantity,
          period: request.period
        )
      end
    end

    def unavailable_product_ids_for(request)
      quantities_for(request)
        .filter_map do |product_id, quantity|
          unless available?(
                   product_id: product_id,
                   quantity: quantity,
                   period: request.period
                 )
            product_id
          end
        end
        .freeze
    end

    private

    attr_reader :bookings, :items

    def available?(product_id:, quantity:, period:)
      total_quantity(product_id) - reserved_quantity(product_id, period) >=
        quantity
    end

    def quantities_for(request)
      request
        .items
        .each_with_object(Hash.new(0)) do |item, quantities|
          quantities[item.product_id] += item.quantity
        end
    end

    def total_quantity(product_id)
      items.select { |item| item.product_id == product_id }.sum(&:quantity)
    end

    def reserved_quantity(product_id, period)
      bookings.sum do |booking|
        request = booking.request
        next 0 unless request.period.overlaps?(period)

        request
          .items
          .select { |item| item.product_id == product_id }
          .sum(&:quantity)
      end
    end
  end
end
