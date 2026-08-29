require "time"
require_relative "../sensor_message"
require_relative "../stage_result"

class Validator
  UNIT_NAMES = { "C" => :celsius, "F" => :fahrenheit }.freeze

  def call(data)
    unless data.is_a?(Hash)
      return StageResult.failure(TypeError.new("Validator requires a Hash"))
    end

    validate_required_fields(data)
    validate_type(data[:type])
    validate_value(data[:value])

    unit = UNIT_NAMES[data[:unit]]
    raise ArgumentError, "unit must be C or F" unless unit

    message =
      SensorMessage.new(
        message_id: data[:message_id],
        sensor_id: data[:sensor_id],
        type: :temperature,
        value: data[:value],
        unit: unit,
        recorded_at: Time.iso8601(data[:recorded_at])
      )

    StageResult.pass(message)
  rescue ArgumentError => error
    StageResult.failure(error)
  end

  private

  def validate_required_fields(data)
    required = %i[message_id sensor_id type value unit recorded_at]

    missing =
      required.find do |key|
        value = data[key]
        value.nil? || (value.respond_to?(:empty?) && value.empty?) ||
          (value.is_a?(String) && value.strip.empty?)
      end

    raise ArgumentError, "#{missing} is required" if missing
  end

  def validate_type(type)
    raise ArgumentError, "type must be temperature" unless type == "temperature"
  end

  def validate_value(value)
    raise ArgumentError, "value must be numeric" unless value.is_a?(Numeric)
  end
end
