module Bank
  module Errors
    class AccountNotFound < StandardError
    end
    class InsufficientFunds < StandardError
    end
    class InvalidAmount < StandardError
    end
  end
end
