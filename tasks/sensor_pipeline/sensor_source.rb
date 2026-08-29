class SensorSource
  include Enumerable

  def initialize(reader:, interval:, sleeper: ->(seconds) { sleep(seconds) })
    unless reader.respond_to?(:call)
      raise ArgumentError, "reader must respond to call"
    end
    unless sleeper.respond_to?(:call)
      raise ArgumentError, "sleeper must respond to call"
    end
    unless interval.respond_to?(:call) || valid_interval?(interval)
      raise ArgumentError, "interval must be a non-negative number or callable"
    end

    @reader = reader
    @interval = interval
    @sleeper = sleeper
  end

  def each
    return enum_for(:each) unless block_given?

    first_reading = true

    loop do
      @sleeper.call(next_interval) unless first_reading
      first_reading = false

      yield @reader.call
    end
  end

  private

  def next_interval
    interval = @interval.respond_to?(:call) ? @interval.call : @interval

    unless valid_interval?(interval)
      raise ArgumentError, "interval callable must return a non-negative number"
    end

    interval
  end

  def valid_interval?(interval)
    interval.is_a?(Numeric) && interval >= 0
  end
end
