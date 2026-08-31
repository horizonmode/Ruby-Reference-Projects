require_relative "../test_helper"
require_relative "helpers"

class NearestElevatorSchedulerTest < Minitest::Test
  include ElevatorTestHelpers

  def setup
    @building = build_building
    @scheduler = NearestElevatorScheduler.new
  end

  def test_prefers_a_compatible_elevator_moving_toward_the_origin
    moving = moving_elevator(id: 1, from: 1, destination: 10)
    idle = build_elevator(id: 2, building: @building, current_floor: 4)
    request = build_request(origin: 5, destination: 8, building: @building)

    selected = @scheduler.call(request, [moving, idle])

    assert_same moving, selected
  end

  def test_prefers_an_idle_elevator_over_an_incompatible_moving_one
    moving_down = moving_elevator(id: 1, from: 10, destination: 1)
    idle = build_elevator(id: 2, building: @building, current_floor: 1)
    request = build_request(origin: 6, destination: 9, building: @building)

    selected = @scheduler.call(request, [moving_down, idle])

    assert_same idle, selected
  end

  def test_uses_distance_then_lowest_id_to_break_ties
    farther = build_elevator(id: 3, building: @building, current_floor: 1)
    nearer_high_id =
      build_elevator(id: 2, building: @building, current_floor: 4)
    nearer_low_id = build_elevator(id: 1, building: @building, current_floor: 6)
    request = build_request(origin: 5, destination: 8, building: @building)

    selected =
      @scheduler.call(request, [farther, nearer_high_id, nearer_low_id])

    assert_same nearer_low_id, selected
  end

  def test_ignores_elevators_without_capacity_or_service
    full = build_elevator(id: 1, building: @building, capacity: 1)
    full.assign(build_request(id: 1, building: @building), tick: 0)
    disabled = build_elevator(id: 2, building: @building)
    disabled.disable(tick: 0)
    request = build_request(id: 2, passengers: 1, building: @building)

    assert_nil @scheduler.call(request, [full, disabled])
  end

  private

  def moving_elevator(id:, from:, destination:)
    elevator = build_elevator(id: id, building: @building, current_floor: from)
    direction = from < destination ? :up : :down
    origin = from
    request =
      build_request(
        id: "prime-#{id}",
        origin: origin,
        destination: destination,
        building: @building
      )
    elevator.assign(request, tick: 0)
    elevator.tick(tick_number: 1) # Open and board at the origin.
    elevator.tick(tick_number: 2) # Close the doors.
    elevator.tick(tick_number: 3) # Move one floor and establish direction.

    assert_equal direction, elevator.direction
    elevator
  end
end
