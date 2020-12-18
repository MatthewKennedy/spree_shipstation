# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  get '/shipstation', to: 'shipstation#export'
  post '/shipstation', to: 'shipstation#shipnotify'
end
