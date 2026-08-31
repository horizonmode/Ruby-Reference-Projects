require "securerandom"
require_relative "quote_result"
require_relative "errors"
require_relative "./services/system_clock"
require_relative "./services/notifier"
require_relative "./services/payment_gateway"
require_relative "booking"

class BookingConfirmer
  def initialize(inventory:, payment_gateway:, notifier:, clock:)
    @inventory = inventory
    @payment_gateway = payment_gateway
    @notifier = notifier
    @clock = clock
  end

  def confirm(quote_result)
    raise ArgumentError, "Quote cannot be nil" if quote_result.nil?
    if quote_result.request.nil?
      raise ArgumentError, "Quote request cannot be nil"
    end
    raise QuoteExpiredError if expired?(quote_result)
    unless @inventory.available_for?(quote_result.request)
      raise EquipmentUnavailableError
    end
    unless @payment_gateway.charge(quote_result.total)
      raise PaymentRejectedError
    end

    booking = Booking.new(id: SecureRandom.uuid, request: quote_result.request)
    @inventory.reserve(booking)
    @notifier.notify("Booking confirmed")
    booking
  end

  private

  def expired?(quote_result)
    quote_result.time < @clock.now - 3600
  end
end
