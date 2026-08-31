require_relative "helpers"

class EquipmentHireQuoteCalculatorTest < Minitest::Test
  include EquipmentHireTestHelpers

  def setup
    @time = Time.utc(2026, 9, 1, 9)
    @catalog = build_catalog
  end

  def test_builds_an_immutable_quote_with_injected_collaborators
    request = build_request
    calculator = build_calculator

    quote = calculator.quote(request)

    assert_equal 4_500, quote.equipment_subtotal
    assert_equal 1_500, quote.delivery_charge
    assert_equal 6_000, quote.total
    assert_equal @time, quote.created_at
    assert_predicate quote, :confirmable?
    assert_predicate quote, :frozen?
    assert_predicate quote.unavailable_product_ids, :frozen?
  end

  def test_reports_unavailable_products
    request =
      build_request(
        items: [EquipmentHire::HireItem.new(product_id: :drill, quantity: 6)]
      )

    quote = build_calculator.quote(request)

    refute_predicate quote, :confirmable?
    assert_equal [:drill], quote.unavailable_product_ids
  end

  def test_catalog_owns_unknown_product_errors
    request =
      build_request(
        items: [EquipmentHire::HireItem.new(product_id: :saw, quantity: 1)]
      )

    assert_raises(EquipmentHire::UnknownProductError) do
      build_calculator.quote(request)
    end
  end

  private

  def build_calculator
    EquipmentHire::QuoteCalculator.new(
      catalog: @catalog,
      inventory: build_inventory,
      pricing: EquipmentHire::Pricing::Standard.new,
      delivery: EquipmentHire::Delivery::Local.new,
      clock: FixedClock.new(@time)
    )
  end
end
