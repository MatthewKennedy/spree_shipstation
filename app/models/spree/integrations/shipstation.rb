module Spree
  module Integrations
    class Shipstation < Spree::Integration
      # --- Username ---
      preference :username, :string

      # # 1. Base requirements: Presence and Length
      # validates :preferred_username,
      #   presence: true,
      #   length: {minimum: 10, maximum: 30}

      # # 2. Requirement: Safe Characters Only (Basic Auth Compatible)
      # # Allows: a-z, A-Z, 0-9, ., _, @, +, -
      # validates :preferred_username,
      #   format: {
      #     with: /\A[a-zA-Z0-9._@+\-]+\z/,
      #     message: Spree.t("admin.integrations.shipstation.username_chars_error")
      #   },
      #   allow_blank: true

      # --- Password ---
      preference :password, :string

      # # 1. Base requirements: Presence and Length
      # validates :preferred_password,
      #   presence: true,
      #   length: {minimum: 20, maximum: 60}

      # # 2. Requirement: At least one Special Character
      # validates :preferred_password,
      #   format: {
      #     with: /[!@#$%^&*(),.?":{}|<>]/,
      #     message: Spree.t("admin.integrations.shipstation.must_contain_at_least_one_special_character")
      #   },
      #   allow_blank: true

      # # 3. Requirement: At least one Uppercase Letter
      # validates :preferred_password,
      #   format: {
      #     with: /[A-Z]/,
      #     message: Spree.t("admin.integrations.shipstation.must_contain_at_least_one_uppercase_letter")
      #   },
      #   allow_blank: true

      # # 4. Requirement: At least one Number
      # validates :preferred_password,
      #   format: {
      #     with: /\d/, # \d matches any digit 0-9
      #     message: Spree.t("admin.integrations.shipstation.must_contain_at_least_one_number")
      #   },
      #   allow_blank: true

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
