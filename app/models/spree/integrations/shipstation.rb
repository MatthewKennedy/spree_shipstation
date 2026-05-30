# frozen_string_literal: true

module Spree
  module Integrations
    class Shipstation < Spree::Integration
      preference :username, :string

      validates :preferred_username,
        presence: true,
        length: {minimum: 10, maximum: 30}

      # Restrict to characters that are safe to send in an HTTP Basic Auth header:
      # a-z, A-Z, 0-9, and . _ @ + -
      validates :preferred_username,
        format: {
          with: /\A[a-zA-Z0-9._@+-]+\z/,
          message: Spree.t("admin.integrations.shipstation.username_chars_error")
        },
        allow_blank: true

      preference :password, :password

      validates :preferred_password,
        presence: true,
        length: {minimum: 20, maximum: 60}

      validates :preferred_password,
        format: {
          with: /[!@#$%^&*(),.?":{}|<>]/,
          message: Spree.t("admin.integrations.shipstation.must_contain_at_least_one_special_character")
        },
        allow_blank: true

      validates :preferred_password,
        format: {
          with: /[A-Z]/,
          message: Spree.t("admin.integrations.shipstation.must_contain_at_least_one_uppercase_letter")
        },
        allow_blank: true

      validates :preferred_password,
        format: {
          with: /\d/,
          message: Spree.t("admin.integrations.shipstation.must_contain_at_least_one_number")
        },
        allow_blank: true

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
