class StageResult
  attr_reader :status, :value, :reason, :error

  def self.pass(value)
    new(status: :pass, value: value, reason: nil, error: nil)
  end

  def self.drop(reason)
    new(status: :drop, value: nil, reason: reason, error: nil)
  end

  def self.failure(error)
    new(status: :failure, value: nil, reason: nil, error: error)
  end

  def initialize(status:, value: nil, reason: nil, error: nil)
    @status = status
    @value = value
    @reason = reason
    @error = error
    freeze
  end

  def pass?
    status == :pass
  end

  def drop?
    status == :drop
  end

  def failure?
    status == :failure
  end
end
