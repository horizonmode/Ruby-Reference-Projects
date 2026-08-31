require_relative "hire_request"

module EquipmentHire
  class Booking
    attr_reader :amount_charged, :confirmed_at, :id, :request

    def initialize(id:, request:, amount_charged:, confirmed_at:)
      raise ArgumentError, "id is required" if id.nil?
      unless request.is_a?(HireRequest)
        raise ArgumentError, "request must be a HireRequest"
      end
      unless amount_charged.is_a?(Integer) && amount_charged >= 0
        raise ArgumentError, "amount_charged must be a non-negative integer"
      end
      unless confirmed_at.is_a?(Time)
        raise ArgumentError, "confirmed_at must be a Time"
      end

      @id = id.is_a?(String) ? id.dup.freeze : id
      @request = request
      @amount_charged = amount_charged
      @confirmed_at = confirmed_at.dup.freeze
      freeze
    end
  end
end
