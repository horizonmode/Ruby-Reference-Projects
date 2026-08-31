require "date"

require_relative "product"
require_relative "booking"
require_relative "hire_item"
require_relative "hire_request"
require_relative "catalog"
require_relative "inventory"
require_relative "quote_calculator"
require_relative "booking_confirmer"

require_relative "pricing/standard_pricing"
require_relative "delivery/local_delivery"

require_relative "services/payment_gateway"
require_relative "services/notifier"
require_relative "services/system_clock"

# 1. Create the product catalogue

products = [
  Product.new(id: :drill, daily_rate: 1_500, replacement_value: 12_000),
  Product.new(id: :ladder, daily_rate: 800, replacement_value: 8_000),
  Product.new(id: :generator, daily_rate: 4_000, replacement_value: 50_000)
]

catalog = Catalog.new(products)

# 2. Create the inventory

inventory =
  Inventory.new(
    [
      Inventory::Item.new(:drill, 5),
      Inventory::Item.new(:ladder, 3),
      Inventory::Item.new(:generator, 1)
    ]
  )

# 3. Select interchangeable behaviour

pricing = StandardPricing.new
delivery = LocalDelivery.new

# Try swapping these later:
#
# pricing = WeekendPricing.new
# pricing = MemberPricing.new
#
# delivery = CustomerCollection.new
# delivery = DistanceDelivery.new(miles: 12)

# 4. Create the quote calculator

calculator = QuoteCalculator.new(pricingModel: pricing, deliveryModel: delivery)

# 5. Create a hire request

request =
  HireRequest.new(
    customer_id: 42,
    starts_on: Date.new(2026, 9, 5),
    days: 3,
    items: [
      HireItem.new(product_id: :drill, quantity: 2),
      HireItem.new(product_id: :ladder, quantity: 1)
    ]
  )

# 6. Produce a quote

quote = calculator.quote(request, catalog: catalog, inventory: inventory)

puts "Equipment subtotal: £#{quote.subtotal / 100.0}"
puts "Delivery: £#{quote.delivery_charge / 100.0}"
puts "Total: £#{quote.total / 100.0}"

unless quote.can_be_confirmed?
  puts "Unavailable products: #{quote.unavailable_products.join(", ")}"
  exit
end

# 7. Inject external service objects

confirmer =
  BookingConfirmer.new(
    inventory: inventory,
    payment_gateway: PaymentGateway.new,
    notifier: Notifier.new,
    clock: SystemClock.new
  )

# 8. Confirm the quote

begin
  booking = confirmer.confirm(quote)

  puts "Booking #{booking.id} confirmed"
  puts "Amount charged: £#{quote.total / 100.0}"
rescue QuoteExpiredError => error
  warn "Could not confirm: #{error.message}"
rescue PaymentRejectedError => error
  warn "Payment failed: #{error.message}"
rescue EquipmentUnavailableError => error
  warn "Equipment is no longer available: #{error.message}"
end
