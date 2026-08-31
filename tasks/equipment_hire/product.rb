class Product
  attr_reader :id, :daily_rate, :replacement_value
  PRODUCTIDs = %i[drill ladder generator].freeze
  def initialize(id:, daily_rate:, replacement_value:)
    unless PRODUCTIDs.include?(id)
      raise ArgumentError, "id must be one of #{PRODUCTIDs.join(", ")}"
    end
    unless daily_rate.is_a?(Numeric) && daily_rate.positive?
      raise ArgumentError, "daily_rate must be a positive number"
    end
    unless replacement_value.is_a?(Numeric) && replacement_value.positive?
      raise ArgumentError, "replacement_value must be a positive number"
    end
    @id = id
    @daily_rate = daily_rate
    @replacement_value = replacement_value
    freeze
  end
end
