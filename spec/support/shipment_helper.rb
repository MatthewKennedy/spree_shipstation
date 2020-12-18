# frozen_string_literal: true

module ShipmentHelper
  def create_shipment(options = {})
    FactoryBot.create(:shipment, options).tap do |shipment|
      shipment.update_column(:state, options[:state]) if options[:state]
    end
  end
end

RSpec.configure do |config|
  config.include ShipmentHelper
end
