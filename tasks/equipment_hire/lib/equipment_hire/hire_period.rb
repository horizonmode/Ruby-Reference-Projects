require "date"

module EquipmentHire
  class HirePeriod
    attr_reader :starts_on, :days

    def initialize(starts_on:, days:)
      unless starts_on.is_a?(Date)
        raise ArgumentError, "starts_on must be a Date"
      end
      unless days.is_a?(Integer) && days.positive?
        raise ArgumentError, "days must be a positive integer"
      end

      @starts_on = starts_on
      @days = days
      freeze
    end

    def ends_on
      starts_on + days
    end

    def dates
      (starts_on...ends_on)
    end

    def includes_weekend?
      dates.any? { |date| date.saturday? || date.sunday? }
    end

    def overlaps?(other)
      unless other.respond_to?(:starts_on) && other.respond_to?(:ends_on)
        raise ArgumentError, "other must behave like a hire period"
      end

      starts_on < other.ends_on && other.starts_on < ends_on
    end
  end
end
