require "minitest/autorun"
require "minitest/mock"
require "json"
require "tmpdir"
require "fileutils"

require_relative "../tasks/bank/bank/transaction"
require_relative "../tasks/bank/bank/account"
require_relative "../tasks/bank/bank/ledger"
require_relative "../tasks/bank/bank/persistence/json_store"

module BankTestHelpers
  def build_account(id: "account-1", owner_name: "Ada")
    Bank::Account.new(id: id, owner_name: owner_name)
  end

  def quietly
    result = nil
    capture_io { result = yield }
    result
  end
end

class Minitest::Test
  include BankTestHelpers
end
