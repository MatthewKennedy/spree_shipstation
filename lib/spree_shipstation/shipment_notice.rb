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

    def apply
      raise ShipmentNotFoundError, shipment unless shipment

      Spree::Shipment.transaction do
        ship_shipment
      end

      shipment
    end

    private

    def shipment
      @shipment ||= ::Spree::Shipment.find_by(number: shipment_number)
    end

    def ship_shipment
      shipment.tracking = shipment_tracking
      shipment.save!

      unless shipment.shipped?
        shipment.reload.ship!
      end
    end
  end
end
