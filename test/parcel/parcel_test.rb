require_relative "../test_helper"
require_relative "../../tasks/parcel/parcel"

class ParcelTest < Minitest::Test
  def test_exposes_its_attributes
    parcel =
      Parcel.new(
        id: "P-100",
        destination: "London",
        weight: 4.5,
        priority: :express
      )

    assert_equal "P-100", parcel.id
    assert_equal "London", parcel.destination
    assert_equal 4.5, parcel.weight
    assert_equal :express, parcel.priority
  end

  def test_accepts_every_supported_priority
    Parcels::PRIORITY_TYPES.each do |priority|
      parcel = build_parcel(priority: priority)

      assert_equal priority, parcel.priority
    end
  end

  def test_rejects_an_unsupported_priority
    error = assert_raises(ArgumentError) { build_parcel(priority: :overnight) }

    assert_equal "Invalid priority type", error.message
  end

  def test_is_immutable
    parcel = build_parcel

    assert_predicate parcel, :frozen?
    assert_predicate parcel.id, :frozen?
    assert_predicate parcel.destination, :frozen?
    assert_raises(FrozenError) { parcel.instance_variable_set(:@weight, 20) }
  end

  def test_copies_mutable_constructor_values
    id = +"P-100"
    destination = +"London"
    parcel = build_parcel(id: id, destination: destination)

    id << "-changed"
    destination << " changed"

    assert_equal "P-100", parcel.id
    assert_equal "London", parcel.destination
  end

  private

  def build_parcel(
    id: "P-100",
    destination: "London",
    weight: 4.5,
    priority: :standard
  )
    Parcel.new(
      id: id,
      destination: destination,
      weight: weight,
      priority: priority
    )
  end
end
