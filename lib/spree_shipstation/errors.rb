# frozen_string_literal: true

module SpreeShipstation
  class Error < StandardError; end

  class OrderNotPaidError < Error
    def initialize(order, *args)
      super("Order #{order.number} is not paid and capture_at_notification is false", *args)
    end
  end

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
end
