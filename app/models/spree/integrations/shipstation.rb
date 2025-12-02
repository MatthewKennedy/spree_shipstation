module Spree
  module Integrations
    class Shipstation < Spree::Integration
      preference :username, :string
      preference :password, :string
      preference :capture_at_notification, :boolean, default: false

      validates :preferred_username, presence: true
      validates :preferred_password, presence: true

      def self.integration_group
        'Shipping'
      end

      def self.icon_path
        'integration_icons/shipstation-logo.webp'
      end

      def self.integration_name
        Spree.t('admin.integrations.shipstation.brand_name')
      end
    end
  end
end
