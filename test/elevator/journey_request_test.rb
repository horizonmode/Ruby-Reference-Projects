require_relative "../test_helper"
require_relative "helpers"

class JourneyRequestTest < Minitest::Test
  include ElevatorTestHelpers

  def test_reports_its_direction
    up = build_request(origin: 2, destination: 8)
    down = build_request(origin: 8, destination: 2)

    assert_equal :up, up.direction
    assert_equal :down, down.direction
  end

  def test_is_immutable
    request = build_request

    assert_predicate request, :frozen?
    assert_raises(FrozenError) do
      request.instance_variable_set(:@destination, 9)
    end
  end

  def test_rejects_equal_origin_and_destination
    assert_raises(ArgumentError) { build_request(origin: 4, destination: 4) }
  end

  def test_rejects_floors_outside_the_building
    building = build_building(min_floor: -2, max_floor: 5)

    assert_raises(ArgumentError) do
      build_request(origin: -3, destination: 2, building: building)
    end
    assert_raises(ArgumentError) do
      build_request(origin: 2, destination: 6, building: building)
    end
  end

  def test_requires_a_positive_integer_passenger_count
    [0, -1, 1.5, nil].each do |passengers|
      assert_raises(ArgumentError) { build_request(passengers: passengers) }
    end
  end
end

class BuildingTest < Minitest::Test
  include ElevatorTestHelpers

  def test_reports_which_floors_it_contains
    building = build_building(min_floor: -1, max_floor: 3)

    assert building.include?(-1)
    assert building.include?(3)
    refute building.include?(4)
    refute building.include?(1.5)
  end

  def test_rejects_invalid_floor_boundaries
    assert_raises(ArgumentError) { build_building(min_floor: 3, max_floor: 3) }
    assert_raises(ArgumentError) { build_building(min_floor: 5, max_floor: 2) }
    assert_raises(ArgumentError) do
      build_building(min_floor: 1.5, max_floor: 5)
    end
  end
end
