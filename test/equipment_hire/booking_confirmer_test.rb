require_relative "helpers"

class EquipmentHireBookingConfirmerTest < Minitest::Test
  include EquipmentHireTestHelpers

  RecordingInventory =
    Struct.new(:available, :events) do
      def available_for?(_request)
        events << :availability_checked
        available
      end

      def reserve(booking)
        events << :reserved
        booking
      end
    end

  RecordingPayment =
    Struct.new(:accepted, :events) do
      def charge(amount)
        events << [:charged, amount]
        accepted
      end
    end

  RecordingNotifier =
    Struct.new(:events) do
      def notify(_booking)
        events << :notified
      end
    end

  def setup
    @now = Time.utc(2026, 9, 1, 9)
    @events = []
  end

  def test_successful_confirmation_uses_collaborators_in_order
    confirmer = build_confirmer

    booking = confirmer.confirm(build_quote)

    assert_equal "booking-123", booking.id
    assert_equal 1_500, booking.amount_charged
    assert_equal @now, booking.confirmed_at
    assert_equal(
      [:availability_checked, [:charged, 1_500], :reserved, :notified],
      @events
    )
  end

  def test_rechecks_inventory_before_charging
    confirmer = build_confirmer(available: false)

    assert_raises(EquipmentHire::EquipmentUnavailableError) do
      confirmer.confirm(build_quote)
    end
    assert_equal [:availability_checked], @events
  end

  def test_payment_rejection_does_not_reserve_or_notify
    confirmer = build_confirmer(payment_accepted: false)

    assert_raises(EquipmentHire::PaymentRejectedError) do
      confirmer.confirm(build_quote)
    end
    assert_equal [:availability_checked, [:charged, 1_500]], @events
  end

  def test_injected_clock_controls_expiry
    expired_quote = build_quote(created_at: @now - 3_601)
    confirmer = build_confirmer

    assert_raises(EquipmentHire::QuoteExpiredError) do
      confirmer.confirm(expired_quote)
    end
    assert_empty @events
  end

  private

  def build_confirmer(available: true, payment_accepted: true)
    EquipmentHire::BookingConfirmer.new(
      inventory: RecordingInventory.new(available, @events),
      payment_gateway: RecordingPayment.new(payment_accepted, @events),
      notifier: RecordingNotifier.new(@events),
      clock: FixedClock.new(@now),
      id_generator: -> { "booking-123" }
    )
  end
end
