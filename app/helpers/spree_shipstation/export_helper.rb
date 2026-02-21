# frozen_string_literal: true

require "builder"

module SpreeShipstation
  module ExportHelper
    DATE_FORMAT = "%m/%d/%Y %H:%M"

    def self.address(xml, order, type)
      address = order.public_send("#{type}_address")
      return unless address

      tag_name = "#{type.to_s.camelize}To"

      xml.tag!(tag_name) do
        xml.Name name_from(address)
        xml.Company address.company

        if type == :ship
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

    def self.weight(variant)
      value = variant.weight || 0.0

      case variant.weight_unit
      when "lb"
        [value.to_f, "Pounds"]
      when "oz"
        [value.to_f, "Ounces"]
      when "kg"
        [(value * 1000).to_f, "Grams"]
      else
        [value.to_f, "Grams"]
      end
    end

    class << self
      private

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
