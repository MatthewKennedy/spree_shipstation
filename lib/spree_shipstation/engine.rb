# frozen_string_literal: true

require 'spree_core'
require 'spree_shipstation'

module SpreeShipstation
  class Engine < Rails::Engine
    isolate_namespace Spree
    engine_name 'spree_shipstation'
    config.autoload_paths += %w(#{config.root}/lib)

    initializer "spree_shipstation.preferences", before: "spree.environment" do
      Spree::AppConfiguration.class_eval do
         preference :shipstation_username,     :string
         preference :shipstation_password,     :string
         preference :shipstation_weight_units, :string
         preference :shipstation_ssl_encrypted, :boolean, default: true
         preference :shipstation_require_payment_to_ship, :boolean, default: true
         preference :shipstation_capture_at_notification, :boolean, default: false
         preference :shipstation_export_canceled_shipments, :boolean, default: false
      end
    end

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
