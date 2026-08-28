require "json"
require_relative "../account"

module Bank
  module Persistence
    # JsonStore is a simple JSON-based persistence layer for storing and retrieving account data.
    class JsonStore
      def initialize(file_path)
        @file_path = file_path
      end

      def load
        return [] unless File.exist?(@file_path)

        raw_accounts = JSON.parse(File.read(@file_path), symbolize_names: true)
        return [] unless raw_accounts.is_a?(Array)

        raw_accounts
          .filter_map do |account_data|
            next unless account_data.is_a?(Hash)

            Account.from_h(account_data)
          end
          .uniq(&:id)
      end

      def save(accounts)
        unique_accounts = accounts.uniq(&:id)
        File.write(
          @file_path,
          JSON.pretty_generate(unique_accounts.map(&:to_h))
        )
      end
    end
  end
end
