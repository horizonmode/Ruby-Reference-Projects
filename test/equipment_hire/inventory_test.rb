require_relative "helpers"

class EquipmentHireInventoryTest < Minitest::Test
  include EquipmentHireTestHelpers

  def test_reserved_equipment_is_unavailable_during_an_overlap
    inventory = build_inventory(drills: 1)
    existing = build_request(starts_on: Date.new(2026, 9, 5), days: 3)
    inventory.reserve(build_booking(existing))

    earlier_overlap =
      build_request(id: "request-2", starts_on: Date.new(2026, 9, 3), days: 4)
    later_overlap =
      build_request(id: "request-3", starts_on: Date.new(2026, 9, 6), days: 1)

    refute inventory.available_for?(earlier_overlap)
    refute inventory.available_for?(later_overlap)
  end

  def test_adjacent_periods_do_not_overlap
    inventory = build_inventory(drills: 1)
    existing = build_request(starts_on: Date.new(2026, 9, 5), days: 3)
    inventory.reserve(build_booking(existing))

    before =
      build_request(id: "request-2", starts_on: Date.new(2026, 9, 3), days: 2)
    after =
      build_request(id: "request-3", starts_on: Date.new(2026, 9, 8), days: 1)

    assert inventory.available_for?(before)
    assert inventory.available_for?(after)
  end

  def test_duplicate_product_lines_are_combined
    inventory = build_inventory(drills: 5)
    request =
      build_request(
        items: [
          EquipmentHire::HireItem.new(product_id: :drill, quantity: 3),
          EquipmentHire::HireItem.new(product_id: :drill, quantity: 3)
        ]
      )

    refute inventory.available_for?(request)
    assert_equal [:drill], inventory.unavailable_product_ids_for(request)
  end

  def test_reserve_returns_and_retains_the_booking
    inventory = build_inventory(drills: 1)
    request = build_request
    booking = build_booking(request)

    assert_same booking, inventory.reserve(booking)
    refute inventory.available_for?(request)
  end

  private

  def build_booking(request)
    EquipmentHire::Booking.new(
      id: "booking-1",
      request: request,
      amount_charged: 1_500,
      confirmed_at: Time.utc(2026, 9, 1, 9)
    )
  end
end
