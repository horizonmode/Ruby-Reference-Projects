class Alert
  attr_reader :message, :reading, :created_at
  def initialize(message:, reading:, created_at: Time.now)
    @message = message
    @reading = reading
    @created_at = created_at
    freeze
  end
end
