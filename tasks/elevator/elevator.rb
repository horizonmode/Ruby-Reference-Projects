require_relative "building"
require_relative "consts"
require_relative "elevator_event"
require_relative "journey-request"

class ElevatorTickResult
  attr_reader :events, :completed_requests

  def initialize(events: [], completed_requests: [])
    @events = events.dup.freeze
    @completed_requests = completed_requests.dup.freeze
    freeze
  end
end

class ElevatorSnapshot
  attr_reader :assigned_requests,
              :capacity,
              :current_floor,
              :direction,
              :door_status,
              :id,
              :onboard_requests,
              :passenger_count,
              :service_status,
              :waiting_requests

  def initialize(elevator)
    @id = elevator.id
    @capacity = elevator.capacity
    @current_floor = elevator.current_floor
    @direction = elevator.direction
    @door_status = elevator.door_status
    @passenger_count = elevator.passenger_count
    @service_status = elevator.service_status
    @assigned_requests = elevator.assigned_requests
    @waiting_requests = elevator.waiting_requests
    @onboard_requests = elevator.onboard_requests
    freeze
  end

  def available?
    service_status == :available
  end

  def out_of_service?
    service_status == :out_of_service
  end

  def idle?
    direction == :idle && assigned_requests.empty?
  end
end

class Elevator
  Assignment = Struct.new(:request, :status, keyword_init: true)

  attr_reader :building,
              :capacity,
              :current_floor,
              :direction,
              :door_status,
              :id,
              :passenger_count,
              :service_status

  def initialize(
    id:,
    building: Building.new,
    capacity: 4,
    current_floor: building.min_floor
  )
    raise ArgumentError, "id is required" if id.nil?
    unless building.is_a?(Building)
      raise ArgumentError, "building must be a Building"
    end
    unless capacity.is_a?(Integer) && capacity.positive?
      raise ArgumentError, "capacity must be a positive integer"
    end
    unless building.include?(current_floor)
      raise ArgumentError, "current_floor must be inside the building"
    end

    @id = id.is_a?(String) ? id.dup.freeze : id
    @building = building
    @capacity = capacity
    @current_floor = current_floor
    @direction = :idle
    @door_status = :closed
    @service_status = :available
    @passenger_count = 0
    @assignments = []
  end

  def assigned_requests
    @assignments.map(&:request).dup.freeze
  end

  def waiting_requests
    assignments_with_status(:waiting).map(&:request).freeze
  end

  def onboard_requests
    assignments_with_status(:onboard).map(&:request).freeze
  end

  def available?
    service_status == :available
  end

  def out_of_service?
    service_status == :out_of_service
  end

  def idle?
    direction == :idle && assigned_requests.empty?
  end

  def snapshot
    ElevatorSnapshot.new(self)
  end

  def can_accept?(request)
    request.is_a?(JourneyRequest) && available? &&
      reserved_passenger_count + request.passengers <= capacity
  end

  def assign(request, tick:)
    unless request.is_a?(JourneyRequest)
      raise ArgumentError, "request must be a JourneyRequest"
    end
    unless @building.include?(request.origin) &&
             @building.include?(request.destination)
      raise ArgumentError, "request floors must be inside the building"
    end
    unless can_accept?(request)
      raise ArgumentError, "elevator cannot accept request"
    end

    @assignments << Assignment.new(request: request, status: :waiting)

    event(
      :request_assigned,
      tick,
      request_id: request.id,
      floor: request.origin,
      details: {
        destination: request.destination,
        passengers: request.passengers
      }
    )
  end

  def disable(tick:)
    return [], [] if out_of_service?

    released = waiting_requests
    @assignments.reject! { |assignment| assignment.status == :waiting }
    @service_status = :out_of_service

    @direction = :idle if onboard_requests.empty? && door_status == :closed

    disabled_event =
      event(
        :elevator_disabled,
        tick,
        floor: current_floor,
        details: {
          released_request_ids: released.map(&:id).freeze
        }
      )

    [released, [disabled_event]]
  end

  def enable(tick:)
    return [] if available?

    @service_status = :available
    [event(:elevator_enabled, tick, floor: current_floor)]
  end

  def tick(tick_number:)
    validate_tick(tick_number)

    return close_doors(tick_number) if door_status == :open
    return become_idle(tick_number) if stops.empty?
    return open_doors_and_service(tick_number) if stop_at_current_floor?

    move_one_floor(tick_number)
  end

  private

  def assignments_with_status(status)
    @assignments.select { |assignment| assignment.status == status }
  end

  def reserved_passenger_count
    @assignments.sum { |assignment| assignment.request.passengers }
  end

  def stops
    if out_of_service?
      onboard_requests.map(&:destination).uniq
    else
      (
        waiting_requests.map(&:origin) + onboard_requests.map(&:destination)
      ).uniq
    end
  end

  def stop_at_current_floor?
    stops.include?(current_floor)
  end

  def close_doors(tick_number)
    @door_status = :closed

    ElevatorTickResult.new(
      events: [event(:doors_closed, tick_number, floor: current_floor)]
    )
  end

  def become_idle(tick_number)
    return ElevatorTickResult.new if direction == :idle

    previous_direction = direction
    @direction = :idle

    ElevatorTickResult.new(
      events: [
        event(
          :direction_changed,
          tick_number,
          floor: current_floor,
          details: {
            from: previous_direction,
            to: :idle
          }
        )
      ]
    )
  end

  def open_doors_and_service(tick_number)
    @door_status = :open
    events = [event(:doors_opened, tick_number, floor: current_floor)]
    completed = exit_passengers(tick_number, events)
    board_passengers(tick_number, events) if available?

    ElevatorTickResult.new(events: events, completed_requests: completed)
  end

  def exit_passengers(tick_number, events)
    exiting =
      assignments_with_status(:onboard).select do |assignment|
        assignment.request.destination == current_floor
      end

    exiting.each do |assignment|
      request = assignment.request
      @passenger_count -= request.passengers
      @assignments.delete(assignment)
      events << event(
        :passengers_exited,
        tick_number,
        request_id: request.id,
        floor: current_floor,
        details: {
          passengers: request.passengers
        }
      )
    end

    exiting.map(&:request)
  end

  def board_passengers(tick_number, events)
    boarding =
      assignments_with_status(:waiting).select do |assignment|
        assignment.request.origin == current_floor
      end

    boarding.each do |assignment|
      request = assignment.request
      next if passenger_count + request.passengers > capacity

      assignment.status = :onboard
      @passenger_count += request.passengers
      events << event(
        :passengers_boarded,
        tick_number,
        request_id: request.id,
        floor: current_floor,
        details: {
          passengers: request.passengers
        }
      )
    end
  end

  def move_one_floor(tick_number)
    target = next_target
    new_direction = target > current_floor ? :up : :down
    from_floor = current_floor
    destination_floor = current_floor + (new_direction == :up ? 1 : -1)

    unless @building.include?(destination_floor)
      raise "elevator attempted to move outside the building"
    end

    @direction = new_direction
    @current_floor = destination_floor

    ElevatorTickResult.new(
      events: [
        event(
          :elevator_moved,
          tick_number,
          floor: current_floor,
          details: {
            from_floor: from_floor,
            to_floor: current_floor,
            direction: direction
          }
        )
      ]
    )
  end

  def next_target
    case direction
    when :up
      stops.select { |floor| floor > current_floor }.min ||
        stops.select { |floor| floor < current_floor }.max
    when :down
      stops.select { |floor| floor < current_floor }.max ||
        stops.select { |floor| floor > current_floor }.min
    else
      stops.min_by { |floor| [(floor - current_floor).abs, floor] }
    end
  end

  def event(type, tick, request_id: nil, floor: nil, details: {})
    ElevatorEvent.new(
      type: type,
      elevator_id: id,
      tick: tick,
      request_id: request_id,
      floor: floor,
      details: details
    )
  end

  def validate_tick(tick_number)
    unless tick_number.is_a?(Integer) && tick_number >= 0
      raise ArgumentError, "tick_number must be a non-negative integer"
    end
  end
end
