require_relative "../classified_reading"
require_relative "../stage_result"

class SeverityClassifier
  def initialize(thresholds:, clock: -> { Time.now })
    @thresholds = thresholds
    @clock = clock
  end

  def call(message)
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
        classified_at: @clock.call
      )

    StageResult.pass(classified)
  end
end
