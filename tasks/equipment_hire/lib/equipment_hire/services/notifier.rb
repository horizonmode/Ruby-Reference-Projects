module EquipmentHire
  module Services
    class Notifier
      def notify(booking)
        puts "Notification: booking #{booking.id} confirmed"
      end
    end
  end
end
