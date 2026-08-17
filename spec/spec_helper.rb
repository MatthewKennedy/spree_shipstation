# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("dummy/config/environment.rb", __dir__)

require "spree_dev_tools/rspec/spec_helper"
require "spree/shipstation/factories"

# spree_dev_tools starts SimpleCov for us; enforce a minimum line coverage so
# regressions in test coverage fail the build.
#
# `SimpleCov.running` was removed in SimpleCov 1.0, so it is not used to gate this.
# No gate is needed: minimum_coverage only sets config, and it is enforced by the
# at_exit hook that SimpleCov.start installs — if coverage is disabled, nothing
# started, so this is a no-op.
SimpleCov.minimum_coverage(line: 90) if defined?(SimpleCov)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }
