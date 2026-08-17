# frozen_string_literal: true

require "spec_helper"

RSpec.describe(Spree::Shipstation::Export::Weight) do
  describe ".from_variant" do
    def weight_for(weight:, unit:)
      variant = instance_double(Spree::Variant, weight: weight, weight_unit: unit)
      described_class.from_variant(variant)
    end

    it("reports pounds for the lb unit") do
      expect(weight_for(weight: 2.5, unit: "lb")).to eq(described_class.new(value: 2.5, units: "Pounds"))
    end

    it("reports ounces for the oz unit") do
      expect(weight_for(weight: 8, unit: "oz")).to eq(described_class.new(value: 8.0, units: "Ounces"))
    end

    it("converts kilograms to grams") do
      expect(weight_for(weight: 1.5, unit: "kg")).to eq(described_class.new(value: 1500.0, units: "Grams"))
    end

    it("defaults unknown units to grams") do
      expect(weight_for(weight: 42, unit: "stone")).to eq(described_class.new(value: 42.0, units: "Grams"))
    end

    it("treats a nil weight as zero") do
      expect(weight_for(weight: nil, unit: "lb")).to eq(described_class.new(value: 0.0, units: "Pounds"))
    end
  end

  describe "value equality" do
    it("considers two weights with the same value and units equal") do
      expect(described_class.new(value: 1.0, units: "Pounds"))
        .to eq(described_class.new(value: 1.0, units: "Pounds"))
    end

    it("considers weights with different units unequal") do
      expect(described_class.new(value: 1.0, units: "Pounds"))
        .not_to eq(described_class.new(value: 1.0, units: "Grams"))
    end
  end
end
