# frozen_string_literal: true

Rails.application.config.after_initialize do
  Rails.application.config.spree.integrations << Spree::Integrations::Shipstation
end
