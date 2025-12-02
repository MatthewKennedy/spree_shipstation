# frozen_string_literal: true

RSpec.describe Spree::Shipment do
  describe ".between" do
    it "returns shipments whose updated_at falls within the given time range" do
      shipment = create(:shipment) { |s| s.update_column(:updated_at, Time.zone.now) }
      expect(described_class.between(Time.zone.yesterday, Time.zone.tomorrow)).to eq([shipment])
    end

    it "returns shipments whose order's updated_at falls within the given time range" do
      order = create(:order) { |o| o.update_column(:updated_at, Time.zone.now) }
      shipment = create(:shipment, order: order)
      expect(described_class.between(Time.zone.yesterday, Time.zone.tomorrow)).to eq([shipment])
    end

    it "does not return shipments whose updated_at does not fall within the given time range" do
      create(:shipment) { |s| s.update_column(:updated_at, Time.zone.now) }
      expect(described_class.between(Time.zone.tomorrow, Time.zone.tomorrow + 1.day)).to eq([])
    end

    it "does not return shipments whose order's updated_at falls within the given time range" do
      order = create(:order) { |o| o.update_column(:updated_at, Time.zone.now) }
      create(:shipment, order: order)
      expect(described_class.between(Time.zone.tomorrow, Time.zone.tomorrow + 1.day)).to eq([])
    end
  end

  describe ".exportable" do
    context "when capture_at_notification is false" do
      it "returns ONLY ready shipments from complete orders" do
        ready_shipment = create(:order_ready_to_ship).shipments.first
        canceled_order = create(:order_ready_to_ship)
        canceled_order.shipments.first.cancel!

        create(:shipped_order)

        expect(described_class.exportable(false)).to eq([ready_shipment])
      end
    end

    context "when capture_at_notification is true" do
      it "returns non-canceled shipments (ready and shipped) from complete orders" do
        ready_shipment = create(:order_ready_to_ship).shipments.first
        shipped_shipment = create(:shipped_order).shipments.first
        canceled_order = create(:order_ready_to_ship)
        canceled_order.shipments.first.cancel!

        expect(described_class.exportable(true)).to match_array([ready_shipment, shipped_shipment])
      end
    end
  end
end
