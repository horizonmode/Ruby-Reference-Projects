module EquipmentHire
  class Error < StandardError
  end
  class UnknownProductError < Error
  end
  class QuoteExpiredError < Error
  end
  class PaymentRejectedError < Error
  end
  class EquipmentUnavailableError < Error
  end
end
