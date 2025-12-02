# frozen_string_literal: true

module Spree
  module ShipmentDecorator
    def self.prepended(base)
      base.scope :exportable, ->(capture_at_notification = false) {
        current_scope = joins(:order)
          .merge(::Spree::Order.complete)
          .order(:updated_at)
          .where.not(state: 'canceled')

        unless capture_at_notification
          current_scope = current_scope.where(state: ['ready'])
        end

        current_scope
      }

      base.scope :between, ->(from, to) {
        range = from..to

        shipment_match = joins(:order).where(updated_at: range)
        order_match = joins(:order).where(spree_orders: { updated_at: range })

        shipment_match.or(order_match)
      }
    end

    ::Spree::Shipment.prepend self
  end
end
