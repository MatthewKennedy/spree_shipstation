# frozen_string_literal: true

module Spree
  module Shipstation
    module Export
      # Shapes a shipment line item (a line item plus its inventory units) into the
      # values ShipStation's export XML expects for an <Item>.
      class ItemPresenter
        attr_reader :line_item, :units

        def initialize(line_item, units)
          @line_item = line_item
          @units = units
        end

        def variant
          @variant ||= line_item.variant
        end

        def sku
          variant.sku
        end

        def name
          [variant.product.name, variant.options_text].reject(&:blank?).join(" ")
        end

        # The Spree::Image to advertise, or nil. URL generation stays in the view
        # because it depends on Rails route/URL helpers.
        def image
          variant.images.first || variant.product.master.images.first
        end

        def weight
          Weight.from_variant(variant)
        end

        def quantity
          units.size
        end

        def unit_price
          line_item.price
        end

        def option_values
          variant.option_values
        end
      end
    end
  end
end
