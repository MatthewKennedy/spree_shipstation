module ConfigurationHelper
  def stub_configuration(options)
    # allow(Spree.configuration).to receive_messages(options)

    # if options[:capture_at_notification]
    #   Config.shipstation_require_payment_to_ship = false
    # end
  end
end

RSpec.configure do |config|
  config.include ConfigurationHelper
end
