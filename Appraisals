appraise "spree-5-1" do
  spree = "~> 5.1.0"

  gem "spree", spree
  gem "spree_emails", spree
  gem "spree_admin", spree

  gem "sprockets-rails"
end

appraise "spree-5-2" do
  spree = "~> 5.2.0"

  gem "spree", spree
  gem "spree_emails", spree
  gem "spree_admin", spree

  gem "propshaft"
end

appraise "spree-main" do
  spree_opts = {github: "spree/spree", branch: "main"}

  gem "spree", spree_opts
  gem "spree_emails", spree_opts
  gem "spree_admin", spree_opts

  gem "propshaft"
end
