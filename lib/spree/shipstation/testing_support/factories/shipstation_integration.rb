FactoryBot.define do
  factory :shipstation_integration, class: Spree::Integrations::Shipstation do
    active { true }
    preferred_username { "myusernameisvalid23kd-ws" }
    preferred_password { "aWc2yNoc27tLisYeT-J@4fjyDN6JZHj@2t-6YFXArFXNUsZBs-G-r" }

    store { Spree::Store.default }
  end
end
