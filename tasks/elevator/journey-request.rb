require_relative "building"

class JourneyRequest
  attr_reader :id, :origin, :destination, :passengers

  def initialize(
    id:,
    origin:,
    destination:,
    passengers:,
    building: Building.new
  )
    raise ArgumentError, "id is required" if id.nil?
    unless building.is_a?(Building)
      raise ArgumentError, "building must be a Building"
    end
    unless building.include?(origin)
      raise ArgumentError, "origin must be a valid floor"
    end
    unless building.include?(destination)
      raise ArgumentError, "destination must be a valid floor"
    end
    if origin == destination
      raise ArgumentError, "origin and destination cannot be the same"
    end
    unless passengers.is_a?(Integer) && passengers.positive?
      raise ArgumentError, "passengers must be a positive integer"
    end

    @id = id.is_a?(String) ? id.dup.freeze : id
    @origin = origin
    @destination = destination
    @passengers = passengers
    freeze
  end

  def direction
    origin < destination ? :up : :down
  end
end
