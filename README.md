# spree_shipstation
![CI](https://github.com/MatthewKennedy/spree_shipstation/workflows/CI/badge.svg)
![Standard Rb](https://github.com/MatthewKennedy/spree_shipstation/workflows/Standard%20Rb/badge.svg)

This gem integrates [ShipStation](https://www.shipstation.com) with [Spree](https://spreecommerce.org). It
enables ShipStation to pull shipments from the system and update tracking numbers.

## Installation

Add spree_shipstation to your Gemfile:

```ruby
gem 'spree_shipstation', github: 'matthewkennedy/spree_shipstation'
```

Bundle your dependencies and run the installation generator:

```shell
bundle exec rails generate spree_shipstation:install
```

## Configuration

### Configuring spree_shipstation

Configure your ShipStation integration:

```ruby
# config/initializers/spree_shipstation.rb

SpreeShipstation.configure do |config|
  # Choose between Grams, Ounces or Pounds.
  config.weight_units = "Grams"

  # ShipStation expects the endpoint to be protected by HTTP Basic Auth.
  # Set the username and password you desire for ShipStation to use.
  config.username = "smoking_jay_cutler"
  config.password = "my-awesome-password"

  # Capture payment when ShipStation notifies a shipping label creation.
  # Set this to `true` and `Spree::Configrequire_payment_to_ship` to `false` if you
  # want to charge your customers at the time of shipment.
  config.capture_at_notification = false

  # Export canceled shipments to ShipStation
  # Set this to `true` if you want canceled shipments included in the endpoint.
  config.export_canceled_shipments = false
end
```

You may also need to configure some options of your Spree store:

```ruby
# config/initializers/spree.rb
Spree.config do |config|
  # Set to false if you're not using auto_capture (defaults to true).
  config.auto_capture_on_dispatch = true

  # Set to false if you're not using inventory tracking features (defaults to true).
  config.track_inventory_levels = true
end
```

### Configuring ShipStation

To configure or create a ShipStation store, go to **Settings** -> **Stores** -> **Add Store**, then
scroll down and choose the **Custom Store** option.

Enter the following details:

- **Username**: the username defined in your config.
- **Password**: the password defined in your config.
- **URL to custom page**: `https://yourdomain.com/shipstation.xml`.

There are five shipment states for an order (= shipment) in ShipStation. These states do not
necessarily align with Spree, but you can configure ShipStation to create a mapping for your
specific needs. Here's the default mapping:

ShipStation description | ShipStation status | Spree status
------------------------|--------------------|---------------
Awaiting Payment        | `unpaid`           | `pending`
Awaiting Shipment       | `paid`             | `ready`
Shipped                 | `shipped`          | `shipped`
Cancelled               | `cancelled`        | `cancelled`
On-Hold                 | `on-hold`          | `pending`

## Usage

There's nothing you need to do. Once properly configured, the integration just works!

## Gotchas

There are a few gotchas you need to be aware of:

- If you change the shipping method of an order in ShipStation, the change will not be reflected in
  Spree and the tracking link might not work properly.
- When `shipstation_capture_at_notification` is enabled, any errors during payment capture will
  prevent the update of the shipment's tracking number.

## Development

### Testing the extension

First bundle your dependencies, then run `bundle exec rake test_app` this will default to building the dummy
app if it does not exist.

To run the tests use:

```shell
bundle exec rake
```

To run [Standard Rb](https://github.com/testdouble/standard) static code analysis run:

```shell
bundle exec standardrb
```

To fix code formatting issues run:

```shell
bundle exec standardrb --fix
```

When testing your application's integration with this extension you may use its factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_shipstation/factories'
```

## License

Copyright (c) 2020 Matthew Kennedy, released under the New BSD License.
