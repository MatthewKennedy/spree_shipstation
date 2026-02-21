# frozen_string_literal: true

module Spree
  module ShipmentDecorator
    def self.prepended(base)
      base.scope :exportable, lambda {
        joins(:order)
          .merge(::Spree::Order.complete)
          .where(state: "ready")
          .order(:updated_at)
      }

      base.scope :between, lambda { |from, to|
        range = from..to

        shipment_match = joins(:order).where(updated_at: range)
        order_match = joins(:order).where(spree_orders: {updated_at: range})

        shipment_match.or(order_match).distinct
      }
    end

    ::Spree::Shipment.prepend self
  end
end
