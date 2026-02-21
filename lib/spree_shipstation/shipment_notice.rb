# frozen_string_literal: true

module SpreeShipstation
  class ShipmentNotice
    attr_reader :shipment_number, :shipment_tracking, :store

    class << self
      def from_payload(params, store:)
        new(
          # ShipStation's webhook param is named `order_number` but its value is the
          # shipment number — it mirrors the <OrderNumber> field from the export XML.
          shipment_number: params[:order_number],
          shipment_tracking: params[:tracking_number],
          store: store
        )
      end
    end

    def initialize(shipment_number:, shipment_tracking:, store:)
      @shipment_number = shipment_number
      @shipment_tracking = shipment_tracking
      @store = store
    end

    def apply
      raise ShipmentNotFoundError, shipment_number unless shipment

      Spree::Shipment.transaction do
        ship_shipment
      end

      shipment
    end

    private

    def shipment
      @shipment ||= store.shipments.find_by(number: shipment_number)
    end

    def ship_shipment
      capture_pending_payments! if Spree::Config.auto_capture_on_dispatch

      shipment.tracking = shipment_tracking
      shipment.save!

      shipment.reload.ship! unless shipment.shipped?
    end

    def capture_pending_payments!
      shipment.order.payments.pending.each do |payment|
        payment.capture!
      rescue Spree::Core::GatewayError
        raise PaymentError.new(payment)
      end
    end
  end
end
