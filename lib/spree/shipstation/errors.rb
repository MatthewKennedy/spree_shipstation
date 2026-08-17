# frozen_string_literal: true

module Spree
  module Shipstation
    ##
    # Base error for ShipStation integration failures returned as HTTP 400.
    #
    class Error < StandardError; end

    ##
    # Raised when the shipnotify payload names a shipment that does not exist.
    #
    class ShipmentNotFoundError < Error
      ##
      # @param shipment_number [String] the shipment number from the payload
      #
      def initialize(shipment_number, *args)
        super("Could not find shipment with number #{shipment_number}", *args)
      end
    end

    ##
    # Raised when a pending payment cannot be captured during shipnotify.
    #
    class PaymentError < Error
      ##
      # @param payment [Spree::Payment] the payment that failed to capture
      #
      def initialize(payment, *args)
        super("Could not process payment #{payment.id}", *args)
      end
    end

    ##
    # Raised when shipnotify is called without a tracking number.
    #
    class MissingTrackingNumberError < Error
      def initialize(*args)
        super("Tracking number is required", *args)
      end
    end
  end
end
