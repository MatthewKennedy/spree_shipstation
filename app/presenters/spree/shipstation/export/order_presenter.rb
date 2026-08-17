# frozen_string_literal: true

module Spree
  module Shipstation
    module Export
      ##
      # Shapes a single +Spree::Shipment+ into the values ShipStation's export XML
      # expects, keeping data-massaging logic out of the Builder template.
      #
      # Note: ShipStation models one "Order" per shipment, so most order-level
      # fields are derived from +shipment.order+ while identifiers come from the
      # shipment itself (mirroring the +<OrderNumber>+ = shipment.number contract).
      #
      class OrderPresenter
        attr_reader :shipment

        ##
        # @param shipment [Spree::Shipment] the shipment to export
        #
        def initialize(shipment)
          @shipment = shipment
        end

        ##
        # @return [Spree::Order]
        #
        def order
          shipment.order
        end

        ##
        # @return [Integer]
        #
        def order_id
          shipment.id
        end

        ##
        # @return [String]
        #
        def order_number
          shipment.number
        end

        ##
        # @return [String]
        #
        def order_status
          shipment.state
        end

        ##
        # @return [String, NilClass]
        #
        def order_date
          format_date(order.completed_at)
        end

        ##
        # @return [String, NilClass]
        #
        def last_modified
          format_date([order.completed_at, shipment.updated_at].compact.max)
        end

        ##
        # @return [String, NilClass]
        #
        def shipping_method_name
          shipment.shipping_method&.name
        end

        ##
        # @return [BigDecimal]
        #
        def order_total
          order.total
        end

        ##
        # @return [BigDecimal]
        #
        def tax_total
          order.tax_total
        end

        ##
        # @return [BigDecimal]
        #
        def ship_total
          order.ship_total
        end

        ##
        # Spree order number, exported as ShipStation CustomField1.
        #
        # @return [String]
        #
        def custom_field_1
          order.number
        end

        ##
        # Email truncated to ShipStation's 50-character customer-code limit.
        #
        # @return [String, NilClass]
        #
        def customer_code
          order.email&.slice(0, 50)
        end

        ##
        # @return [Spree::Address, NilClass]
        #
        def bill_address
          order.bill_address
        end

        ##
        # @return [Spree::Address, NilClass]
        #
        def ship_address
          order.ship_address
        end

        ##
        # One presenter per line item that still has a variant.
        #
        # @return [Array<Spree::Shipstation::Export::ItemPresenter>]
        #
        def items
          shipment.inventory_units.group_by(&:line_item).filter_map do |line_item, units|
            next unless line_item.variant

            ItemPresenter.new(line_item, units)
          end
        end

        private

        def format_date(time)
          time&.strftime(ExportHelper::DATE_FORMAT)
        end
      end
    end
  end
end
