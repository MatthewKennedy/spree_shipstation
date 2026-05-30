# frozen_string_literal: true

require "spec_helper"

RSpec.describe SpreeShipstation::Export::Weight do
  describe ".from_variant" do
    def weight_for(weight:, unit:)
      variant = double("Variant", weight: weight, weight_unit: unit)
      described_class.from_variant(variant)
    end

    it "reports pounds for the lb unit" do
      result = weight_for(weight: 2.5, unit: "lb")

      expect(result.value).to eq(2.5)
      expect(result.units).to eq("Pounds")
    end

    it "reports ounces for the oz unit" do
      result = weight_for(weight: 8, unit: "oz")

      expect(result.value).to eq(8.0)
      expect(result.units).to eq("Ounces")
    end

    it "converts kilograms to grams" do
      result = weight_for(weight: 1.5, unit: "kg")

      expect(result.value).to eq(1500.0)
      expect(result.units).to eq("Grams")
    end

    it "defaults unknown units to grams" do
      result = weight_for(weight: 42, unit: "stone")

      expect(result.value).to eq(42.0)
      expect(result.units).to eq("Grams")
    end

    it "treats a nil weight as zero" do
      result = weight_for(weight: nil, unit: "lb")

      expect(result.value).to eq(0.0)
      expect(result.units).to eq("Pounds")
    end
  end

  describe "value equality" do
    it "considers two weights with the same value and units equal" do
      expect(described_class.new(value: 1.0, units: "Pounds"))
        .to eq(described_class.new(value: 1.0, units: "Pounds"))
    end

    it "considers weights with different units unequal" do
      expect(described_class.new(value: 1.0, units: "Pounds"))
        .not_to eq(described_class.new(value: 1.0, units: "Grams"))
    end
  end
end
