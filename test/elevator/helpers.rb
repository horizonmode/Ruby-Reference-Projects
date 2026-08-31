require_relative "../../tasks/elevator/building"
require_relative "../../tasks/elevator/elevator"
require_relative "../../tasks/elevator/elevator_controller"
require_relative "../../tasks/elevator/journey-request"
require_relative "../../tasks/elevator/scheduler"

module ElevatorTestHelpers
  def build_building(min_floor: 1, max_floor: 10)
    Building.new(min_floor: min_floor, max_floor: max_floor)
  end

  def build_elevator(
    id: 1,
    building: build_building,
    capacity: 4,
    current_floor: building.min_floor
  )
    Elevator.new(
      id: id,
      building: building,
      capacity: capacity,
      current_floor: current_floor
    )
  end

  def build_request(
    id: 101,
    origin: 1,
    destination: 5,
    passengers: 1,
    building: build_building
  )
    JourneyRequest.new(
      id: id,
      origin: origin,
      destination: destination,
      passengers: passengers,
      building: building
    )
  end

  def run_until(limit: 100)
    limit.times { return if yield }
    flunk "condition was not reached within #{limit} ticks"
  end
end
