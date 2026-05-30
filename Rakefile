require "bundler"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
require "spree/testing_support/extension_rake"

RSpec::Core::RakeTask.new

task :default do
  if Dir["spec/dummy"].empty?
    Rake::Task[:test_app].invoke
    Dir.chdir("../../")
  end
  Rake::Task["dummy:verify_schema"].invoke
  Rake::Task[:spec].invoke
end

desc "Generates a dummy app for testing"
task :test_app do
  ENV["LIB_NAME"] = "spree_shipstation"
  Rake::Task["extension:test_app"].execute(
    install_admin: true
  )
end

namespace :dummy do
  # Spree's test_app task runs `db:migrate` with output redirected to /dev/null
  # and ignores its exit status. An intermittent failure there leaves the dummy
  # database without tables, which later surfaces as "Could not find table
  # 'spree_*'" errors across the entire suite. Re-run the migration here,
  # visibly: this self-heals a transient failure and fails fast (with the real
  # error) on a genuine one, instead of producing a wall of misleading specs.
  desc "Ensure the dummy app database schema is fully migrated"
  task :verify_schema do
    dummy_path = File.expand_path("spec/dummy", __dir__)
    next unless File.directory?(dummy_path)

    # Keep using the gem's bundle after the chdir below.
    ENV["BUNDLE_GEMFILE"] = File.expand_path(ENV["BUNDLE_GEMFILE"], __dir__) if ENV["BUNDLE_GEMFILE"]
    ENV["RAILS_ENV"] = "test"

    Dir.chdir(dummy_path) do
      next if system("bundle exec rails db:migrate")

      abort "Dummy app database migration failed; aborting before running specs. " \
        "See the migration output above for the underlying error."
    end
  end
end
