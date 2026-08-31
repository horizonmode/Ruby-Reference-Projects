require_relative "../test_helper"
require_relative "helpers"

class ElevatorTest < Minitest::Test
  include ElevatorTestHelpers

  def setup
    @building = build_building
    @elevator = build_elevator(building: @building, capacity: 4)
  end

  def test_initial_state
    assert_equal 1, @elevator.current_floor
    assert_equal :idle, @elevator.direction
    assert_equal :closed, @elevator.door_status
    assert_equal :available, @elevator.service_status
    assert_equal 0, @elevator.passenger_count
    assert_empty @elevator.assigned_requests
  end

  def test_assignment_reserves_capacity
    first = build_request(id: 1, passengers: 3, building: @building)
    second = build_request(id: 2, passengers: 2, building: @building)

    event = @elevator.assign(first, tick: 0)

    assert_equal :request_assigned, event.type
    refute @elevator.can_accept?(second)
    assert_raises(ArgumentError) { @elevator.assign(second, tick: 0) }
  end

  def test_one_tick_performs_one_physical_action
    request =
      build_request(
        origin: 2,
        destination: 4,
        passengers: 2,
        building: @building
      )
    @elevator.assign(request, tick: 0)

    moved = @elevator.tick(tick_number: 1)
    opened = @elevator.tick(tick_number: 2)
    closed = @elevator.tick(tick_number: 3)

    assert_equal [:elevator_moved], moved.events.map(&:type)
    assert_equal %i[doors_opened passengers_boarded], opened.events.map(&:type)
    assert_equal [:doors_closed], closed.events.map(&:type)
    assert_equal 2, @elevator.current_floor
    assert_equal :closed, @elevator.door_status
    assert_equal 2, @elevator.passenger_count
  end

  def test_completes_a_journey_and_updates_passenger_count
    request =
      build_request(
        origin: 1,
        destination: 3,
        passengers: 2,
        building: @building
      )
    @elevator.assign(request, tick: 0)
    completed = []
    tick = 0

    run_until do
      tick += 1
      completed.concat(@elevator.tick(tick_number: tick).completed_requests)
      completed.include?(request)
    end

    assert_equal 0, @elevator.passenger_count
    refute_includes @elevator.assigned_requests, request
  end

  def test_services_stops_in_directional_order
    requests = [
      build_request(id: 1, origin: 8, destination: 10, building: @building),
      build_request(id: 2, origin: 3, destination: 10, building: @building),
      build_request(id: 3, origin: 5, destination: 10, building: @building)
    ]
    requests.each { |request| @elevator.assign(request, tick: 0) }
    opened_floors = []

    30.times do |tick|
      result = @elevator.tick(tick_number: tick + 1)
      result.events.each do |event|
        opened_floors << event.floor if event.type == :doors_opened
      end
      break if opened_floors.length >= 3
    end

    assert_equal [3, 5, 8], opened_floors.first(3)
  end

  def test_never_moves_outside_the_building
    request = build_request(origin: 1, destination: 10, building: @building)
    @elevator.assign(request, tick: 0)

    30.times do |tick|
      @elevator.tick(tick_number: tick + 1)
      assert @building.include?(@elevator.current_floor)
    end
  end
end
