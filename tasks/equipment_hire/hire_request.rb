require "securerandom"
require_relative "hire_item"

class HireRequest
  attr_reader :id, :customer_id, :starts_on, :days, :items

  def initialize(customer_id:, starts_on:, days:, items:)
    unless customer_id.is_a?(Integer) && customer_id.positive?
      raise ArgumentError, "customer_id must be a positive integer"
    end
    raise ArgumentError, "starts_on must be a Date" unless starts_on.is_a?(Date)
    unless days.is_a?(Integer) && days.positive?
      raise ArgumentError, "days must be a positive integer"
    end
    unless items.is_a?(Array) && items.all? { |item| item.is_a?(HireItem) }
      raise ArgumentError, "items must be an array of HireItem objects"
    end
    @id = SecureRandom.uuid
    @customer_id = customer_id
    @starts_on = starts_on
    @days = days
    @items = items
  end
end
