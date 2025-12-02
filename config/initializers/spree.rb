Rails.application.config.after_initialize do
  Rails.application.config.spree.integrations << Spree::Integrations::Shipstation
end
