require_relative "transaction"
require_relative "errors"
require_relative "auditable"
require "time"
require "securerandom"

module Bank
  class Account
    class << self
      attr_accessor :count
    end

    @count = 0 # Initialize the class variable to keep track of the number of accounts
    include Bank::Auditable
    attr_reader :id, :owner_name, :transactions
    MAX_BALANCE = 1_000_000

    def initialize(id:, owner_name:, transactions: [])
      @id = id
      @owner_name = owner_name
      @transactions = transactions
      self.class.count += 1
    end

    def deposit(amount)
      if amount <= 0
        raise Bank::Errors::InvalidAmount, "Amount must be positive"
      end
      audit("Depositing #{amount} to account #{@id}")
      @transactions << Transaction.new(type: :deposit, amount: amount)
    end

    def withdraw(amount)
      if amount <= 0
        raise Bank::Errors::InvalidAmount, "Amount must be positive"
      end
      if amount > balance
        raise Bank::Errors::InsufficientFunds, "Insufficient funds"
      else
        audit("Withdrawing #{amount} from account #{@id}")
        @transactions << Transaction.new(type: :withdrawal, amount: amount)
      end
    end

    def get_count
      self.class.count
    end

    def balance
      # Calculate the balance based on transactions
      # inject is used to accumulate the balance by iterating through each transaction
      @transactions.inject(0) do |sum, transaction|
        case transaction.type
        when :deposit, :transfer_in
          sum + transaction.amount
        when :withdrawal, :transfer_out
          sum - transaction.amount
        else
          sum
        end
      end
    end

    def statement
      @transactions
        .map { |transaction| "#{transaction.type}: #{transaction.amount}" }
        .join("\n")
    end

    def transfer_to(other_account, amount)
      if amount <= 0
        raise Bank::Errors::InvalidAmount, "Amount must be positive"
      end
      if other_account.id == id
        raise ArgumentError, "Cannot transfer to the same account"
      end

      if amount > balance
        raise Bank::Errors::InsufficientFunds, "Insufficient funds"
      else
        audit(
          "Transferring #{amount} from account #{@id} to account #{other_account.id}"
        )
        transfer_id = SecureRandom.uuid
        @transactions << Transaction.new(
          type: :transfer_out,
          amount: amount,
          transfer_id: transfer_id
        )
        other_account.transfer_in(amount, transfer_id: transfer_id)
      end
    end

    def transfer_in(amount, transfer_id:)
      if amount <= 0
        raise Bank::Errors::InvalidAmount, "Amount must be positive"
      end
      audit("Receiving transfer of #{amount} to account #{@id}")
      @transactions << Transaction.new(
        type: :transfer_in,
        amount: amount,
        transfer_id: transfer_id
      )
    end

    def to_h
      {
        id: @id,
        owner_name: @owner_name,
        transactions: @transactions.map(&:to_h)
      }
    end

    def self.from_h(data)
      transactions =
        Array(data[:transactions]).map do |transaction|
          Transaction.from_h(transaction)
        end
      new(
        id: data[:id],
        owner_name: data[:owner_name],
        transactions: transactions
      )
    end
  end
end
