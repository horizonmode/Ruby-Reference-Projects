class AlertEngine
  def initialize(rules:, notifier:, clock: -> { Time.now })
    @rules = rules
    @notifier = notifier
    @clock = clock
    @alerts = []
  end

  def process(stream)
    all_alerts = []

    stream.each do |reading|
      reading_alerts = evaluate(reading)
      reading_alerts.each { |alert| @notifier.call(alert) }

      yield reading, reading_alerts if block_given?
      all_alerts.concat(reading_alerts)
    end
    all_alerts
  end

  private

  def evaluate(reading)
    @rules
      .select { |rule| rule.call(reading) }
      .map do |rule|
        Alert.new(
          message: "Alert triggered by #{rule}",
          reading: reading,
          created_at: @clock.call
        )
      end
  end
end
