require "securerandom"
require_relative "lib/equipment_hire"

include EquipmentHire

def format_money(pence)
  format("£%.2f", pence.fdiv(100))
end

clock = Services::SystemClock.new
id_generator = -> { SecureRandom.uuid }

catalog =
  Catalog.new(
    [
      Product.new(id: :drill, daily_rate: 1_500, replacement_value: 12_000),
      Product.new(id: :ladder, daily_rate: 800, replacement_value: 8_000),
      Product.new(id: :generator, daily_rate: 4_000, replacement_value: 50_000)
    ]
  )

inventory =
  Inventory.new(
    items: [
      StockItem.new(product_id: :drill, quantity: 5),
      StockItem.new(product_id: :ladder, quantity: 3),
      StockItem.new(product_id: :generator, quantity: 1)
    ]
  )

# These collaborators can be replaced without changing QuoteCalculator.
pricing = Pricing::Standard.new
delivery = Delivery::Local.new

# Other examples:
# pricing = Pricing::Weekend.new
# pricing = Pricing::Member.new(base: Pricing::Weekend.new)
# delivery = Delivery::Collection.new
# delivery = Delivery::Distance.new(miles: 12)
# delivery = Delivery::Corporate.new(base: delivery)

calculator =
  QuoteCalculator.new(
    catalog: catalog,
    inventory: inventory,
    pricing: pricing,
    delivery: delivery,
    clock: clock
  )

request =
  HireRequest.new(
    id: id_generator.call,
    customer_id: 42,
    starts_on: Date.new(2026, 9, 5),
    days: 3,
    items: [
      HireItem.new(product_id: :drill, quantity: 2),
      HireItem.new(product_id: :ladder, quantity: 1)
    ]
  )

quote = calculator.quote(request)

puts "Equipment subtotal: #{format_money(quote.equipment_subtotal)}"
puts "Delivery: #{format_money(quote.delivery_charge)}"
puts "Total: #{format_money(quote.total)}"

unless quote.confirmable?
  puts "Unavailable products: #{quote.unavailable_product_ids.join(", ")}"
  exit
end

confirmer =
  BookingConfirmer.new(
    inventory: inventory,
    payment_gateway: Services::PaymentGateway.new,
    notifier: Services::Notifier.new,
    clock: clock,
    id_generator: id_generator
  )

begin
  booking = confirmer.confirm(quote)

  puts "Booking #{booking.id} confirmed"
  puts "Amount charged: #{format_money(booking.amount_charged)}"
rescue QuoteExpiredError => error
  warn "Could not confirm: #{error.message}"
rescue PaymentRejectedError => error
  warn "Payment failed: #{error.message}"
rescue EquipmentUnavailableError => error
  warn "Equipment is no longer available: #{error.message}"
end
