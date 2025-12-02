FactoryBot.define do
  factory :shipstation_integration, class: Spree::Integrations::Shipstation do
    active { true }
    preferred_username { "my_username" }
    preferred_password { "1Password-123!" }

    store { Spree::Store.default }
  end
end
