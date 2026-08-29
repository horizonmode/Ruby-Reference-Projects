class ClassifiedReading
  attr_reader :message, :severity, :classified_at

  def initialize(message:, severity:, classified_at:)
    @message = message
    @severity = severity
    @classified_at = classified_at
    freeze
  end
end
