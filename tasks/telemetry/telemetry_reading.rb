class TelemetryReading
  attr_accessor :value, :sensor, :recorded_at
  def initialize(value: nil, sensor: nil, recorded_at: DateTime.now)
    @value = value
    @sensor = sensor
    @recorded_at = recorded_at
    freeze
  end
end
