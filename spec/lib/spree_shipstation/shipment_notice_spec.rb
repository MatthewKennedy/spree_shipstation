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

        context "when a pending payment cannot be captured" do
          it "raises a PaymentError naming the payment" do
            order = create(:completed_order_with_pending_payment)
            payment = pending_payment_for(order)
            allow_any_instance_of(Spree::Payment).to receive(:capture!).and_raise(Spree::Core::GatewayError)

            shipment_notice = build_shipment_notice(order.shipments.first, shipment_tracking: "1Z1231234")

            expect { shipment_notice.apply }
              .to raise_error(SpreeShipstation::PaymentError, "Could not process payment #{payment.id}")
          end

          it "does not ship the shipment" do
            order = create(:completed_order_with_pending_payment)
            pending_payment_for(order)
            allow_any_instance_of(Spree::Payment).to receive(:capture!).and_raise(Spree::Core::GatewayError)

            shipment_notice = build_shipment_notice(order.shipments.first, shipment_tracking: "1Z1231234")

            expect { shipment_notice.apply }.to raise_error(SpreeShipstation::PaymentError)
            expect(order.shipments.first.reload).not_to be_shipped
          end
        end
      end
    end

    context "when auto_capture_on_dispatch is false" do
      before do
        allow(Spree::Config).to receive(:auto_capture_on_dispatch).and_return(false)
      end

      it "ships an already-paid order without capturing payments" do
        order = create(:order_ready_to_ship)
        expect_any_instance_of(Spree::Payment).not_to receive(:capture!)

        shipment_notice = build_shipment_notice(order.shipments.first, shipment_tracking: "1Z1231234")
        shipment_notice.apply

        expect_order_to_be_shipped(order)
      end
    end

    context "when the shipment cannot be found" do
      it "raises a ShipmentNotFoundError naming the shipment number" do
        store = create(:store, default: true)

        shipment_notice = SpreeShipstation::ShipmentNotice.new(
          shipment_number: "DOES-NOT-EXIST",
          shipment_tracking: "1Z1231234",
          store: store
        )

        expect { shipment_notice.apply }
          .to raise_error(SpreeShipstation::ShipmentNotFoundError, /DOES-NOT-EXIST/)
      end
    end

    context "when the tracking number is blank" do
      it "raises a MissingTrackingNumberError" do
        order = create(:order_ready_to_ship)

        shipment_notice = build_shipment_notice(order.shipments.first, shipment_tracking: "")

        expect { shipment_notice.apply }
          .to raise_error(SpreeShipstation::MissingTrackingNumberError, "Tracking number is required")
      end
    end

    context "when the shipment is already shipped" do
      it "updates the tracking number without re-shipping" do
        order = create(:order_ready_to_ship)
        shipment = order.shipments.first
        shipment.ship!

        expect(shipment).not_to receive(:ship!)
        allow(order.store.shipments).to receive(:find_by).and_return(shipment)

        shipment_notice = SpreeShipstation::ShipmentNotice.new(
          shipment_number: shipment.number,
          shipment_tracking: "1Z9999999",
          store: order.store
        )
        shipment_notice.apply

        expect(shipment.reload.tracking).to eq("1Z9999999")
        expect(shipment).to be_shipped
      end
    end
  end

  private

  # Transitions the order's existing (checkout-state) payment into the `pending`
  # state so that `Spree::Payment.pending` returns it, exercising the capture path.
  def pending_payment_for(order)
    order.payments.reload.first.tap { |payment| payment.update_column(:state, "pending") }
  end

  def build_shipment_notice(shipment, shipment_tracking: "1Z1231234")
    SpreeShipstation::ShipmentNotice.new(
      shipment_number: shipment.number,
      shipment_tracking: shipment_tracking,
      store: shipment.order.store
    )
  end

  def expect_order_to_be_shipped(order)
    order.reload
    expect(order.shipments.first).to be_shipped
    expect(order.shipments.first.shipped_at).not_to be_nil
    expect(order.shipments.first.tracking).to eq("1Z1231234")
  end
end
