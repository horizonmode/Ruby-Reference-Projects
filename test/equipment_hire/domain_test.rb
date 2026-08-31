require_relative "helpers"

class EquipmentHireDomainTest < Minitest::Test
  include EquipmentHireTestHelpers

  def test_domain_values_and_collections_are_immutable
    product = build_product
    item = EquipmentHire::HireItem.new(product_id: :drill, quantity: 1)
    request = build_request(items: [item])
    catalog = EquipmentHire::Catalog.new([product])

    assert_predicate product, :frozen?
    assert_predicate item, :frozen?
    assert_predicate request, :frozen?
    assert_predicate request.items, :frozen?
    assert_predicate catalog.all_products, :frozen?
    assert_raises(FrozenError) { request.items << item }
  end

  def test_catalog_fetches_products_and_reports_unknown_ids
    catalog = build_catalog

    assert_equal :drill, catalog.fetch(:drill).id
    assert_equal %i[drill ladder], catalog.map(&:id)
    assert_raises(EquipmentHire::UnknownProductError) { catalog.fetch(:saw) }
  end

  def test_hire_period_detects_weekends_and_overlaps
    weekend =
      EquipmentHire::HirePeriod.new(starts_on: Date.new(2026, 9, 5), days: 2)
    overlapping =
      EquipmentHire::HirePeriod.new(starts_on: Date.new(2026, 9, 4), days: 2)
    adjacent =
      EquipmentHire::HirePeriod.new(starts_on: Date.new(2026, 9, 7), days: 1)

    assert_predicate weekend, :includes_weekend?
    assert weekend.overlaps?(overlapping)
    refute weekend.overlaps?(adjacent)
  end

  def test_money_values_must_be_integer_pence
    assert_raises(ArgumentError) do
      EquipmentHire::Product.new(
        id: :drill,
        daily_rate: 15.50,
        replacement_value: 12_000
      )
    end
  end
end
