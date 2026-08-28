require_relative "account"
require_relative "errors"
require "securerandom"

module Bank
  class Ledger
    def initialize(accounts = [])
      @accounts = accounts
    end

    def create_account(owner_name)
      id = SecureRandom.uuid
      account = Account.new(id: id, owner_name: owner_name)
      @accounts << account
      account
    end

    def find_account_by_id(id)
      @accounts.find { |account| account.id == id }
    end

    def transfer_funds(from_account_id, to_account_id, amount)
      from_account = find_account_by_id(from_account_id)
      to_account = find_account_by_id(to_account_id)

      unless from_account
        raise Bank::Errors::AccountNotFound, "From account not found"
      end
      unless to_account
        raise Bank::Errors::AccountNotFound, "To account not found"
      end

      from_account.transfer_to(to_account, amount)
    end

    def all_accounts
      @accounts.dup
    end
  end
end
