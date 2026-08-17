# frozen_string_literal: true

module Spree
  module Shipstation
    ##
    # Applies a ShipStation shipnotify payload to a Spree shipment.
    #
    # Looks up the shipment by number on the given store and, inside a
    # transaction: captures pending payments if +auto_capture_on_dispatch+ is
    # on, writes the tracking number, and ships the shipment unless it is
    # already shipped.
    #
    class ShipmentNotice
      attr_reader :shipment_number, :shipment_tracking, :store

      class << self
        ##
        # Builds a notice from the shipnotify webhook params.
        #
        # ShipStation's webhook param is named +order_number+ but its value is
        # the shipment number — it mirrors the +<OrderNumber>+ field from the
        # export XML.
        #
        # @param params [Hash] webhook params including +:order_number+ and +:tracking_number+
        # @param store [Spree::Store] store that owns the shipment
        # @return [Spree::Shipstation::ShipmentNotice]
        #
        def from_payload(params, store:)
          new(
            shipment_number: params[:order_number],
            shipment_tracking: params[:tracking_number],
            store: store
          )
        end
      end

      ##
      # @param shipment_number [String] Spree shipment number
      # @param shipment_tracking [String] carrier tracking number
      # @param store [Spree::Store] store that owns the shipment
      #
      def initialize(shipment_number:, shipment_tracking:, store:)
        @shipment_number = shipment_number
        @shipment_tracking = shipment_tracking
        @store = store
      end

      ##
      # Captures pending payments if configured, writes tracking, and ships.
      #
      # @return [Spree::Shipment] the updated shipment
      # @raise [Spree::Shipstation::ShipmentNotFoundError] when the shipment is missing
      # @raise [Spree::Shipstation::MissingTrackingNumberError] when tracking is blank
      # @raise [Spree::Shipstation::PaymentError] when a pending payment cannot be captured
      #
      def apply
        raise ShipmentNotFoundError, shipment_number unless shipment

        ::Spree::Shipment.transaction do
          ship_shipment
        end

        shipment
      end

      private

      def shipment
        @shipment ||= store.shipments.find_by(number: shipment_number)
      end

      def ship_shipment
        raise MissingTrackingNumberError if shipment_tracking.blank?

        # Payment capture is performed synchronously, inside the webhook request and
        # the surrounding transaction, so a capture failure aborts the ship and is
        # reported back to ShipStation as an error (HTTP 400) rather than silently
        # shipping an uncaptured order. ShipStation retries failed webhooks, so the
        # operation is written to be safe to repeat: an already-shipped shipment is
        # not re-shipped (see below) and capture only targets still-pending payments.
        capture_pending_payments! if ::Spree::Config.auto_capture_on_dispatch

        shipment.tracking = shipment_tracking
        shipment.save!

        shipment.ship! unless shipment.shipped?
      end

      def capture_pending_payments!
        shipment.order.payments.pending.each do |payment|
          payment.capture!
        rescue ::Spree::Core::GatewayError
          raise PaymentError.new(payment)
        end
      end
    end
  end
end
