module Spree
  module Integrations
    class Shipstation < Spree::Integration

      # --- Username ---
      preference :username, :string
      validates :preferred_username,
                presence: true,
                length: { minimum: 12, maximum: 20 }

      # --- Password ---
      preference :password, :string

      # 1. Base requirements: Presence and Length
      validates :preferred_password,
                presence: true,
                length: { minimum: 22 }

      # 2. Requirement: At least one Special Character
      validates :preferred_password,
                format: {
                  with: /[!@#$%^&*(),.?":{}|<>]/,
                  message: Spree.t("admin.integrations.shipstation.must_contain_at_least_one_special_character")
                },
                allow_blank: true

      # 3. Requirement: At least one Uppercase Letter
      validates :preferred_password,
                format: {
                  with: /[A-Z]/,
                  message: Spree.t("admin.integrations.shipstation.must_contain_at_least_one_uppercase_letter")
                },
                allow_blank: true

      # 4. Requirement: At least one Number
      validates :preferred_password,
                format: {
                  with: /\d/, # \d matches any digit 0-9
                  message: Spree.t("admin.integrations.shipstation.must_contain_at_least_one_number")
                },
                allow_blank: true

      # --- Other Preferences ---
      preference :capture_at_notification, :boolean, default: false

      def self.integration_group
        "Shipping"
      end

      def self.icon_path
        "integration_icons/shipstation-logo.webp"
      end

      def self.integration_name
        Spree.t("admin.integrations.shipstation.brand_name")
      end
    end
  end
end
