require_relative "helpers"

class EquipmentHirePricingAndDeliveryTest < Minitest::Test
  include EquipmentHireTestHelpers

  def setup
    @catalog = build_catalog
    @items = [
      EquipmentHire::HireItem.new(product_id: :drill, quantity: 2),
      EquipmentHire::HireItem.new(product_id: :ladder, quantity: 1)
    ]
  end

  def test_standard_pricing
    request = build_request(items: @items)

    amount =
      EquipmentHire::Pricing::Standard.new.calculate(
        request: request,
        catalog: @catalog
      )

    assert_equal 11_400, amount
  end

  def test_weekend_pricing_only_adds_surcharge_when_period_includes_weekend
    policy = EquipmentHire::Pricing::Weekend.new
    weekday = build_request(starts_on: Date.new(2026, 9, 1), items: @items)
    weekend = build_request(starts_on: Date.new(2026, 9, 5), items: @items)

    assert_equal 11_400, policy.calculate(request: weekday, catalog: @catalog)
    assert_equal 13_680, policy.calculate(request: weekend, catalog: @catalog)
  end

  def test_member_pricing_decorates_another_policy
    policy =
      EquipmentHire::Pricing::Member.new(
        base: EquipmentHire::Pricing::Weekend.new
      )
    request = build_request(starts_on: Date.new(2026, 9, 5), items: @items)

    assert_equal 12_312, policy.calculate(request: request, catalog: @catalog)
  end

  def test_delivery_options_share_the_cost_interface
    options = {
      EquipmentHire::Delivery::Collection.new => 0,
      EquipmentHire::Delivery::Local.new => 1_500,
      EquipmentHire::Delivery::Distance.new(miles: 12) => 2_400,
      EquipmentHire::Delivery::Corporate.new(
        base: EquipmentHire::Delivery::Distance.new(miles: 12)
      ) =>
        0
    }

    options.each { |delivery, expected| assert_equal expected, delivery.cost }
  end
end
