class ElevatorEvent
  TYPES = %i[
    elevator_moved
    doors_opened
    doors_closed
    direction_changed
    request_assigned
    passengers_boarded
    passengers_exited
    elevator_disabled
    elevator_enabled
  ].freeze

  attr_reader :type, :elevator_id, :tick, :request_id, :floor, :details

  def initialize(
    type:,
    elevator_id:,
    tick:,
    request_id: nil,
    floor: nil,
    details: {}
  )
    raise ArgumentError, "invalid event type" unless TYPES.include?(type)
    raise ArgumentError, "elevator_id is required" if elevator_id.nil?
    unless tick.is_a?(Integer) && tick >= 0
      raise ArgumentError, "tick must be a non-negative integer"
    end
    raise ArgumentError, "details must be a Hash" unless details.is_a?(Hash)

    @type = type
    @elevator_id =
      elevator_id.is_a?(String) ? elevator_id.dup.freeze : elevator_id
    @tick = tick
    @request_id = request_id.is_a?(String) ? request_id.dup.freeze : request_id
    @floor = floor
    @details = details.dup.freeze
    freeze
  end
end
