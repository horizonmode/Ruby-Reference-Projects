require "json"
require "set"
require "thread"
require "time"

require_relative "pipeline"
require_relative "sensor_source"
require_relative "stages/json_decoder"
require_relative "stages/validator"
require_relative "stages/deduplicator"
require_relative "stages/unit_normalizer"
require_relative "stages/severity_classifier"

MESSAGE_COUNT = 20
QUEUE_CAPACITY = 2
MIN_SENSOR_INTERVAL = 0.05
MAX_SENSOR_INTERVAL = 0.35
END_OF_STREAM = Object.new.freeze

thresholds = { warning: -12, critical: -5 }

sink =
  lambda do |reading|
    # Simulate a slower database or external service. Because the queue is
    # bounded, the producer waits instead of creating an unlimited backlog.
    sleep 0.15
    puts "Processed #{reading.message.message_id}: " \
           "#{reading.message.value.round(2)}°C — #{reading.severity}"
  end

error_handler = ->(error) { warn "Rejected: #{error.message}" }

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

random = Random.new
random_interval =
  lambda do
    interval = random.rand(MIN_SENSOR_INTERVAL..MAX_SENSOR_INTERVAL)
    puts "Next sensor message in #{interval.round(2)} seconds"
    interval
  end

source = SensorSource.new(reader: reader, interval: random_interval)
queue = SizedQueue.new(QUEUE_CAPACITY)

producer =
  Thread.new do
    Thread.current.name = "sensor-producer"

    begin
      source
        .lazy
        .take(MESSAGE_COUNT)
        .each do |raw_message|
          queue << raw_message
          puts "Queued sensor message"
        end
    ensure
      queue << END_OF_STREAM
    end
  end

processed_count = 0

loop do
  raw_message = queue.pop
  break if raw_message.equal?(END_OF_STREAM)

  result = pipeline.call(raw_message)
  processed_count += 1 if result&.pass?
end

# Thread#value waits for completion and re-raises an exception from the
# producer, unlike silently abandoning a failed background thread.
producer.value

puts "Finished: #{processed_count} messages processed"
