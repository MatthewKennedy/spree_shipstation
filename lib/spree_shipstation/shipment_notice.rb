# frozen_string_literal: true

module SpreeShipstation
  class ShipmentNotice
    attr_reader :shipment_number, :shipment_tracking

    class << self
      def from_payload(params)
        new(
          shipment_number: params[:order_number],
          shipment_tracking: params[:tracking_number]
        )
      end
    end

    def initialize(shipment_number:, shipment_tracking:)
      @shipment_number = shipment_number
      @shipment_tracking = shipment_tracking
    end

    def apply(capture: false)
      raise ShipmentNotFoundError, shipment unless shipment

      Spree::Shipment.transaction do
        process_payment(capture: capture)
        ship_shipment
      end

      shipment
    end

    private

    def shipment
      @shipment ||= ::Spree::Shipment.find_by(number: shipment_number)
    end

    def process_payment(capture:)
      return if shipment.order.paid?

      raise OrderNotPaidError, shipment.order unless capture

      shipment.order.payments.pending.each do |payment|
        payment.capture!
      rescue ::Spree::Core::GatewayError
        raise PaymentError, payment
      end
    end

    def ship_shipment
      shipment.tracking = shipment_tracking
      shipment.save!

      unless shipment.shipped?
        shipment.reload.ship!
        shipment.order.updater.update if shipment.order.respond_to?(:updater)
      end
    end
  end
end
