require_relative "../test_helper"

class LedgerTest < Minitest::Test
  def setup
    @ada = build_account(id: "account-1", owner_name: "Ada")
    @grace = build_account(id: "account-2", owner_name: "Grace")
    @ledger = Bank::Ledger.new([@ada, @grace])
  end

  def test_creates_and_finds_an_account
    account = @ledger.create_account("Linus")

    assert_equal "Linus", account.owner_name
    assert_same account, @ledger.find_account_by_id(account.id)
  end

  def test_missing_account_returns_nil
    assert_nil @ledger.find_account_by_id("missing")
  end

  def test_transfers_funds_between_accounts
    quietly { @ada.deposit(100) }
    quietly { @ledger.transfer_funds(@ada.id, @grace.id, 30) }

    assert_equal 70, @ada.balance
    assert_equal 30, @grace.balance
  end

  def test_missing_sender_is_rejected
    error =
      assert_raises(Bank::Errors::AccountNotFound) do
        @ledger.transfer_funds("missing", @grace.id, 10)
      end

    assert_equal "From account not found", error.message
  end

  def test_missing_recipient_is_rejected
    error =
      assert_raises(Bank::Errors::AccountNotFound) do
        @ledger.transfer_funds(@ada.id, "missing", 10)
      end

    assert_equal "To account not found", error.message
  end

  def test_all_accounts_returns_a_defensive_array_copy
    returned_accounts = @ledger.all_accounts
    returned_accounts.clear

    assert_equal [@ada, @grace], @ledger.all_accounts
  end
end
