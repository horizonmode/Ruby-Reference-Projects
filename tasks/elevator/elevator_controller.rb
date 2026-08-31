require_relative "building"
require_relative "elevator"
require_relative "journey-request"

class ElevatorController
  attr_reader :building, :tick_number

  def initialize(elevators:, scheduler:, building:)
    unless building.is_a?(Building)
      raise ArgumentError, "building must be a Building"
    end
    unless elevators.is_a?(Array) && !elevators.empty? &&
             elevators.all? { |elevator| elevator.is_a?(Elevator) }
      raise ArgumentError, "elevators must be a non-empty array of Elevators"
    end
    unless elevators.map(&:id).uniq.length == elevators.length
      raise ArgumentError, "elevator IDs must be unique"
    end
    unless elevators.all? { |elevator| elevator.building == building }
      raise ArgumentError, "elevators must belong to the controller building"
    end
    unless scheduler.respond_to?(:call)
      raise ArgumentError, "scheduler must respond to call"
    end

    @building = building
    @elevators = elevators.dup.freeze
    @scheduler = scheduler
    @pending_requests = []
    @completed_requests = []
    @events = []
    @requests_by_id = {}
    @request_statuses = {}
    @tick_number = 0
  end

  def elevators
    @elevators.map(&:snapshot).freeze
  end

  def pending_requests
    @pending_requests.dup.freeze
  end

  def completed_requests
    @completed_requests.dup.freeze
  end

  def events
    @events.dup.freeze
  end

  def request_status(request_id)
    @request_statuses[request_id]
  end

  def request_journey(request)
    validate_request(request)
    if @requests_by_id.key?(request.id)
      raise ArgumentError, "request ID must be unique"
    end

    @requests_by_id[request.id] = request
    @request_statuses[request.id] = :pending
    @pending_requests << request

    dispatch_pending_requests
    assigned_elevator_for(request)&.snapshot
  end

  def tick
    @tick_number += 1
    dispatch_pending_requests

    @elevators.each do |elevator|
      outcome = elevator.tick(tick_number: tick_number)
      @events.concat(outcome.events)

      outcome.events.each do |event|
        if event.type == :passengers_boarded
          @request_statuses[event.request_id] = :picked_up
        end
      end

      outcome.completed_requests.each do |request|
        @request_statuses[request.id] = :completed
        @completed_requests << request
      end
    end

    events_for_tick(tick_number)
  end

  def disable_elevator(elevator_id)
    elevator = find_elevator(elevator_id)
    released, new_events = elevator.disable(tick: tick_number)

    released.each do |request|
      @request_statuses[request.id] = :pending
      @pending_requests << request unless @pending_requests.include?(request)
    end
    @events.concat(new_events)

    released
  end

  def enable_elevator(elevator_id)
    elevator = find_elevator(elevator_id)
    @events.concat(elevator.enable(tick: tick_number))
    dispatch_pending_requests
    elevator.snapshot
  end

  private

  def validate_request(request)
    unless request.is_a?(JourneyRequest)
      raise ArgumentError, "request must be a JourneyRequest"
    end
    unless building.include?(request.origin) &&
             building.include?(request.destination)
      raise ArgumentError, "request floors must be inside the building"
    end
  end

  def dispatch_pending_requests
    @pending_requests.dup.each do |request|
      candidates = @elevators.select(&:available?)
      elevator = @scheduler.call(request, candidates)
      next unless elevator

      unless @elevators.include?(elevator)
        raise ArgumentError, "scheduler returned an unknown elevator"
      end
      next unless elevator.can_accept?(request)

      @events << elevator.assign(request, tick: tick_number)
      @request_statuses[request.id] = :assigned
      @pending_requests.delete(request)
    end
  end

  def assigned_elevator_for(request)
    @elevators.find { |elevator| elevator.assigned_requests.include?(request) }
  end

  def find_elevator(elevator_id)
    @elevators.find { |elevator| elevator.id == elevator_id } ||
      raise(ArgumentError, "elevator not found")
  end

  def events_for_tick(tick)
    @events.select { |event| event.tick == tick }.dup.freeze
  end
end
