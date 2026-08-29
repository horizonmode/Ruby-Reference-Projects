class SensorMessage
  attr_reader :message_id, :sensor_id, :type, :value, :unit, :recorded_at

  def initialize(message_id:, sensor_id:, type:, value:, unit:, recorded_at:)
    @message_id = message_id
    @sensor_id = sensor_id
    @type = type
    @value = value
    @unit = unit
    @recorded_at = recorded_at

    freeze
  end

  def to_h
    {
      message_id: message_id,
      sensor_id: sensor_id,
      type: type,
      value: value,
      unit: unit,
      recorded_at: recorded_at
    }
  end

  def with(**changes)
    self.class.new(**to_h.merge(changes))
  end
end
