# frozen_string_literal: true

require "spec_helper"
require "builder"

RSpec.describe Spree::Shipstation::ExportHelper do
  describe "address rendering" do
    let(:xml) { Builder::XmlMarkup.new }

    def address_double(overrides = {})
      defaults = {
        name: "Jane Doe",
        company: "Acme",
        address1: "1 Main St",
        address2: "Apt 2",
        city: "Springfield",
        state: double("State", abbr: "IL"),
        state_name: "Illinois",
        zipcode: "12345",
        country: double("Country", iso: "US"),
        phone: "555-1234"
      }
      double("Address", defaults.merge(overrides))
    end

    describe ".ship_address" do
      it "emits nothing when the address is missing" do
        expect(described_class.ship_address(xml, nil)).to be_nil
        expect(xml.target!).to eq("")
      end

      it "emits the full set of fields" do
        described_class.ship_address(xml, address_double)
        output = xml.target!

        expect(output).to include("<ShipTo>")
        expect(output).to include("<Name>Jane Doe</Name>")
        expect(output).to include("<Address1>1 Main St</Address1>")
        expect(output).to include("<City>Springfield</City>")
        expect(output).to include("<State>IL</State>")
        expect(output).to include("<PostalCode>12345</PostalCode>")
        expect(output).to include("<Country>US</Country>")
        expect(output).to include("<Phone>555-1234</Phone>")
      end

      it "falls back to the state name when no abbreviation is available" do
        described_class.ship_address(xml, address_double(state: nil, state_name: "Illinois"))

        expect(xml.target!).to include("<State>Illinois</State>")
      end

      it "falls back to full_name when the address has no name" do
        address = double("Address",
          company: "Acme",
          address1: "1 Main St",
          address2: nil,
          city: "Springfield",
          state: double("State", abbr: "IL"),
          state_name: "Illinois",
          zipcode: "12345",
          country: double("Country", iso: "US"),
          phone: "555-1234",
          full_name: "Legacy Name")

        described_class.ship_address(xml, address)

        expect(xml.target!).to include("<Name>Legacy Name</Name>")
      end
    end

    describe ".bill_address" do
      it "emits nothing when the address is missing" do
        expect(described_class.bill_address(xml, nil)).to be_nil
        expect(xml.target!).to eq("")
      end

      it "omits street-level fields" do
        described_class.bill_address(xml, address_double)
        output = xml.target!

        expect(output).to include("<BillTo>")
        expect(output).to include("<Name>Jane Doe</Name>")
        expect(output).to include("<Phone>555-1234</Phone>")
        expect(output).not_to include("Address1")
        expect(output).not_to include("PostalCode")
        expect(output).not_to include("Country")
      end
    end
  end
end
