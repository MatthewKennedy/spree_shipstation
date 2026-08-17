# frozen_string_literal: true

require "spec_helper"

RSpec.describe(Spree::Shipstation) do
  describe "VERSION" do
    it("is defined") { expect(Spree::Shipstation::VERSION).to be_present }
  end

  describe ".version" do
    it("returns the VERSION as a Gem::Version") do
      expect(Spree::Shipstation.version).to eq(Gem::Version.new(Spree::Shipstation::VERSION))
    end
  end
end
