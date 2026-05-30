require "spec_helper"

RSpec.describe SpreeShipstation do
  describe "VERSION" do
    it "is defined" do
      expect(SpreeShipstation::VERSION).to be_present
    end
  end

  describe ".version" do
    it "returns the VERSION as a Gem::Version" do
      expect(SpreeShipstation.version).to eq(Gem::Version.new(SpreeShipstation::VERSION))
    end
  end
end
