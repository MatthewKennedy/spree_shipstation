# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("dummy/config/environment.rb", __dir__)

require "spree_dev_tools/rspec/spec_helper"
require "spree_shipstation/factories"

# spree_dev_tools starts SimpleCov for us; enforce a minimum line coverage so
# regressions in test coverage fail the build. Skip when SimpleCov is disabled.
if defined?(SimpleCov) && SimpleCov.running
  SimpleCov.minimum_coverage(line: 90)
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].sort.each { |f| require f }
