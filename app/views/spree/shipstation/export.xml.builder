xml.instruct!

xml.Orders(pages: @pagy.pages) do
  @shipments.each do |shipment|
    order = Spree::Shipstation::Export::OrderPresenter.new(shipment)

    xml.Order do
      xml.OrderID order.order_id
      xml.OrderNumber order.order_number

      xml.OrderDate order.order_date
      xml.OrderStatus order.order_status
      xml.LastModified order.last_modified

      xml.ShippingMethod order.shipping_method_name
      xml.OrderTotal order.order_total
      xml.TaxAmount order.tax_total
      xml.ShippingAmount order.ship_total
      xml.CustomField1 order.custom_field_1

      xml.Customer do
        xml.CustomerCode order.customer_code
        Spree::Shipstation::ExportHelper.bill_address(xml, order.bill_address)
        Spree::Shipstation::ExportHelper.ship_address(xml, order.ship_address)
      end

      xml.Items do
        order.items.each do |item|
          weight = item.weight
          image = item.image

          xml.Item do
            xml.SKU item.sku
            xml.Name item.name

            image_url = image && url_for(image.attachment)
            xml.ImageUrl image_url if image_url

            xml.Weight weight.value
            xml.WeightUnits weight.units
            xml.Quantity item.quantity
            xml.UnitPrice item.unit_price

            if item.option_values.present?
              xml.Options do
                item.option_values.each do |value|
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
