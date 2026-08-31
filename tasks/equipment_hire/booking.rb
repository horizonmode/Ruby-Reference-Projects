require_relative "hire_request"

class Booking
  attr_reader :id, :request

  def initialize(id:, request:)
    @id = id
    @request = request

    freeze
  end
end
