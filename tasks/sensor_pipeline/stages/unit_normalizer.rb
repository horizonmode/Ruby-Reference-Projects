require_relative "../stage_result"
require_relative "../sensor_message"

class UnitNormalizer
  def call(message)
    unless message.is_a?(SensorMessage)
      return(
        StageResult.failure(
          TypeError.new("UnitNormalizer requires a SensorMessage")
        )
      )
    end

    normalized =
      case message.unit
      when :celsius
        message
      when :fahrenheit
        message.with(
          value: fahrenheit_to_celsius(message.value),
          unit: :celsius
        )
      else
        return(
          StageResult.failure(
            ArgumentError.new("Unknown unit: #{message.unit}")
          )
        )
      end

    StageResult.pass(normalized)
  end

  private

  def fahrenheit_to_celsius(value)
    (value - 32) * 5.0 / 9.0
  end
end
