require_relative "../test_helper"
require_relative "../../tasks/equipment_hire/lib/equipment_hire"

module EquipmentHireTestHelpers
  FixedClock = Struct.new(:now)

  def build_product(id: :drill, daily_rate: 1_500, replacement_value: 12_000)
    EquipmentHire::Product.new(
      id: id,
      daily_rate: daily_rate,
      replacement_value: replacement_value
    )
  end

  def build_catalog
    EquipmentHire::Catalog.new(
      [
        build_product,
        build_product(id: :ladder, daily_rate: 800, replacement_value: 8_000)
      ]
    )
  end

  def build_request(
    id: "request-1",
    customer_id: 42,
    starts_on: Date.new(2026, 9, 1),
    days: 3,
    items: [EquipmentHire::HireItem.new(product_id: :drill, quantity: 1)]
  )
    EquipmentHire::HireRequest.new(
      id: id,
      customer_id: customer_id,
      starts_on: starts_on,
      days: days,
      items: items
    )
  end

  def build_inventory(drills: 5, ladders: 3)
    EquipmentHire::Inventory.new(
      items: [
        EquipmentHire::StockItem.new(product_id: :drill, quantity: drills),
        EquipmentHire::StockItem.new(product_id: :ladder, quantity: ladders)
      ]
    )
  end

  def build_quote(
    request: build_request,
    total: 1_500,
    created_at: Time.utc(2026, 9, 1, 9)
  )
    EquipmentHire::QuoteResult.new(
      request: request,
      equipment_subtotal: total,
      delivery_charge: 0,
      unavailable_product_ids: [],
      created_at: created_at
    )
  end
end
