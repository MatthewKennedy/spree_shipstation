# frozen_string_literal: true

require "spec_helper"

RSpec.describe(Spree::Shipstation::Export::ItemPresenter) do
  let!(:store) { create(:store, default: true) }
  let(:order) { create(:order_ready_to_ship, store: store) }
  let(:shipment) { order.shipments.first }
  let(:line_item) { shipment.inventory_units.first.line_item }
  let(:units) { shipment.inventory_units.select { |unit| unit.line_item == line_item } }

  subject(:presenter) { described_class.new(line_item, units) }

  it("exposes the variant sku") { expect(presenter.sku).to eq(line_item.variant.sku) }

  it("exposes the unit price") { expect(presenter.unit_price).to eq(line_item.price) }

  it("counts the inventory units as the quantity") do
    expect(presenter.quantity).to eq(units.size)
  end

  it("builds a Weight value object from the variant") do
    expect(presenter.weight).to eq(Spree::Shipstation::Export::Weight.from_variant(line_item.variant))
  end

  describe "#name" do
    it("joins the product name with the variant options text, dropping blanks") do
      allow(line_item.variant).to receive(:options_text).and_return("")

      expect(presenter.name).to eq(line_item.variant.product.name)
    end

    it("includes the options text when present") do
      allow(line_item.variant).to receive(:options_text).and_return("Size: L")

      expect(presenter.name).to eq("#{line_item.variant.product.name} Size: L")
    end
  end

  describe "#image" do
    it("prefers a variant image") do
      variant_image = instance_double(Spree::Image)
      allow(line_item.variant).to receive(:images).and_return([variant_image])

      expect(presenter.image).to eq(variant_image)
    end

    it("falls back to the product master image when the variant has none") do
      master_image = instance_double(Spree::Image)
      allow(line_item.variant).to receive(:images).and_return([])
      allow(line_item.variant.product.master).to receive(:images).and_return([master_image])

      expect(presenter.image).to eq(master_image)
    end
  end
end
