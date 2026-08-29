require_relative "../test_helper"
require_relative "../../tasks/sensor_pipeline/stage"
require_relative "../../tasks/sensor_pipeline/stage_result"
require_relative "../../tasks/sensor_pipeline/sensor_message"
require_relative "../../tasks/sensor_pipeline/classified_reading"

class StageResultValidationTest < Minitest::Test
  def test_factory_methods_create_valid_results
    error = ArgumentError.new("invalid")

    assert_predicate StageResult.pass("message"), :pass?
    assert_predicate StageResult.drop("duplicate"), :drop?
    assert_predicate StageResult.failure(error), :failure?
  end

  def test_rejects_an_unknown_status
    assert_raises(ArgumentError) { StageResult.new(status: :unknown) }
  end

  def test_pass_requires_a_value_and_no_failure_details
    assert_raises(ArgumentError) { StageResult.pass(nil) }
    assert_raises(ArgumentError) do
      StageResult.new(status: :pass, value: "message", reason: "unexpected")
    end
  end

  def test_drop_requires_a_non_empty_reason
    [nil, "", "  "].each do |reason|
      assert_raises(ArgumentError) { StageResult.drop(reason) }
    end
  end

  def test_failure_requires_an_exception
    assert_raises(ArgumentError) { StageResult.failure("invalid") }
  end
end

class SensorMessageValidationTest < Minitest::Test
  def test_accepts_valid_parameters_and_copies_mutable_values
    message_id = +"msg-1"
    sensor_id = +"sensor-1"
    recorded_at = Time.utc(2026, 8, 29, 12)
    message =
      build_message(
        message_id: message_id,
        sensor_id: sensor_id,
        recorded_at: recorded_at
      )

    message_id << "-changed"
    sensor_id << "-changed"

    assert_equal "msg-1", message.message_id
    assert_equal "sensor-1", message.sensor_id
    assert_predicate message, :frozen?
    assert_predicate message.recorded_at, :frozen?
  end

  def test_requires_non_empty_identifiers
    [nil, "", "  ", :symbol].each do |value|
      assert_raises(ArgumentError) { build_message(message_id: value) }
      assert_raises(ArgumentError) { build_message(sensor_id: value) }
    end
  end

  def test_rejects_invalid_types_units_values_and_timestamps
    assert_raises(ArgumentError) { build_message(type: :humidity) }
    assert_raises(ArgumentError) { build_message(unit: :kelvin) }
    assert_raises(ArgumentError) { build_message(value: "cold") }
    assert_raises(ArgumentError) { build_message(value: Float::INFINITY) }
    assert_raises(ArgumentError) { build_message(recorded_at: "now") }
  end

  private

  def build_message(
    message_id: "msg-1",
    sensor_id: "sensor-1",
    type: :temperature,
    value: -10,
    unit: :celsius,
    recorded_at: Time.utc(2026, 8, 29, 12)
  )
    SensorMessage.new(
      message_id: message_id,
      sensor_id: sensor_id,
      type: type,
      value: value,
      unit: unit,
      recorded_at: recorded_at
    )
  end
end

class ClassifiedReadingValidationTest < Minitest::Test
  def setup
    @message =
      SensorMessage.new(
        message_id: "msg-1",
        sensor_id: "sensor-1",
        type: :temperature,
        value: -10,
        unit: :celsius,
        recorded_at: Time.utc(2026, 8, 29, 12)
      )
  end

  def test_accepts_valid_parameters
    reading =
      ClassifiedReading.new(
        message: @message,
        severity: :warning,
        classified_at: Time.utc(2026, 8, 29, 13)
      )

    assert_predicate reading, :frozen?
    assert_predicate reading.classified_at, :frozen?
  end

  def test_rejects_invalid_parameters
    assert_raises(ArgumentError) do
      ClassifiedReading.new(
        message: Object.new,
        severity: :warning,
        classified_at: Time.now
      )
    end
    assert_raises(ArgumentError) do
      ClassifiedReading.new(
        message: @message,
        severity: :urgent,
        classified_at: Time.now
      )
    end
    assert_raises(ArgumentError) do
      ClassifiedReading.new(
        message: @message,
        severity: :warning,
        classified_at: "now"
      )
    end
  end
end

class StageContractTest < Minitest::Test
  def test_base_stage_requires_subclasses_to_implement_call
    assert_raises(NotImplementedError) { Stage.new.call("input") }
  end
end
