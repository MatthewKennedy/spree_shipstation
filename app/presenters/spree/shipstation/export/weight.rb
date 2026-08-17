# frozen_string_literal: true

module Spree
  module Shipstation
    module Export
      ##
      # Value object converting a +Spree::Variant+'s weight into the
      # (value, unit-label) pair ShipStation's export XML expects.
      #
      # ShipStation accepts Pounds, Ounces, and Grams; any unrecognised Spree
      # weight unit (including a missing weight) falls back to Grams.
      #
      class Weight
        attr_reader :value, :units

        ##
        # @param value [Float] numeric weight
        # @param units [String] ShipStation unit label
        #
        def initialize(value:, units:)
          @value = value
          @units = units
        end

        ##
        # Converts a variant's weight into ShipStation units.
        #
        # @param variant [Spree::Variant]
        # @return [Spree::Shipstation::Export::Weight]
        #
        def self.from_variant(variant)
          amount = (variant.weight || 0.0).to_f

          case variant.weight_unit
          when "lb"
            new(value: amount, units: "Pounds")
          when "oz"
            new(value: amount, units: "Ounces")
          when "kg"
            new(value: amount * 1000, units: "Grams")
          else
            new(value: amount, units: "Grams")
          end
        end

        ##
        # @param other [Object]
        # @return [TrueClass, FalseClass]
        #
        def ==(other)
          other.is_a?(self.class) && value == other.value && units == other.units
        end
        alias_method :eql?, :==

        ##
        # @return [Integer]
        #
        def hash
          [value, units].hash
        end
      end
    end
  end
end
