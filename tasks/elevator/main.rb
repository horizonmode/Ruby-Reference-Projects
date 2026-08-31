require_relative "building"
require_relative "elevator"
require_relative "elevator_controller"
require_relative "journey-request"
require_relative "scheduler"

building = Building.new(min_floor: 1, max_floor: 10)

elevators = [
  Elevator.new(id: 1, building: building, capacity: 6, current_floor: 1),
  Elevator.new(id: 2, building: building, capacity: 6, current_floor: 5),
  Elevator.new(id: 3, building: building, capacity: 6, current_floor: 10)
]

controller =
  ElevatorController.new(
    elevators: elevators,
    scheduler: NearestElevatorScheduler.new,
    building: building
  )

requests = [
  JourneyRequest.new(
    id: 101,
    origin: 2,
    destination: 9,
    passengers: 2,
    building: building
  ),
  JourneyRequest.new(
    id: 102,
    origin: 8,
    destination: 3,
    passengers: 3,
    building: building
  ),
  JourneyRequest.new(
    id: 103,
    origin: 4,
    destination: 7,
    passengers: 1,
    building: building
  )
]

requests.each do |request|
  elevator = controller.request_journey(request)
  puts "Request #{request.id} assigned to elevator #{elevator.id}"
end

until controller.completed_requests.length == requests.length
  events = controller.tick
  puts "\nTick #{controller.tick_number}"

  events.each do |event|
    case event.type
    when :elevator_moved
      puts "Elevator #{event.elevator_id} moved " \
             "#{event.details[:from_floor]} → #{event.details[:to_floor]}"
    when :doors_opened
      puts "Elevator #{event.elevator_id} opened at floor #{event.floor}"
    when :doors_closed
      puts "Elevator #{event.elevator_id} closed at floor #{event.floor}"
    when :passengers_boarded
      puts "Request #{event.request_id} boarded elevator #{event.elevator_id}"
    when :passengers_exited
      puts "Request #{event.request_id} completed on elevator #{event.elevator_id}"
    end
  end

  raise "simulation did not finish" if controller.tick_number >= 100
end

puts "\nAll #{controller.completed_requests.length} journeys completed."
