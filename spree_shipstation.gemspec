# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require "spree_shipstation/version"

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "spree_shipstation"
  s.version = SpreeShipstation.version
  s.summary = "ShipStation integration for Spree e-commerce"
  s.description = "Connects Spree stores to ShipStation via an XML export endpoint and shipnotify webhook, enabling automated label creation and shipment tracking."
  s.required_ruby_version = ">= 3.1"

  s.author = "Matthew Kennedy"
  s.email = "m.kennedy@me.com"
  s.homepage = "https://github.com/matthewkennedy/spree_shipstation"
  s.license = "MIT"

  s.files = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(%r{^spec/fixtures}) }
  s.require_path = "lib"

  spree_version = ">= 5.0", "< 6.0"

  s.add_dependency "pagy", ">= 43.0", "< 45.0"
  s.add_dependency "spree", spree_version
  s.add_dependency "spree_extension"
end
