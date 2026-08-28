require "securerandom"
require "time"

module Bank
  class Transaction
    attr_reader :type, :amount, :timestamp, :id, :transfer_id

    TYPES = %i[deposit withdrawal transfer_in transfer_out].freeze

    def initialize(
      type:,
      amount:,
      timestamp: Time.now,
      id: SecureRandom.uuid,
      transfer_id: nil
    )
      unless TYPES.include?(type)
        raise ArgumentError, "Invalid transaction type"
      end

      @type = type
      @amount = amount
      @timestamp = timestamp.dup.freeze
      @id = id.dup.freeze
      @transfer_id = transfer_id&.dup&.freeze
      freeze
    end

    def to_h
      {
        type: type,
        amount: amount,
        timestamp: timestamp.iso8601,
        id: id,
        transfer_id: transfer_id
      }
    end

    def self.from_h(data)
      new(
        type: data[:type].to_sym,
        amount: data[:amount],
        timestamp: Time.parse(data[:timestamp]),
        id: data[:id] || SecureRandom.uuid,
        transfer_id: data[:transfer_id]
      )
    end
  end
end
