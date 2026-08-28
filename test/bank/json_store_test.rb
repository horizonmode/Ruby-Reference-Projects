require_relative "../test_helper"

class JsonStoreTest < Minitest::Test
  def setup
    @directory = Dir.mktmpdir("ruby-bank-test")
    @path = File.join(@directory, "accounts.json")
    @store = Bank::Persistence::JsonStore.new(@path)
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def test_loading_a_missing_file_returns_an_empty_array
    assert_equal [], @store.load
  end

  def test_save_and_load_preserves_accounts_and_transactions
    ada = build_account(id: "account-1", owner_name: "Ada")
    grace = build_account(id: "account-2", owner_name: "Grace")
    quietly do
      ada.deposit(100)
      ada.transfer_to(grace, 35)
    end

    @store.save([ada, grace])
    restored = @store.load

    assert_equal [ada.to_h, grace.to_h], restored.map(&:to_h)
    assert_equal [65, 35], restored.map(&:balance)
  end

  def test_saving_duplicate_ids_writes_one_account
    original = build_account(id: "duplicate", owner_name: "Ada")
    duplicate = build_account(id: "duplicate", owner_name: "Grace")

    @store.save([original, duplicate])
    stored_data = JSON.parse(File.read(@path))

    assert_equal 1, stored_data.length
    assert_equal "Ada", stored_data.first.fetch("owner_name")
  end

  def test_loading_duplicate_ids_returns_one_account
    account_data = build_account(id: "duplicate").to_h
    File.write(@path, JSON.generate([account_data, account_data]))

    restored = @store.load

    assert_equal 1, restored.length
    assert_equal "duplicate", restored.first.id
  end

  def test_timestamp_survives_a_persistence_round_trip
    timestamp = Time.utc(2026, 8, 28, 10, 30, 45)
    transaction =
      Bank::Transaction.new(
        type: :deposit,
        amount: 100,
        timestamp: timestamp,
        id: "transaction-1"
      )
    account =
      Bank::Account.new(
        id: "account-1",
        owner_name: "Ada",
        transactions: [transaction]
      )

    @store.save([account])
    restored_timestamp = @store.load.first.transactions.first.timestamp

    assert_equal timestamp, restored_timestamp
  end
end
