require_relative "../test_helper"
require_relative "../../tasks/sensor_pipeline/sensor_source"

class SensorSourceTest < Minitest::Test
  def test_is_an_enumerable
    source = build_source

    assert_kind_of Enumerable, source
  end

  def test_each_returns_an_enumerator_without_a_block
    source = build_source

    assert_instance_of Enumerator, source.each
  end

  def test_yields_successive_readings_from_the_injected_reader
    sequence = 0
    reader = -> { sequence += 1 }
    source = build_source(reader: reader)

    assert_equal [1, 2, 3], source.lazy.take(3).force
  end

  def test_waits_between_readings_but_not_before_the_first
    delays = []
    sleeper = ->(seconds) { delays << seconds }
    source = build_source(interval: 2, sleeper: sleeper)

    source.lazy.take(3).force

    assert_equal [2, 2], delays
  end

  def test_accepts_a_callable_that_supplies_each_interval
    intervals = [0.25, 0.75].each
    interval = -> { intervals.next }
    delays = []
    sleeper = ->(seconds) { delays << seconds }
    source = build_source(interval: interval, sleeper: sleeper)

    source.lazy.take(3).force

    assert_equal [0.25, 0.75], delays
  end

  def test_supports_standard_lazy_enumerable_operations
    sequence = 0
    reader = -> { sequence += 1 }
    source = build_source(reader: reader)

    result =
      source.lazy.select(&:even?).map { |value| value * 10 }.take(3).force

    assert_equal [20, 40, 60], result
  end

  def test_rejects_a_reader_that_is_not_callable
    error = assert_raises(ArgumentError) { build_source(reader: Object.new) }

    assert_equal "reader must respond to call", error.message
  end

  def test_rejects_a_sleeper_that_is_not_callable
    error = assert_raises(ArgumentError) { build_source(sleeper: Object.new) }

    assert_equal "sleeper must respond to call", error.message
  end

  def test_rejects_an_invalid_interval
    [-1, "one second", nil].each do |interval|
      error = assert_raises(ArgumentError) { build_source(interval: interval) }

      assert_equal "interval must be a non-negative number or callable",
                   error.message
    end
  end

  def test_rejects_an_invalid_value_returned_by_an_interval_callable
    source = build_source(interval: -> { -1 })

    error = assert_raises(ArgumentError) { source.lazy.take(2).force }

    assert_equal "interval callable must return a non-negative number",
                 error.message
  end

  private

  def build_source(
    reader: -> { "reading" },
    interval: 1,
    sleeper: ->(_seconds) {}
  )
    SensorSource.new(reader: reader, interval: interval, sleeper: sleeper)
  end
end
