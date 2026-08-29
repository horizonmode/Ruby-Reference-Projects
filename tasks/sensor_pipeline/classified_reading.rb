require_relative "sensor_message"

class ClassifiedReading
  SEVERITIES = %i[normal warning critical].freeze

  attr_reader :message, :severity, :classified_at

  def initialize(message:, severity:, classified_at:)
    unless message.is_a?(SensorMessage)
      raise ArgumentError, "message must be a SensorMessage"
    end
    raise ArgumentError, "invalid severity" unless SEVERITIES.include?(severity)
    unless classified_at.is_a?(Time)
      raise ArgumentError, "classified_at must be a Time"
    end

    @message = message
    @severity = severity
    @classified_at = classified_at.dup.freeze
    freeze
  end
end
