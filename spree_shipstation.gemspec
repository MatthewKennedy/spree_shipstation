# frozen_string_literal: true

lib = File.expand_path("../lib/", __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require "spree_shipstation/version"

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "spree_shipstation"
  s.version = SpreeShipstation.version
  s.summary = "Add extension summary here"
  s.description = "Add (optional) extension description here"
  s.required_ruby_version = ">= 2.2.7"

  s.author = "Matthew Kennedy"
  s.email = "m.kennedy@me.com"
  s.homepage = "https://github.com/matthewkennedy/spree_shipstation"
  s.license = "MIT"

  s.files = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = "lib"
  s.requirements << "none"

  spree_version = ">= 5.0", "< 6.0"

  s.add_dependency "spree", spree_version
  s.add_dependency "spree_extension"
end
