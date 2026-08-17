# frozen_string_literal: true

require "spec_helper"

RSpec.describe(Spree::Shipstation::Export::OrderPresenter) do
  let!(:store) { create(:store, default: true) }
  let(:order) { create(:order_ready_to_ship, store: store) }
  let(:shipment) { order.shipments.first }

  subject(:presenter) { described_class.new(shipment) }

  describe "identifiers" do
    it("derives the order id from the shipment") { expect(presenter.order_id).to eq(shipment.id) }

    it("derives the order number from the shipment") { expect(presenter.order_number).to eq(shipment.number) }

    it("exposes the shipment state as the order status") do
      expect(presenter.order_status).to eq(shipment.state)
    end
  end

  describe "order-level fields" do
    it("exposes the order total") { expect(presenter.order_total).to eq(order.total) }

    it("exposes the tax total") { expect(presenter.tax_total).to eq(order.tax_total) }

    it("exposes the ship total") { expect(presenter.ship_total).to eq(order.ship_total) }

    it("exposes the order number as CustomField1") { expect(presenter.custom_field_1).to eq(order.number) }

    it("truncates the customer code to 50 characters") do
      allow(order).to receive(:email).and_return("#{"a" * 60}@example.com")

      expect(presenter.customer_code.length).to eq(50)
    end
  end

  describe "#order_date" do
    it("formats the completed_at timestamp using the shared date format") do
      expect(presenter.order_date)
        .to eq(order.completed_at.strftime(Spree::Shipstation::ExportHelper::DATE_FORMAT))
    end
  end

  describe "#last_modified" do
    it("uses the latest of completed_at and the shipment updated_at") do
      latest = [order.completed_at, shipment.updated_at].compact.max

      expect(presenter.last_modified).to eq(latest.strftime(Spree::Shipstation::ExportHelper::DATE_FORMAT))
    end
  end

  describe "#items" do
    it("returns an ItemPresenter per line item with a variant") do
      expect(presenter.items).to all(be_a(Spree::Shipstation::Export::ItemPresenter))
    end

    it("skips line items without a variant") do
      # Force the order (and its line items) to persist before stubbing variant
      # away — otherwise FactoryBot's line-item validation fails on create.
      shipment
      allow_any_instance_of(Spree::LineItem).to receive(:variant).and_return(nil)

      expect(presenter.items).to be_empty
    end
  end
end
