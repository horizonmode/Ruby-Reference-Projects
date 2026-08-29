class SensorMessage
  TYPES = %i[temperature].freeze
  UNITS = %i[celsius fahrenheit].freeze

  attr_reader :message_id, :sensor_id, :type, :value, :unit, :recorded_at

  def initialize(message_id:, sensor_id:, type:, value:, unit:, recorded_at:)
    validate_identifier(message_id, :message_id)
    validate_identifier(sensor_id, :sensor_id)
    unless TYPES.include?(type)
      raise ArgumentError, "invalid sensor message type"
    end
    unless valid_number?(value)
      raise ArgumentError, "value must be a finite number"
    end
    unless UNITS.include?(unit)
      raise ArgumentError, "invalid sensor message unit"
    end
    unless recorded_at.is_a?(Time)
      raise ArgumentError, "recorded_at must be a Time"
    end

    @message_id = message_id.dup.freeze
    @sensor_id = sensor_id.dup.freeze
    @type = type
    @value = value
    @unit = unit
    @recorded_at = recorded_at.dup.freeze

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

  private

  def validate_identifier(value, name)
    unless value.is_a?(String) && !value.strip.empty?
      raise ArgumentError, "#{name} must be a non-empty string"
    end
  end

  def valid_number?(value)
    value.is_a?(Numeric) && value.real? && value.finite?
  end
end
