class Stage
  def call(input)
    throw :halt_pipeline if (!input.success)
    next_stage.call(input) unless next_stage.nil?
  end

  def set_next_stage(next_stage)
    unless next_stage.nil? || next_stage.is_a?(Stage)
      raise ArgumentError, "next_stage must be a Stage or nil"
    end
    @next_stage = next_stage
  end

  def self.pass(value)
    @next_stage.call(value) unless @next_stage.nil?
  end

  def self.drop(reason)
    throw :halt_pipeline
  end

  def self.failure(error)
    throw :halt_pipeline
  end

  private

  attr_reader :next_stage
end
