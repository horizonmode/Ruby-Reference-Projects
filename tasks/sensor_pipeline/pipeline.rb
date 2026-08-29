require_relative "stage_result"

class Pipeline
  def initialize(stages:, sink:, error_handler:)
    unless stages.is_a?(Array) && !stages.empty?
      raise ArgumentError, "stages must be a non-empty array"
    end
    unless stages.all? { |stage| stage.respond_to?(:call) }
      raise ArgumentError, "every stage must respond to call"
    end
    unless sink.respond_to?(:call)
      raise ArgumentError, "sink must respond to call"
    end
    unless error_handler.respond_to?(:call)
      raise ArgumentError, "error_handler must respond to call"
    end

    @stages = stages.dup.freeze
    @sink = sink
    @error_handler = error_handler
  end

  def call(input)
    current_value = input
    @stages.each do |stage|
      result = stage.call(current_value)

      unless result.is_a?(StageResult)
        error =
          TypeError.new(
            "#{stage.class} must return StageResult, returned #{result.class}"
          )
        @error_handler.call(error)
        return StageResult.failure(error)
      end

      case
      when result.pass?
        current_value = result.value
      when result.drop?
        return result
      when result.failure?
        @error_handler.call(result.error)
        return result
      end
    end
    @sink.call(current_value)
    StageResult.pass(current_value)
  end
end
