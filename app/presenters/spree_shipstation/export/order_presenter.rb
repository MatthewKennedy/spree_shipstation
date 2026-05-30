# frozen_string_literal: true

module SpreeShipstation
  module Export
    # Shapes a single Spree::Shipment into the values ShipStation's export XML
    # expects, keeping data-massaging logic out of the Builder template.
    #
    # Note: ShipStation models one "Order" per shipment, so most order-level
    # fields are derived from `shipment.order` while identifiers come from the
    # shipment itself (mirroring the <OrderNumber> = shipment.number contract).
    class OrderPresenter
      attr_reader :shipment

      def initialize(shipment)
        @shipment = shipment
      end

      def order
        shipment.order
      end

      def order_id
        shipment.id
      end

      def order_number
        shipment.number
      end

      def order_status
        shipment.state
      end

      def order_date
        format_date(order.completed_at)
      end

      def last_modified
        format_date([order.completed_at, shipment.updated_at].compact.max)
      end

      def shipping_method_name
        shipment.shipping_method&.name
      end

      def order_total
        order.total
      end

      def tax_total
        order.tax_total
      end

      def ship_total
        order.ship_total
      end

      def custom_field_1
        order.number
      end

      def customer_code
        order.email&.slice(0, 50)
      end

      def bill_address
        order.bill_address
      end

      def ship_address
        order.ship_address
      end

      def items
        shipment.inventory_units.group_by(&:line_item).filter_map do |line_item, units|
          next unless line_item.variant

          ItemPresenter.new(line_item, units)
        end
      end

      private

      def format_date(time)
        time&.strftime(SpreeShipstation::ExportHelper::DATE_FORMAT)
      end
    end
  end
end
