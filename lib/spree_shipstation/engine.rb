# frozen_string_literal: true

require "spree_core"
require "spree_shipstation"

module SpreeShipstation
  class Engine < Rails::Engine
    isolate_namespace Spree
    engine_name "spree_shipstation"

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")).sort.each do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
