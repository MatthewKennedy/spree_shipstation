# frozen_string_literal: true

Spree::Core::Engine.add_routes do
  get "/shipstation", to: "shipstation#export"
  post "/shipstation", to: "shipstation#shipnotify"
end
