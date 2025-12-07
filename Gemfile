source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

spree_opts = {github: "spree/spree", branch: "main"}

gem "spree", spree_opts
gem "spree_emails", spree_opts
gem "spree_admin", spree_opts
gem "spree_storefront", spree_opts

gem "appraisal", "~> 2.5"
gem "rails-controller-testing"
gem "rspec-xsd", "~> 0.1.0"
gem "spree_dev_tools"
gem "sprockets-rails"
gem "sqlite3", ">= 2.0"
gem "standard", "~> 1.52"

gemspec
