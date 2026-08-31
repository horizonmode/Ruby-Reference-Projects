require_relative "elevator"

class NearestElevatorScheduler
  def call(request, elevators)
    unless request.is_a?(JourneyRequest)
      raise ArgumentError, "request must be a JourneyRequest"
    end
    unless elevators.respond_to?(:select)
      raise ArgumentError, "elevators must be a collection"
    end

    candidates = elevators.select { |elevator| elevator.can_accept?(request) }

    candidates.min_by do |elevator|
      [
        preference_rank(elevator, request),
        (elevator.current_floor - request.origin).abs,
        id_sort_key(elevator.id)
      ]
    end
  end

  private

  def preference_rank(elevator, request)
    return 0 if moving_toward_request?(elevator, request)
    return 1 if elevator.direction == :idle

    2
  end

  def moving_toward_request?(elevator, request)
    return false unless elevator.direction == request.direction

    case request.direction
    when :up
      elevator.current_floor <= request.origin
    when :down
      elevator.current_floor >= request.origin
    end
  end

  def id_sort_key(id)
    id.is_a?(Numeric) ? [0, id] : [1, id.to_s]
  end
end

# A short name retained for the exercise's original public API.
Scheduler = NearestElevatorScheduler
