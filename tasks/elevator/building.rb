require_relative "consts"

class Building
  attr_reader :min_floor, :max_floor

  def initialize(
    min_floor: ElevatorConsts::MIN_FLOOR,
    max_floor: ElevatorConsts::MAX_FLOOR
  )
    unless min_floor.is_a?(Integer) && max_floor.is_a?(Integer)
      raise ArgumentError, "building floors must be integers"
    end
    unless min_floor < max_floor
      raise ArgumentError, "min_floor must be lower than max_floor"
    end

    @min_floor = min_floor
    @max_floor = max_floor
    freeze
  end

  def include?(floor)
    floor.is_a?(Integer) && floor.between?(min_floor, max_floor)
  end

  def ==(other)
    other.is_a?(Building) &&
      min_floor == other.min_floor &&
      max_floor == other.max_floor
  end

  alias eql? ==

  def hash
    [self.class, min_floor, max_floor].hash
  end
end
