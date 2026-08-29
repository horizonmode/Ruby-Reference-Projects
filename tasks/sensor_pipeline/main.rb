require "json"
require "set"
require "time"

require_relative "pipeline"
require_relative "sensor_source"
require_relative "stages/json_decoder"
require_relative "stages/validator"
require_relative "stages/deduplicator"
require_relative "stages/unit_normalizer"
require_relative "stages/severity_classifier"

thresholds = { warning: -12, critical: -5 }

sink =
  lambda do |reading|
    puts "#{reading.message.sensor_id}: " \
           "#{reading.message.value.round(2)}°C — #{reading.severity}"
  end

error_handler = lambda { |error| warn "Rejected: #{error.message}" }

pipeline =
  Pipeline.new(
    stages: [
      JsonDecoder.new,
      Validator.new,
      Deduplicator.new(store: Set.new),
      UnitNormalizer.new,
      SeverityClassifier.new(thresholds: thresholds)
    ],
    sink: sink,
    error_handler: error_handler
  )

sequence = 0
temperatures = [18.5, 45.0, -4.0]

reader =
  lambda do
    value = temperatures[sequence % temperatures.length]
    sequence += 1

    JSON.generate(
      message_id: "msg-#{sequence}",
      sensor_id: "freezer-7",
      type: "temperature",
      value: value,
      unit: "F",
      recorded_at: Time.now.utc.iso8601
    )
  end

source = SensorSource.new(reader: reader, interval: 1)

source
  .lazy
  .take(3)
  .each do |raw_message|
    result = pipeline.call(raw_message)

    puts "Status: #{result.status}" if result
  end
