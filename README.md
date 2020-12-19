# spree_shipstation
![CI](https://github.com/MatthewKennedy/spree_shipstation/workflows/CI/badge.svg)
![Standard Rb](https://github.com/MatthewKennedy/spree_shipstation/workflows/Standard%20Rb/badge.svg)

This Spree extension integrates [ShipStation](https://www.shipstation.com) with [Spree](https://spreecommerce.org). It enables ShipStation to pull shipments from the Spree and update tracking numbers.

## Installation

Add spree_shipstation to your Gemfile:

```ruby
gem 'spree_shipstation', github: 'matthewkennedy/spree_shipstation'
```

Bundle your dependencies and run the installation generator:

```shell
bundle exec rails generate spree_shipstation:install

# Generates the spree_shipstation.rb file => config/initializers/spree_shipstation.rb
```

## Configuration

### Configuring Spree

Once installed you will find the `spree_shipstation.rb` file located at: `config/initializers/spree_shipstation.rb`.

```ruby
# config/initializers/spree_shipstation.rb

SpreeShipstation.configure do |config|
  # Choose between Grams, Ounces or Pounds.
  config.weight_units = "Grams"

  # ShipStation expects the endpoint to be protected by HTTP Basic Auth.
  # Set the username and password you desire for ShipStation to use.
  config.username = "create-a-username"
  config.password = "set-a-new-password"

  # Capture payment when ShipStation notifies a shipping label creation.
  # Set this to `true` and `config.auto_capture_on_dispatch = true` if you
  # want to charge your customers at the time of shipment.
  config.capture_at_notification = false

  # Export canceled shipments to ShipStation
  # Set this to `true` if you want canceled shipments included in the endpoint.
  config.export_canceled_shipments = false
end
```

If you are using `config.capture_at_notification = true` in `spree_shipstation.rb` add the following config to your spree.rb initializer:

```ruby
# config/initializers/spree.rb

Spree.config do |config|
  config.auto_capture_on_dispatch = true # (Default is false)
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

### Compatibility

This extension works with the following Spree versions:

- 3.7.x
- 4.1.x
- 4.2.x

## Gotchas

There are a few gotchas you need to be aware of:

- If you change the shipping method of an order in ShipStation, the change will not be reflected in
  Spree and the tracking link might not work properly.
- When `shipstation_capture_at_notification` is enabled, any errors during payment capture will
  prevent the update of the shipment's tracking number.

## Development

### Testing

First bundle your dependencies:

```shell
bundle
```

To run the tests use:

```shell
bundle exec rake
```

### Code Formatting

To check your code formatting with [Standard Rb](https://github.com/testdouble/standard) run:

```shell
bundle exec standardrb
```

To fix basic code formatting issues run:

```shell
bundle exec standardrb --fix
```

## License

Copyright (c) 2020 Matthew Kennedy, released under the New BSD License.
