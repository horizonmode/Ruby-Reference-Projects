require_relative "hire_item"
require_relative "hire_period"

module EquipmentHire
  class HireRequest
    attr_reader :id, :customer_id, :items, :period

    def initialize(id:, customer_id:, starts_on:, days:, items:)
      raise ArgumentError, "id is required" if id.nil?
      raise ArgumentError, "customer_id is required" if customer_id.nil?
      unless items.is_a?(Array) && !items.empty? &&
               items.all? { |item| item.is_a?(HireItem) }
        raise ArgumentError,
              "items must be a non-empty array of HireItem objects"
      end

      @id = immutable_id(id)
      @customer_id = immutable_id(customer_id)
      @period = HirePeriod.new(starts_on: starts_on, days: days)
      @items = items.dup.freeze
      freeze
    end

    def starts_on
      period.starts_on
    end

    def days
      period.days
    end

    private

    def immutable_id(id)
      id.is_a?(String) ? id.dup.freeze : id
    end
  end
end
