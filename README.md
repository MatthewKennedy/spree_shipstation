# spree_shipstation

![CI](https://github.com/MatthewKennedy/spree_shipstation/workflows/CI/badge.svg)
![Standard Rb](https://github.com/MatthewKennedy/spree_shipstation/workflows/Standard%20Rb/badge.svg)

The spree_shipstation integration connects your Spree stores with [ShipStation](https://www.shipstation.com), allowing ShipStation to pull shipments from your store, and when a shipment is sent, update the order with a tracking number and mark it as shipped.


## Installation

1. Add this extension to your Gemfile with this line:

    ```ruby
    gem "spree_shipstation", github: "MatthewKennedy/spree_shipstation", tag: "v3.0.0"
    ```

2. Install the gem using Bundler

    ```shell
    bundle install
    ```

The extension registers itself with Spree's integration framework automatically — there are no migrations or generators to run.

### Step 1: Configuring Spree

Visit the **Integrations** section of your Spree store and configure the ShipStation integration by creating a unique username and password.

### Step 2: Configuring ShipStation

Create a new ShipStation store by visiting: **Settings** -> **Selling Channels** -> **Stores** -> **Add Store**, then selecting the **Custom Store** option.

Enter the following details:

- **Username**: The username you created in Step 1.
- **Password**: The password you created in Step 1.
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

## Configuration

### Payment capture on dispatch

The integration respects Spree's `auto_capture_on_dispatch` setting. When enabled in your Spree store, pending payments are captured automatically before a shipment is marked as shipped. If a payment capture fails, an error is returned to ShipStation (HTTP 400), preventing the shipment from being marked as shipped until the issue is resolved.

Payment capture happens **synchronously** within the shipnotify webhook request (inside a database transaction) so that a shipment is never marked as shipped against an uncaptured payment. ShipStation automatically retries failed webhook deliveries, and the operation is designed to be safe to repeat: a shipment that is already `shipped` is not shipped again, and only still-pending payments are captured. If your payment gateway is slow, be aware that the capture round-trip occurs in the request cycle.

### Pagination

The export endpoint returns up to **50 shipments per page**. ShipStation handles pagination automatically using the `page` query parameter.

## Security considerations

- **Serve the endpoints over HTTPS.** Both `/shipstation` endpoints authenticate with HTTP Basic Auth, which transmits the configured username and password (base64-encoded) on every request. Always terminate these requests over TLS in production so the credentials are not exposed in transit. Credentials are compared in constant time to avoid timing attacks.
- **Consider rate limiting.** The gem does not throttle authentication attempts. If you want brute-force protection, add it at the application or edge layer (for example, [`rack-attack`](https://github.com/rack/rack-attack)). The enforced credential length (10–30 character username, 20–60 character complex password) already makes guessing impractical.
- **Response codes.** When no active ShipStation integration is configured, the endpoints respond with `404` before authentication is checked; a configured-but-unauthenticated request responds with `401`. This is intentional, but be aware it reveals whether the integration is configured.

## Performance

The export query eager-loads its association graph to avoid N+1 queries. The `exportable` scope filters shipments by `state` and orders them by `updated_at`, joining and filtering orders by their `updated_at`. The gem ships no migrations of its own; on large stores, ensure the relevant Spree core columns (`spree_shipments.state`, `spree_shipments.updated_at`, `spree_orders.updated_at`) are adequately indexed in your application's database.

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

## Releasing

```bash
bundle exec gem bump -p -t
bundle exec gem release
```

## License

Copyright (c) 2021-2026 Matthew Kennedy, released under the MIT License.
