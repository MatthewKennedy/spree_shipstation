# frozen_string_literal: true

module SpreeShipstation
  class Configuration
    attr_accessor :username, :password, :weight_units, :ssl_encrypted, :capture_at_notification, :export_canceled_shipments
  end
end
