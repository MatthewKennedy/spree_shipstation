# frozen_string_literal: true

require "spec_helper"
require "builder"

RSpec.describe(Spree::Shipstation::ExportHelper) do
  describe "address rendering" do
    let(:xml) { Builder::XmlMarkup.new }

    # Spree::Address in this Spree line does not implement `name`, so a verifying
    # Address double cannot be used. The helper still reads `name` when present
    # (newer Spree) and falls back to `full_name`.
    def address_double(overrides = {})
      defaults = {
        name: "Jane Doe",
        company: "Acme",
        address1: "1 Main St",
        address2: "Apt 2",
        city: "Springfield",
        state: instance_double(Spree::State, abbr: "IL"),
        state_name: "Illinois",
        zipcode: "12345",
        country: instance_double(Spree::Country, iso: "US"),
        phone: "555-1234"
      }
      double("address", defaults.merge(overrides))
    end

    describe ".ship_address" do
      it("emits nothing when the address is missing") do
        described_class.ship_address(xml, nil)

        expect(xml.target!).to eq("")
      end

      it("emits the ship-to name") do
        described_class.ship_address(xml, address_double)

        expect(xml.target!).to include("<Name>Jane Doe</Name>")
      end

      it("emits street-level fields") do
        described_class.ship_address(xml, address_double)

        expect(xml.target!).to include("<Address1>1 Main St</Address1>")
      end

      it("emits the state abbreviation") do
        described_class.ship_address(xml, address_double)

        expect(xml.target!).to include("<State>IL</State>")
      end

      it("falls back to the state name when no abbreviation is available") do
        described_class.ship_address(xml, address_double(state: nil, state_name: "Illinois"))

        expect(xml.target!).to include("<State>Illinois</State>")
      end

      it("falls back to full_name when the address has no name") do
        address = double(
          "legacy address",
          company: "Acme",
          address1: "1 Main St",
          address2: nil,
          city: "Springfield",
          state: instance_double(Spree::State, abbr: "IL"),
          state_name: "Illinois",
          zipcode: "12345",
          country: instance_double(Spree::Country, iso: "US"),
          phone: "555-1234",
          full_name: "Legacy Name"
        )

        described_class.ship_address(xml, address)

        expect(xml.target!).to include("<Name>Legacy Name</Name>")
      end
    end

    describe ".bill_address" do
      it("emits nothing when the address is missing") do
        described_class.bill_address(xml, nil)

        expect(xml.target!).to eq("")
      end

      it("emits a BillTo name") do
        described_class.bill_address(xml, address_double)

        expect(xml.target!).to include("<Name>Jane Doe</Name>")
      end

      it("omits street-level fields") do
        described_class.bill_address(xml, address_double)

        expect(xml.target!).not_to include("Address1")
      end
    end
  end
end
