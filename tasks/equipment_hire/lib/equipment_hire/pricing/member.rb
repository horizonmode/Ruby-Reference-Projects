require_relative "standard"

module EquipmentHire
  module Pricing
    class Member
      DISCOUNT_PERCENT = 10

      def initialize(base: Standard.new)
        unless base.respond_to?(:calculate)
          raise ArgumentError, "base must respond to calculate"
        end

        @base = base
      end

      def calculate(request:, catalog:)
        amount = base.calculate(request: request, catalog: catalog)
        amount - percentage_of(amount, DISCOUNT_PERCENT)
      end

      private

      attr_reader :base

      def percentage_of(amount, percentage)
        (amount * percentage).div(100)
      end
    end
  end
end
