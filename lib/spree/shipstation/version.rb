# frozen_string_literal: true

module Spree
  module Shipstation
    VERSION = "1.0.0"

    def self.version
      Gem::Version.new(VERSION)
    end
  end
end
