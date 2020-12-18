module ConfigurationHelper
  def stub_configuration(options)
    allow(SpreeShipstation.configuration).to receive_messages(options)

    if options[:capture_at_notification]
      reset_spree_preferences do |config|
        config.auto_capture_on_dispatch = false
      end
    end
  end
end

RSpec.configure do |config|
  config.include ConfigurationHelper
end
