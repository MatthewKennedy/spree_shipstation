# frozen_string_literal: true

module Spree
  module Shipstation
    # Major version tracks Spree's major version: 5.x supports Spree 5.x.
    VERSION = "5.0.0"

    def self.version
      Gem::Version.new(VERSION)
    end
  end
end
