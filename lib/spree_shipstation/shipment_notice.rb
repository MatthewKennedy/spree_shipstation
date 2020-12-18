# frozen_string_literal: true

module SpreeShipstation
  class ShipmentNotice
    attr_reader :shipment_number, :shipment_tracking

    class << self
      def from_payload(params)
        new(
          shipment_number: params[:order_number],
          shipment_tracking: params[:tracking_number],
        )
      end
    end

    def initialize(shipment_number:, shipment_tracking:)
      @shipment_number = shipment_number
      @shipment_tracking = shipment_tracking
    end

    def apply
      unless shipment
        raise ShipmentNotFoundError, shipment
      end

      process_payment
      ship_shipment

      shipment
    end

    private

    def shipment
      @shipment ||= ::Spree::Shipment.find_by(number: shipment_number)
    end

    def process_payment
      return if shipment.order.paid?
      
      unless SpreeShipstation.configuration.capture_at_notification
        raise OrderNotPaidError, shipment.order
      end

      shipment.order.payments.pending.each do |payment|
        payment.capture!
      rescue ::Spree::Core::GatewayError
        raise PaymentError, payment
      end
    end

    def ship_shipment
      shipment.update_attribute(:tracking, shipment_tracking)

      unless shipment.shipped?
        shipment.reload.ship!
        shipment.touch :shipped_at
        shipment.update!(shipment.order)
      end
    end
  end
end
