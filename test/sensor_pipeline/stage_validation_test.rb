require "set"
require_relative "../test_helper"
require_relative "../../tasks/sensor_pipeline/stages/json_decoder"
require_relative "../../tasks/sensor_pipeline/stages/validator"
require_relative "../../tasks/sensor_pipeline/stages/deduplicator"
require_relative "../../tasks/sensor_pipeline/stages/unit_normalizer"
require_relative "../../tasks/sensor_pipeline/stages/severity_classifier"

class StageValidationTest < Minitest::Test
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

  def test_json_decoder_requires_a_string
    result = JsonDecoder.new.call({ message: "not JSON" })

    assert_predicate result, :failure?
    assert_instance_of TypeError, result.error
  end

  def test_validator_requires_a_hash_and_rejects_blank_fields
    assert_predicate Validator.new.call("data"), :failure?

    data = {
      message_id: "   ",
      sensor_id: "sensor-1",
      type: "temperature",
      value: -10,
      unit: "C",
      recorded_at: "2026-08-29T12:00:00Z"
    }

    assert_predicate Validator.new.call(data), :failure?
  end

  def test_deduplicator_validates_its_store_and_input
    assert_raises(ArgumentError) { Deduplicator.new(store: {}) }

    deduplicator = Deduplicator.new(store: Set.new)
    assert_predicate deduplicator.call("message"), :failure?
    assert_predicate deduplicator.call(@message), :pass?
    assert_predicate deduplicator.call(@message), :drop?
  end

  def test_unit_normalizer_requires_a_sensor_message
    result = UnitNormalizer.new.call("message")

    assert_predicate result, :failure?
    assert_instance_of TypeError, result.error
  end

  def test_severity_classifier_validates_constructor_dependencies
    assert_raises(ArgumentError) do
      SeverityClassifier.new(thresholds: "thresholds")
    end
    assert_raises(ArgumentError) do
      SeverityClassifier.new(thresholds: { warning: nil, critical: -5 })
    end
    assert_raises(ArgumentError) do
      SeverityClassifier.new(thresholds: { warning: -5, critical: -12 })
    end
    assert_raises(ArgumentError) do
      SeverityClassifier.new(
        thresholds: {
          warning: -12,
          critical: -5
        },
        clock: Object.new
      )
    end
  end

  def test_severity_classifier_validates_input_and_clock_output
    classifier = build_classifier
    assert_predicate classifier.call("message"), :failure?

    classifier = build_classifier(clock: -> { "now" })
    result = classifier.call(@message)

    assert_predicate result, :failure?
    assert_instance_of TypeError, result.error
  end

  private

  def build_classifier(clock: -> { Time.utc(2026, 8, 29, 13) })
    SeverityClassifier.new(
      thresholds: {
        warning: -12,
        critical: -5
      },
      clock: clock
    )
  end
end
