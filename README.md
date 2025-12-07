# spree_shipstation

![CI](https://github.com/MatthewKennedy/spree_shipstation/workflows/CI/badge.svg)
![Standard Rb](https://github.com/MatthewKennedy/spree_shipstation/workflows/Standard%20Rb/badge.svg)

The spree_shipstation extension connects your Spree store with [ShipStation](https://www.shipstation.com), allowing ShipStation to pull shipments from your store, and when a shipment is sent, update the order with a tracking number and mark it as shipped.


## Installation

1. Add this extension to your Gemfile with this line:

    ```ruby
    gem "spree_shipstation", github: "matthewkennedy/spree_shipstation", tag: "v2.0.0"
    ```

2. Install the gem using Bundler

    ```shell
    bundle install
    ```

3. Copy & run install the generator

    ```shell
    bundle exec rails generate spree_shipstation:install
    ```

### Configuring Spree

Visit the Integrations section of your Spree store and configure the ShipStation integration, adding a username and password, (remember the password).

### Configuring ShipStation

Create a new ShipStation store by visiting: **Settings** -> **Selling Channels** -> **Stores** -> **Add Store**, then selecting the **Custom Store** option.

Enter the following details:

- **Username**: the username defined in your config.
- **Password**: the password defined in your config.
- **URL to custom page**: `https://your-store-domain.com/shipstation.xml`.

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
- 5.x


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

Copyright (c) 2025 Matthew Kennedy, released under the New BSD License.
