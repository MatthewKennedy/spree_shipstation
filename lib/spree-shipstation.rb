# frozen_string_literal: true

# Bundler auto-requires a gem by its *name*, so `gem "spree-shipstation"` in a host
# Gemfile issues `require "spree-shipstation"`. The gem's real entry point is
# `spree/shipstation` (matching the Spree::Shipstation namespace), so this shim keeps
# the default `Bundler.require` working without every consumer having to write
# `gem "spree-shipstation", require: "spree/shipstation"`.
require "spree/shipstation"
