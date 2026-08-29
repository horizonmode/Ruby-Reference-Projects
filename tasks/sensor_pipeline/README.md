# Sensor Message Pipeline

A staged processing system that decodes, validates, deduplicates, normalizes,
classifies, and delivers messages produced by temperature sensors.

## Topics included

- Pipeline architecture and ordered transformations
- A shared callable stage contract
- Result objects for passing, dropping, and failing messages
- Dependency injection for stages, stores, clocks, sinks, and error handlers
- Custom collections with `Enumerable`
- Implementing `each` and returning an `Enumerator`
- Infinite sources and lazy enumeration
- Injecting time delays for deterministic tests
- Blocks, Procs, lambdas, and callable objects
- Immutable message and result objects
- JSON parsing
- Input validation and custom failure messages
- Unit conversion without mutating input
- Deduplication with an injected store
- Severity classification with injected thresholds
- Automated testing with Minitest

## Run

From the repository root:

```bash
ruby tasks/sensor_pipeline/main.rb
```

Run the producer-consumer version backed by a bounded `SizedQueue`:

```bash
ruby tasks/sensor_pipeline/main_queue.rb
```

In the queue version, a producer thread generates readings independently while
the main thread removes and processes them. The bounded queue applies
backpressure when message production is faster than processing, and a unique
sentinel object signals the end of the stream.

## Consume the sensor source

`SensorSource` yields its first reading immediately and waits for the configured
interval before each later reading. The interval may be a fixed number:

```ruby
source = SensorSource.new(reader: reader, interval: 2)

source.lazy.take(5).each do |raw_message|
  pipeline.call(raw_message)
end
```

It may also be a callable that produces a new interval for every reading:

```ruby
random = Random.new
random_interval = -> { random.rand(0.1..1.0) }

source = SensorSource.new(reader: reader, interval: random_interval)
```

The queue example uses this form to simulate sensor messages arriving at
unpredictable times.

Because the source is infinite, use an operation such as `take` when a consumer
should stop after a finite number of readings.

## Tests

Run the sensor-source tests:

```bash
bundle exec ruby test/sensor_pipeline/sensor_source_test.rb
```
