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
  # Spree's test_app task runs `db:migrate` in the generator's own process with
  # output redirected to /dev/null and its exit status ignored. On the heavier
  # Spree 5.3+/5.4 setup path (admin install + Tailwind/asset build) that step
  # can be interrupted mid schema-dump, leaving a TRUNCATED db/schema.rb. Rails
  # then loads that broken dump on the next migrate and fails, so the dummy
  # database ends up empty and the whole suite errors with
  # "Could not find table 'spree_*'".
  #
  # Make setup deterministic: discard any (possibly corrupt) schema dump and
  # rebuild the database from the migration files, in a fresh process and
  # visibly. Fail fast with the real error if migration genuinely fails.
  desc "Ensure the dummy app database schema is fully migrated"
  task :verify_schema do
    dummy_path = File.expand_path("spec/dummy", __dir__)
    next unless File.directory?(dummy_path)

    # Keep using the gem's bundle after the chdir below.
    ENV["BUNDLE_GEMFILE"] = File.expand_path(ENV["BUNDLE_GEMFILE"], __dir__) if ENV["BUNDLE_GEMFILE"]
    ENV["RAILS_ENV"] = "test"

    Dir.chdir(dummy_path) do
      puts "Rebuilding dummy app database schema..."

      # Remove a potentially-truncated schema dump so the migration files (the
      # source of truth) are used to build the schema from scratch.
      schema = File.join(dummy_path, "db", "schema.rb")
      File.delete(schema) if File.exist?(schema)

      # Separate invocations on purpose: chaining db:create and db:migrate in a
      # single `rails` call can leave migrate reading a stale schema state.
      system("bundle exec rails db:drop db:create")
      migrated = system("bundle exec rails db:migrate")

      unless migrated
        abort "Dummy app database setup failed; aborting before running specs. " \
          "See the migration output above for the underlying error."
      end
    end
  end
end
