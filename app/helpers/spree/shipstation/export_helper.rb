# frozen_string_literal: true

require "builder"

module Spree
  module Shipstation
    module ExportHelper
      DATE_FORMAT = "%m/%d/%Y %H:%M"

      def self.bill_address(xml, address)
        render_address(xml, address, "BillTo", include_street: false)
      end

      def self.ship_address(xml, address)
        render_address(xml, address, "ShipTo", include_street: true)
      end

      class << self
        private

        def render_address(xml, address, tag_name, include_street:)
          return unless address

          xml.tag!(tag_name) do
            xml.Name name_from(address)
            xml.Company address.company

            if include_street
              xml.Address1 address.address1
              xml.Address2 address.address2
              xml.City address.city
              xml.State state_from(address)
              xml.PostalCode address.zipcode
              xml.Country address.country&.iso
            end

            xml.Phone address.phone
          end
        end

        def name_from(address)
          return address.name if address.respond_to?(:name)

          address.try(:full_name)
        end

        def state_from(address)
          address.state&.abbr || address.state_name
        end
      end
    end
  end
end
