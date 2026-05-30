# frozen_string_literal: true

require "spec_helper"

RSpec.describe SpreeShipstation::Export::OrderPresenter do
  let!(:store) { create(:store, default: true) }
  let(:order) { create(:order_ready_to_ship, store: store) }
  let(:shipment) { order.shipments.first }

  subject(:presenter) { described_class.new(shipment) }

  describe "identifiers and order-level fields" do
    it "derives the order id and number from the shipment" do
      expect(presenter.order_id).to eq(shipment.id)
      expect(presenter.order_number).to eq(shipment.number)
    end

    it "exposes the shipment state as the order status" do
      expect(presenter.order_status).to eq(shipment.state)
    end

    it "exposes order totals and the order number as CustomField1" do
      expect(presenter.order_total).to eq(order.total)
      expect(presenter.tax_total).to eq(order.tax_total)
      expect(presenter.ship_total).to eq(order.ship_total)
      expect(presenter.custom_field_1).to eq(order.number)
    end

    it "truncates the customer code (email) to 50 characters" do
      allow(order).to receive(:email).and_return("#{"a" * 60}@example.com")

      expect(presenter.customer_code.length).to eq(50)
    end
  end

  describe "#order_date and #last_modified" do
    it "formats the completed_at timestamp using the shared date format" do
      expect(presenter.order_date)
        .to eq(order.completed_at.strftime(SpreeShipstation::ExportHelper::DATE_FORMAT))
    end

    it "uses the latest of completed_at and the shipment's updated_at" do
      latest = [order.completed_at, shipment.updated_at].compact.max

      expect(presenter.last_modified).to eq(latest.strftime(SpreeShipstation::ExportHelper::DATE_FORMAT))
    end
  end

  describe "#items" do
    it "returns an ItemPresenter per line item with a variant" do
      expect(presenter.items).to all(be_a(SpreeShipstation::Export::ItemPresenter))
      expect(presenter.items.size).to eq(shipment.inventory_units.group_by(&:line_item).size)
    end

    it "skips line items without a variant" do
      line_item = shipment.inventory_units.first.line_item
      allow_any_instance_of(Spree::LineItem).to receive(:variant).and_return(nil)

      expect(presenter.items).to be_empty
      expect(line_item).to be_present
    end
  end
end
