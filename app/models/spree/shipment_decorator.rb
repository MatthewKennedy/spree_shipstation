# frozen_string_literal: true

module Spree
  ##
  # Adds +exportable+ and +between+ scopes to +Spree::Shipment+ so the export
  # endpoint can select ready shipments in a date window.
  #
  module ShipmentDecorator
    def self.prepended(base)
      base.scope :exportable, lambda {
        joins(:order)
          .merge(::Spree::Order.complete)
          .where(state: "ready")
          .order(:updated_at)
          .includes(:order, inventory_units: {line_item: {variant: [:product, :images, {option_values: :option_type}]}})
      }

      base.scope :between, lambda { |from, to|
        return all if from.nil? && to.nil?

        range = from..to

        shipment_match = joins(:order).where(updated_at: range)
        order_match = joins(:order).where(spree_orders: {updated_at: range})

        shipment_match.or(order_match).distinct
      }
    end

    ::Spree::Shipment.prepend self
  end
end
