# frozen_string_literal: true

xml.instruct!

total_count = @shipments.respond_to?(:total_count) ? @shipments.total_count : @shipments.count

xml.Orders(pages: (total_count / 50.0).ceil) do
  @shipments.each do |shipment|
    order = shipment.order

    next unless order

    xml.Order do
      xml.OrderID shipment.id
      xml.OrderNumber shipment.number

      xml.OrderDate order.completed_at&.strftime(SpreeShipstation::ExportHelper::DATE_FORMAT)
      xml.OrderStatus shipment.state

      last_modified = [order.completed_at, shipment.updated_at].compact.max
      xml.LastModified last_modified&.strftime(SpreeShipstation::ExportHelper::DATE_FORMAT)

      xml.ShippingMethod shipment.shipping_method&.name
      xml.OrderTotal order.total
      xml.TaxAmount order.tax_total
      xml.ShippingAmount order.ship_total
      xml.CustomField1 order.number

      xml.Customer do
        xml.CustomerCode order.email.slice(0, 50)
        SpreeShipstation::ExportHelper.address(xml, order, :bill)
        SpreeShipstation::ExportHelper.address(xml, order, :ship)
      end

      xml.Items do
        shipment.line_items.each do |line|
          variant = line.variant
          next unless variant

          weight_val = variant.weight || 0.0
          raw_unit = line.variant.weight_unit

          case raw_unit
          when "lb"
            weight_units = "Pounds"
          when "oz"
            weight_units = "Ounces"
          when "kg"
            weight_val *= 1000
            weight_units = "Grams"
          else
            weight_units = "Grams"
          end

          xml.Item do
            xml.SKU variant.sku

            name_parts = [variant.product.name, variant.options_text]
            xml.Name name_parts.reject(&:blank?).join(" ")

            image = variant.images.first || variant.product.master.images.first
            xml.ImageUrl image&.attachment&.url

            xml.Weight weight_val.to_f
            xml.WeightUnits weight_units
            xml.Quantity line.quantity
            xml.UnitPrice line.price

            if variant.option_values.present?
              xml.Options do
                variant.option_values.each do |value|
                  xml.Option do
                    xml.Name value.option_type.presentation
                    xml.Value value.name
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
