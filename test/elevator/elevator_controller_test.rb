require_relative "../test_helper"
require_relative "helpers"

class ElevatorControllerTest < Minitest::Test
  include ElevatorTestHelpers

  def setup
    @building = build_building
    @first = build_elevator(id: 1, building: @building, capacity: 4)
    @second = build_elevator(id: 2, building: @building, capacity: 4)
    @controller =
      ElevatorController.new(
        elevators: [@first, @second],
        scheduler: NearestElevatorScheduler.new,
        building: @building
      )
  end

  def test_assigns_a_request_and_records_the_event
    request = build_request(building: @building)

    selected = @controller.request_journey(request)

    assert_equal @first.id, selected.id
    assert_instance_of ElevatorSnapshot, selected
    assert_equal :assigned, @controller.request_status(request.id)
    assert_equal :request_assigned, @controller.events.last.type
    assert_empty @controller.pending_requests
  end

  def test_pending_request_is_retried_after_an_elevator_is_enabled
    @controller.disable_elevator(@first.id)
    @controller.disable_elevator(@second.id)
    request = build_request(building: @building)

    assert_nil @controller.request_journey(request)
    assert_equal [request], @controller.pending_requests

    @controller.enable_elevator(@second.id)

    assert_includes @second.assigned_requests, request
    assert_empty @controller.pending_requests
  end

  def test_tracks_pickup_and_completion
    request =
      build_request(
        origin: 1,
        destination: 3,
        passengers: 2,
        building: @building
      )
    @controller.request_journey(request)

    @controller.tick
    assert_equal :picked_up, @controller.request_status(request.id)

    run_until do
      @controller.tick
      @controller.request_status(request.id) == :completed
    end

    assert_includes @controller.completed_requests, request
    assert_equal 0, @first.passenger_count
  end

  def test_disabling_requeues_waiting_requests_but_delivers_passengers
    onboard =
      build_request(
        id: 1,
        origin: 1,
        destination: 5,
        passengers: 2,
        building: @building
      )
    waiting =
      build_request(
        id: 2,
        origin: 3,
        destination: 4,
        passengers: 2,
        building: @building
      )
    @controller.request_journey(onboard)
    @controller.tick # Board the first request.
    @controller.request_journey(waiting)
    assert_includes @first.waiting_requests, waiting

    released = @controller.disable_elevator(@first.id)

    assert_equal [waiting], released
    assert_includes @controller.pending_requests, waiting
    assert_includes @first.onboard_requests, onboard

    @controller.tick # The second elevator receives the pending request.
    assert_includes @second.assigned_requests, waiting

    run_until do
      @controller.tick
      @controller.request_status(onboard.id) == :completed
    end

    assert_predicate @first, :out_of_service?
    assert_equal 0, @first.passenger_count
  end

  def test_injected_scheduler_controls_assignment
    scheduler = ->(_request, elevators) { elevators.last }
    controller =
      ElevatorController.new(
        elevators: [@first, @second],
        scheduler: scheduler,
        building: @building
      )
    request = build_request(building: @building)

    selected = controller.request_journey(request)

    assert_equal @second.id, selected.id
    assert_instance_of ElevatorSnapshot, selected
  end

  def test_public_collections_cannot_mutate_controller_state
    request = build_request(building: @building)
    @controller.request_journey(request)

    assert_predicate @controller.events, :frozen?
    assert_predicate @controller.completed_requests, :frozen?
    assert_predicate @controller.pending_requests, :frozen?
    assert_predicate @controller.elevators, :frozen?
    assert_raises(FrozenError) { @controller.events.clear }
  end

  def test_exposes_immutable_elevator_snapshots
    snapshot = @controller.elevators.first

    assert_instance_of ElevatorSnapshot, snapshot
    assert_predicate snapshot, :frozen?
    refute_respond_to snapshot, :tick
    refute_respond_to snapshot, :assign
    assert_raises(FrozenError) do
      snapshot.instance_variable_set(:@current_floor, 9)
    end
  end

  def test_rejects_elevators_from_a_different_building
    other_building = build_building(min_floor: 1, max_floor: 20)
    elevator = build_elevator(building: other_building)

    error = assert_raises(ArgumentError) do
      ElevatorController.new(
        elevators: [elevator],
        scheduler: NearestElevatorScheduler.new,
        building: @building
      )
    end

    assert_equal "elevators must belong to the controller building", error.message
  end

  def test_accepts_equivalent_building_value
    equivalent_building = build_building
    elevator = build_elevator(building: equivalent_building)

    controller =
      ElevatorController.new(
        elevators: [elevator],
        scheduler: NearestElevatorScheduler.new,
        building: @building
      )

    assert_equal elevator.id, controller.elevators.first.id
  end

  def test_event_objects_are_immutable
    request = build_request(building: @building)
    @controller.request_journey(request)
    event = @controller.events.last

    assert_predicate event, :frozen?
    assert_predicate event.details, :frozen?
    assert_raises(FrozenError) { event.instance_variable_set(:@floor, 9) }
  end

  def test_duplicate_request_ids_are_rejected
    @controller.request_journey(build_request(id: 1, building: @building))

    assert_raises(ArgumentError) do
      @controller.request_journey(
        build_request(id: 1, origin: 2, building: @building)
      )
    end
  end

  def test_identical_simulations_produce_identical_event_sequences
    first_run = run_simulation
    second_run = run_simulation

    assert_equal first_run, second_run
  end

  private

  def run_simulation
    elevator = build_elevator(id: 1, building: @building)
    controller =
      ElevatorController.new(
        elevators: [elevator],
        scheduler: NearestElevatorScheduler.new,
        building: @building
      )
    request =
      build_request(id: 500, origin: 2, destination: 4, building: @building)
    controller.request_journey(request)

    run_until do
      controller.tick
      controller.completed_requests.include?(request)
    end

    controller.events.map do |event|
      [
        event.type,
        event.elevator_id,
        event.request_id,
        event.floor,
        event.details
      ]
    end
  end
end
