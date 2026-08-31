module EquipmentHire
  module Delivery
    class Corporate
      def initialize(base:)
        unless base.respond_to?(:cost)
          raise ArgumentError, "base must respond to cost"
        end

        @base = base
      end

      def cost
        0
      end
    end
  end
end
