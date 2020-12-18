# frozen_string_literal: true

require "spree_core"
require "spree_extension"

require 'spree_shipstation/version'
require 'spree_shipstation/engine'
require 'spree_shipstation/configuration'
require 'spree_shipstation/errors'
require 'spree_shipstation/shipment_notice'

module SpreeShipstation
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
