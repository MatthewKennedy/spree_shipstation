# frozen_string_literal: true

module SpreeShipstation
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def generate_shipstation_configuration_file
       copy_file 'config/initializers/spree_shipstation.rb', 'config/initializers/spree_shipstation.rb', skip: true
      end
    end
  end
end
