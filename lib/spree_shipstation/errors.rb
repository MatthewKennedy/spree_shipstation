# frozen_string_literal: true

module SpreeShipstation
  class Error < StandardError; end

  class ShipmentNotFoundError < Error
    def initialize(shipment_number, *args)
      super("Could not find shipment with number #{shipment_number}", *args)
    end
  end

  class PaymentError < Error
    def initialize(payment, *args)
      super("Could not process payment #{payment.id}", *args)
    end
  end

  class MissingTrackingNumberError < Error
    def initialize(*args)
      super("Tracking number is required", *args)
    end
  end
end
