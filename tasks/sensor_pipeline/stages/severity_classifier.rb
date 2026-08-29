require_relative "../classified_reading"
require_relative "../stage_result"

class SeverityClassifier
  def initialize(thresholds:, clock: -> { Time.now })
    unless thresholds.is_a?(Hash)
      raise ArgumentError, "thresholds must be a Hash"
    end

    warning = thresholds[:warning]
    critical = thresholds[:critical]
    unless valid_number?(warning) && valid_number?(critical)
      raise ArgumentError,
            "warning and critical thresholds must be finite numbers"
    end
    unless warning < critical
      raise ArgumentError, "warning threshold must be lower than critical"
    end
    unless clock.respond_to?(:call)
      raise ArgumentError, "clock must respond to call"
    end

    @thresholds = { warning: warning, critical: critical }.freeze
    @clock = clock
  end

  def call(message)
    unless message.is_a?(SensorMessage)
      return(
        StageResult.failure(
          TypeError.new("SeverityClassifier requires a SensorMessage")
        )
      )
    end

    classified_at = @clock.call
    unless classified_at.is_a?(Time)
      return StageResult.failure(TypeError.new("clock must return a Time"))
    end

    severity =
      if message.value > @thresholds.fetch(:critical)
        :critical
      elsif message.value >= @thresholds.fetch(:warning)
        :warning
      else
        :normal
      end

    classified =
      ClassifiedReading.new(
        message: message,
        severity: severity,
        classified_at: classified_at
      )

    StageResult.pass(classified)
  end

  private

  def valid_number?(value)
    value.is_a?(Numeric) && value.real? && value.finite?
  end
end
