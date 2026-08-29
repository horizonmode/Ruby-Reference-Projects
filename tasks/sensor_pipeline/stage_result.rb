class StageResult
  STATUSES = %i[pass drop failure].freeze

  attr_reader :status, :value, :reason, :error

  def self.pass(value)
    new(status: :pass, value: value)
  end

  def self.drop(reason)
    new(status: :drop, reason: reason)
  end

  def self.failure(error)
    new(status: :failure, error: error)
  end

  def initialize(status:, value: nil, reason: nil, error: nil)
    unless STATUSES.include?(status)
      raise ArgumentError, "status must be pass, drop, or failure"
    end

    case status
    when :pass
      raise ArgumentError, "a passing result requires a value" if value.nil?
      if reason || error
        raise ArgumentError, "a passing result cannot have a reason or error"
      end
    when :drop
      unless reason.is_a?(String) && !reason.strip.empty?
        raise ArgumentError, "a dropped result requires a reason"
      end
      if value || error
        raise ArgumentError, "a dropped result cannot have a value or error"
      end
    when :failure
      unless error.is_a?(Exception)
        raise ArgumentError, "a failed result requires an exception"
      end
      if value || reason
        raise ArgumentError, "a failed result cannot have a value or reason"
      end
    end

    @status = status
    @value = value
    @reason = reason&.dup&.freeze
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
