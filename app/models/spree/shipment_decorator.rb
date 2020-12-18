# frozen_string_literal: true

module Spree
  module ShipmentDecorator
    def self.prepended(base)
      base.singleton_class.prepend ClassMethods
    end

    module ClassMethods
      def exportable
        query = order(:updated_at)
          .joins(:order)
          .merge(::Spree::Order.complete)

        unless SpreeShipstation.configuration.capture_at_notification
          query = query.where(spree_shipments: {state: ["ready", "canceled"]})
        end

        unless SpreeShipstation.configuration.export_canceled_shipments
          query = query.where.not(spree_shipments: {state: "canceled"})
        end

        query
      end

      def between(from, to)
        condition = <<~SQL.squish
          (spree_shipments.updated_at > :from AND spree_shipments.updated_at < :to) OR
          (spree_orders.updated_at > :from AND spree_orders.updated_at < :to)
        SQL

        joins(:order).where(condition, from: from, to: to)
      end
    end

    ::Spree::Shipment.prepend self
  end
end
