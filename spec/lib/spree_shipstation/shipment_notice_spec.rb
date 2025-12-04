# frozen_string_literal: true

RSpec.describe SpreeShipstation::ShipmentNotice do
  describe "#apply" do
    context "when capture_at_notification is true" do
      before do
        allow(Spree::Config).to receive(:auto_capture_on_dispatch).and_return(true)
      end

      context "when the order is paid" do
        it "ships the order successfully" do
          order = create(:order_ready_to_ship)

          shipment_notice = build_shipment_notice(order.shipments.first, shipment_tracking: "1Z1231234")
          shipment_notice.apply

          expect_order_to_be_shipped(order)
        end
      end

      context "when the order is not paid" do
        context "when the payments can be captured successfully" do
          it "ships the order successfully" do
            order = create(:completed_order_with_pending_payment)

            shipment_notice = build_shipment_notice(order.shipments.first, shipment_tracking: "1Z1231234")
            shipment_notice.apply

            expect_order_to_be_shipped(order)
          end
        end
      end
    end
  end

  private

  def build_shipment_notice(shipment, shipment_tracking: "1Z1231234")
    SpreeShipstation::ShipmentNotice.new(
      shipment_number: shipment.number,
      shipment_tracking: shipment_tracking
    )
  end

  def expect_order_to_be_shipped(order)
    order.reload
    expect(order.shipments.first).to be_shipped
    expect(order.shipments.first.shipped_at).not_to be_nil
    expect(order.shipments.first.tracking).to eq("1Z1231234")
  end
end
