module EquipmentHire
  class Product
    attr_reader :id, :daily_rate, :replacement_value

    def initialize(id:, daily_rate:, replacement_value:)
      raise ArgumentError, "id is required" if id.nil?
      validate_money(daily_rate, :daily_rate)
      validate_money(replacement_value, :replacement_value)

      @id = immutable_id(id)
      @daily_rate = daily_rate
      @replacement_value = replacement_value
      freeze
    end

    private

    def validate_money(value, name)
      unless value.is_a?(Integer) && value.positive?
        raise ArgumentError,
              "#{name} must be a positive integer number of pence"
      end
    end

    def immutable_id(id)
      id.is_a?(String) ? id.dup.freeze : id
    end
  end
end
