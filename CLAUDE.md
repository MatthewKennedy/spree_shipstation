# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`spree-shipstation` is a Spree e-commerce extension (gem) that integrates Spree stores with [ShipStation](https://www.shipstation.com). It exposes an XML endpoint that ShipStation polls for shipments, and a webhook endpoint that ShipStation POSTs to when a label is created (updating the Spree shipment with a tracking number and marking it shipped).

This gem targets **Spree 5.x** and uses the `spree_extension` framework for integration registration.

### Naming

Three related but distinct names — do not "fix" one to match another:

| | Value | Why |
|---|---|---|
| Gem name | `spree-shipstation` | Dash denotes a gem under another gem's namespace |
| Require path | `spree/shipstation` | `lib/spree-shipstation.rb` is a shim so Bundler's auto-require of the gem *name* still works |
| Ruby namespace | `Spree::Shipstation` | Matches the require path |
| `engine_name` | `spree_shipstation` | Generates route helper prefixes, so it **must** be a valid Ruby identifier — a dash is illegal here |
| Asset manifest | `app/assets/config/spree_shipstation_manifest.js` | Referenced by name in the engine's `assets` initializer |

`ENV["LIB_NAME"]` in the `Rakefile` must be the **require path** (`spree/shipstation`), not the gem name: Spree's `common:test_app` does a literal `require ENV['LIB_NAME']` and templates the same string into the generated `spec/dummy/config/application.rb`. Setting it to the gem name makes dummy-app generation fail with a `LoadError` that surfaces as the entire suite erroring.

## Commands

### Run all tests
```shell
bundle exec rake
```
The default Rake task automatically generates a dummy Rails app under `spec/dummy/` if it doesn't exist, then runs the full spec suite.

### Generate the test dummy app (first time or after reset)
```shell
bundle exec rake test_app
```

### Run a single spec file
```shell
bundle exec rspec spec/controllers/spree/shipstation_controller_spec.rb
```

### Lint (StandardRB)
```shell
bundle exec standardrb
```

### Auto-fix lint issues
```shell
bundle exec standardrb --fix
```

Public Ruby classes and methods use YARD `##` blocks. Specs follow one
expectation per example.

## Architecture

### Integration Registration

The extension registers itself with Spree's integration framework via `config/initializers/spree.rb`, which appends `Spree::Integrations::Shipstation` to `spree.integrations`. The integration model (`app/models/spree/integrations/shipstation.rb`) extends `Spree::Integration` and stores credentials as Spree preferences (`preferred_username`, `preferred_password`) with validations.

### Request Flow

**Export (GET `/shipstation`)** — ShipStation polls this endpoint to fetch shipments ready to process:
1. `Spree::ShipstationController#export` authenticates via HTTP Basic Auth using credentials stored on the active store integration.
2. Queries `current_store.shipments.exportable` — a scope added by `Spree::ShipmentDecorator` that filters for `state: "ready"` on complete orders.
3. Filters by `start_date`/`end_date` params (matching either shipment or order `updated_at`). If both params are absent or invalid, all exportable shipments are returned with no date filter.
4. Renders `app/views/spree/shipstation/export.xml.builder` using the `builder` gem. XML structure is validated against `spec/fixtures/shipstation_xml_schema.xsd` in tests.
5. Results are paginated at 50 per page.

**Shipnotify (POST `/shipstation`)** — ShipStation calls this when a label is created:
1. `Spree::ShipstationController#shipnotify` passes `order_number` and `tracking_number` params to `Spree::Shipstation::ShipmentNotice.from_payload`.
2. `ShipmentNotice#apply` looks up the `Spree::Shipment` by number on `current_store` and, inside a transaction: captures pending payments if `Spree::Config.auto_capture_on_dispatch` is on, sets the tracking number, saves, then calls `ship!` unless already shipped.
3. Errors from `Spree::Shipstation::Error` subclasses return HTTP 400; successes return HTTP 200. The webhook is written to be safe for ShipStation to retry.

> **Note on naming:** ShipStation's webhook param is called `order_number` but its value is actually the *shipment* number — it mirrors the `<OrderNumber>` field from the export XML, which is set to `shipment.number`.

### Key Files

| File | Purpose |
|------|---------|
| `app/controllers/spree/shipstation_controller.rb` | Both endpoints; auth (constant-time `secure_compare`) + integration guard |
| `app/models/spree/integrations/shipstation.rb` | Integration model with credential preferences and validations |
| `app/models/spree/shipment_decorator.rb` | Adds `:exportable` and `:between` scopes to `Spree::Shipment` |
| `lib/spree/shipstation/shipment_notice.rb` | Plain Ruby object that applies a ship notification |
| `lib/spree/shipstation/errors.rb` | Custom error hierarchy (`ShipmentNotFoundError`, `PaymentError`, `MissingTrackingNumberError`) |
| `lib/spree/shipstation/engine.rb` | Engine; note `activate` globs `../../../app` — three levels up from `lib/spree/shipstation/` |
| `lib/spree-shipstation.rb` | Bundler auto-require shim; only does `require "spree/shipstation"` |
| `app/helpers/spree/shipstation/export_helper.rb` | Helper methods for building address XML nodes |
| `app/views/spree/shipstation/export.xml.builder` | XML template for ShipStation export |
| `app/views/spree/admin/integrations/forms/_shipstation.html.erb` | Admin UI partial for configuring credentials |

### Testing Helpers

- `spec/support/auth_helper.rb` — provides `stub_basic_auth(username, password)` for controller specs.
- `spec/support/xsd.rb` — provides the `pass_validation(xsd_path)` RSpec matcher for XML schema validation.
- `spec/support/shipment_helper.rb` — shipment-related test helpers.
- `lib/spree/shipstation/testing_support/factories/shipstation_integration.rb` — FactoryBot factory for `Spree::Integrations::Shipstation`, loaded via `require "spree/shipstation/factories"` in `spec/spec_helper.rb`.
