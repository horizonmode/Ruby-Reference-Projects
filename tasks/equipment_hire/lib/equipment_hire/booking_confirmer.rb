require_relative "booking"
require_relative "errors"

module EquipmentHire
  class BookingConfirmer
    QUOTE_LIFETIME_SECONDS = 3_600

    def initialize(
      inventory:,
      payment_gateway:,
      notifier:,
      clock:,
      id_generator:
    )
      validate_dependency(inventory, :available_for?, :inventory)
      validate_dependency(inventory, :reserve, :inventory)
      validate_dependency(payment_gateway, :charge, :payment_gateway)
      validate_dependency(notifier, :notify, :notifier)
      validate_dependency(clock, :now, :clock)
      validate_dependency(id_generator, :call, :id_generator)

      @inventory = inventory
      @payment_gateway = payment_gateway
      @notifier = notifier
      @clock = clock
      @id_generator = id_generator
    end

    def confirm(quote)
      raise ArgumentError, "quote is required" if quote.nil?
      raise QuoteExpiredError, "quote has expired" if expired?(quote)
      unless inventory.available_for?(quote.request)
        raise EquipmentUnavailableError, "equipment is no longer available"
      end
      unless payment_gateway.charge(quote.total)
        raise PaymentRejectedError, "payment was rejected"
      end

      booking = build_booking(quote)
      inventory.reserve(booking)
      notifier.notify(booking)
      booking
    end

    private

    attr_reader :clock, :id_generator, :inventory, :notifier, :payment_gateway

    def build_booking(quote)
      Booking.new(
        id: id_generator.call,
        request: quote.request,
        amount_charged: quote.total,
        confirmed_at: clock.now
      )
    end

    def expired?(quote)
      quote.created_at < clock.now - QUOTE_LIFETIME_SECONDS
    end

    def validate_dependency(object, message, name)
      return if object.respond_to?(message)

      raise ArgumentError, "#{name} must respond to #{message}"
    end
  end
end
