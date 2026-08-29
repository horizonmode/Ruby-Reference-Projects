class Pipeline
  def initialize(stages:, sink:, error_handler:)
    @stages = stages
    @sink = sink
    @error_handler = error_handler
  end

  def call(input)
    current_value = input
    @stages.each do |stage|
      result = stage.call(current_value)
      case
      when result.pass?
        current_value = result.value
      when result.drop?
        return nil
      when result.failure?
        @error_handler.call(result.error)
        return nil
      end
    end
    @sink.call(current_value)
    StageResult.pass(current_value)
  end
end
