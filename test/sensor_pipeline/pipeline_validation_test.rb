require_relative "../test_helper"
require_relative "../../tasks/sensor_pipeline/pipeline"

class PipelineValidationTest < Minitest::Test
  def test_requires_a_non_empty_array_of_callable_stages
    [nil, "stage", []].each do |stages|
      assert_raises(ArgumentError) { build_pipeline(stages: stages) }
    end

    assert_raises(ArgumentError) { build_pipeline(stages: [Object.new]) }
  end

  def test_requires_callable_sink_and_error_handler
    assert_raises(ArgumentError) { build_pipeline(sink: Object.new) }
    assert_raises(ArgumentError) { build_pipeline(error_handler: Object.new) }
  end

  def test_rejects_a_stage_that_does_not_return_a_stage_result
    errors = []
    pipeline =
      build_pipeline(
        stages: [->(_input) { "not a result" }],
        error_handler: ->(error) { errors << error }
      )

    result = pipeline.call("input")

    assert_predicate result, :failure?
    assert_instance_of TypeError, result.error
    assert_equal [result.error], errors
  end

  def test_stops_and_returns_a_dropped_result
    sink_values = []
    later_stage_called = false
    stages = [
      ->(_input) { StageResult.drop("duplicate") },
      ->(input) do
        later_stage_called = true
        StageResult.pass(input)
      end
    ]
    pipeline =
      build_pipeline(stages: stages, sink: ->(value) { sink_values << value })

    result = pipeline.call("input")

    assert_predicate result, :drop?
    refute later_stage_called
    assert_empty sink_values
  end

  def test_sends_a_failure_to_the_error_handler
    error = ArgumentError.new("invalid message")
    errors = []
    pipeline =
      build_pipeline(
        stages: [->(_input) { StageResult.failure(error) }],
        error_handler: ->(received) { errors << received }
      )

    result = pipeline.call("input")

    assert_predicate result, :failure?
    assert_equal [error], errors
  end

  private

  def build_pipeline(
    stages: [->(input) { StageResult.pass(input) }],
    sink: ->(_value) {},
    error_handler: ->(_error) {}
  )
    Pipeline.new(stages: stages, sink: sink, error_handler: error_handler)
  end
end
