require_relative "../test_helper"

class TransactionTest < Minitest::Test
  def test_accepts_every_supported_type
    Bank::Transaction::TYPES.each do |type|
      transaction = Bank::Transaction.new(type: type, amount: 10)
      assert_equal type, transaction.type
    end
  end

  def test_rejects_an_unsupported_type
    error =
      assert_raises(ArgumentError) do
        Bank::Transaction.new(type: :refund, amount: 10)
      end

    assert_equal "Invalid transaction type", error.message
  end

  def test_generates_an_id_by_default
    transaction = Bank::Transaction.new(type: :deposit, amount: 10)

    refute_nil transaction.id
    refute_empty transaction.id
  end

  def test_preserves_supplied_identifiers
    transaction =
      Bank::Transaction.new(
        type: :transfer_out,
        amount: 25,
        id: "transaction-1",
        transfer_id: "transfer-1"
      )

    assert_equal "transaction-1", transaction.id
    assert_equal "transfer-1", transaction.transfer_id
  end

  def test_is_immutable
    transaction = Bank::Transaction.new(type: :deposit, amount: 10)

    assert_predicate transaction, :frozen?
    assert_predicate transaction.id, :frozen?
    assert_predicate transaction.timestamp, :frozen?
    assert_raises(FrozenError) do
      transaction.instance_variable_set(:@amount, 20)
    end
  end

  def test_copies_the_timestamp_before_freezing_it
    timestamp = Time.utc(2026, 8, 28, 10, 30)
    transaction =
      Bank::Transaction.new(type: :deposit, amount: 10, timestamp: timestamp)

    refute_same timestamp, transaction.timestamp
    refute_predicate timestamp, :frozen?
    assert_predicate transaction.timestamp, :frozen?
  end

  def test_serialization_round_trip_preserves_values
    original =
      Bank::Transaction.new(
        type: :transfer_in,
        amount: 75.5,
        timestamp: Time.utc(2026, 8, 28, 10, 30),
        id: "transaction-1",
        transfer_id: "transfer-1"
      )

    restored = Bank::Transaction.from_h(original.to_h)

    assert_equal original.to_h, restored.to_h
  end
end
