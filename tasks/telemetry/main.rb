require_relative "alert_engine"
require_relative "telemetry_reading"
require_relative "telemetry_stream"
require_relative "alert"

readings = [
  TelemetryReading.new(sensor: 1, value: 42, recorded_at: Time.now),
  TelemetryReading.new(sensor: 2, value: 36, recorded_at: Time.now),
  TelemetryReading.new(sensor: 3, value: 58, recorded_at: Time.now)
]

temperature_rule =
  lambda do |reading|
    "Temperature alert for sensor #{reading.sensor}" if reading.value > 50
  end

oxygen_rule =
  lambda do |reading|
    "Oxygen alert for sensor #{reading.sensor}" if reading.value < 40
  end

notifier =
  lambda { |alert| puts "ALERT: #{alert.message} at #{alert.created_at}" }

stream = TelemetryStream.new(source: readings)

engine =
  AlertEngine.new(rules: [temperature_rule, oxygen_rule], notifier: notifier)

engine.process(stream) do |reading, alerts|
  puts "Processed reading from sensor #{reading.sensor}"
  alerts.each { |alert| puts "Generated alert: #{alert.message}" }
end
