# frozen_string_literal: true

require_relative "lib/spree_shipstation/version"

Gem::Specification.new do |spec|
  spec.name = "spree_shipstation"
  spec.version = SpreeShipstation::VERSION
  spec.authors = ["Matthew Kennedy"]
  spec.email = "m.kennedy@me.com"

  spec.summary = "Spree/ShipStation Integration"
  spec.description = "Integrates ShipStation API with Spree. Supports exporting shipments and importing tracking numbers"
  spec.homepage = "https://github.com/matthewkennedy/spree_shipstation"
  spec.license = "BSD-3-Clause"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/matthewkennedy/spree_shipstation"

  spec.required_ruby_version = Gem::Requirement.new("~> 2.5")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

  spec.files = files.grep_v(%r{^(test|spec|features)/})
  spec.test_files = files.grep(%r{^(test|spec|features)/})
  spec.bindir = "exe"
  spec.executables = files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spree_version = ">= 3.2.0", "< 5.0"
  spec.add_dependency "spree_core", spree_version
  spec.add_dependency "spree_api", spree_version
  spec.add_dependency "spree_backend", spree_version
  spec.add_dependency "spree_extension"

  spec.add_development_dependency "rspec-xsd"
  spec.add_development_dependency "spree_dev_tools"
  spec.add_development_dependency "standard"
end
