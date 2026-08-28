require_relative "../test_helper"

class AccountTest < Minitest::Test
  def setup
    @account = build_account
  end

  def test_new_account_has_a_zero_balance
    assert_equal 0, @account.balance
  end

  def test_deposit_increases_the_balance
    quietly { @account.deposit(100) }

    assert_equal 100, @account.balance
    assert_equal :deposit, @account.transactions.last.type
  end

  def test_withdrawal_decreases_the_balance
    quietly do
      @account.deposit(100)
      @account.withdraw(35)
    end

    assert_equal 65, @account.balance
    assert_equal :withdrawal, @account.transactions.last.type
  end

  def test_zero_and_negative_deposits_are_rejected
    [0, -10].each do |amount|
      assert_raises(Bank::Errors::InvalidAmount) { @account.deposit(amount) }
    end

    assert_empty @account.transactions
  end

  def test_zero_and_negative_withdrawals_are_rejected
    quietly { @account.deposit(100) }
    original_transactions = @account.transactions.dup

    [0, -10].each do |amount|
      assert_raises(Bank::Errors::InvalidAmount) { @account.withdraw(amount) }
    end

    assert_equal original_transactions, @account.transactions
  end

  def test_excessive_withdrawal_is_rejected_without_mutation
    quietly { @account.deposit(50) }
    original_transactions = @account.transactions.dup

    assert_raises(Bank::Errors::InsufficientFunds) { @account.withdraw(51) }

    assert_equal 50, @account.balance
    assert_equal original_transactions, @account.transactions
  end

  def test_statement_lists_transactions_in_order
    quietly do
      @account.deposit(100)
      @account.withdraw(25)
    end

    assert_equal "deposit: 100\nwithdrawal: 25", @account.statement
  end

  def test_serialization_round_trip_preserves_the_account
    quietly do
      @account.deposit(100)
      @account.withdraw(25)
    end

    restored = Bank::Account.from_h(@account.to_h)

    assert_equal @account.id, restored.id
    assert_equal @account.owner_name, restored.owner_name
    assert_equal @account.balance, restored.balance
    assert_equal @account.to_h, restored.to_h
  end

  def test_transfer_moves_money_and_links_both_transactions
    recipient = build_account(id: "account-2", owner_name: "Grace")
    quietly do
      @account.deposit(100)
      @account.transfer_to(recipient, 40)
    end

    outgoing = @account.transactions.last
    incoming = recipient.transactions.last

    assert_equal 60, @account.balance
    assert_equal 40, recipient.balance
    assert_equal :transfer_out, outgoing.type
    assert_equal :transfer_in, incoming.type
    refute_nil outgoing.transfer_id
    assert_equal outgoing.transfer_id, incoming.transfer_id
  end

  def test_transfer_to_same_account_is_rejected_without_mutation
    quietly { @account.deposit(100) }
    original_transactions = @account.transactions.dup

    assert_raises(ArgumentError) { @account.transfer_to(@account, 25) }

    assert_equal 100, @account.balance
    assert_equal original_transactions, @account.transactions
  end

  def test_unaffordable_transfer_changes_neither_account
    recipient = build_account(id: "account-2", owner_name: "Grace")
    quietly { @account.deposit(20) }
    sender_transactions = @account.transactions.dup

    assert_raises(Bank::Errors::InsufficientFunds) do
      @account.transfer_to(recipient, 21)
    end

    assert_equal sender_transactions, @account.transactions
    assert_empty recipient.transactions
    assert_equal 20, @account.balance
    assert_equal 0, recipient.balance
  end
end
