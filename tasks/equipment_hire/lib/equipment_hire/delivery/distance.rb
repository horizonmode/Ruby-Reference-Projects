module EquipmentHire
  module Delivery
    class Distance
      COST_PER_MILE_IN_PENCE = 200

      def initialize(miles:)
        unless miles.is_a?(Numeric) && miles >= 0
          raise ArgumentError, "miles must be a non-negative number"
        end

        @miles = miles
      end

      def cost
        (miles * COST_PER_MILE_IN_PENCE).round
      end

      private

      attr_reader :miles
    end
  end
end
