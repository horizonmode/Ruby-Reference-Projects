require_relative "constants"
class Parcel
  attr_reader :id, :destination, :weight, :priority
  def initialize(id:, destination:, weight:, priority:)
    if !Parcels::PRIORITY_TYPES.include?(priority)
      raise ArgumentError, "Invalid priority type"
    end
    raise ArgumentError, "Weight must be greater than zero" if weight <= 0
    @id = id.dup.freeze
    @destination = destination.dup.freeze
    @weight = weight
    @priority = priority

    freeze
  end
end
