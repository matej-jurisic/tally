# Tally

Tally is a quick-log widget for tracking personal expenses directly from your wrist. Select an amount, category, accounts and description, then submit with one button press. Transactions are sent instantly to your finance backend. Supported backends include Firefly III and a generic webhook. The glance shows your last logged transaction at a glance.

## What's New

- **Touchscreen support** — Full native touch input on Venu 3, Vivoactive 5 and other touch devices: tap any digit to focus it, swipe left to confirm the amount
- **Smarter digit navigation** — Tap any digit to jump directly to it; values are preserved if you rewind and jump forward again
- **Whole-number currencies** — The "Whole numbers only" setting now shows a 4-digit entry screen instead of 5, correct for JPY, HUF, etc.
- **Per-field custom input** — New settings to enable or disable the "Custom…" free-text entry individually for categories, accounts, and description
- **Configurable description default** — Set a default description to replace the generic "--- none ---" option
- **Removed amount presets** — Simplified the entry flow; manual digit entry is the only mode

## Supported backends

| # | Backend | Auth |
|---|---------|------|
| 0 | Generic Webhook | none (optional Bearer token) |
| 1 | Firefly III | Personal Access Token |

## Supported devices

Forerunner 255/955/265/265S/965, Fenix 7/7S/7X/7 Pro/7X Pro, Epix 2/2 Pro, Venu 3/3S, Vivoactive 5

## Setup

Settings are configured via the **Garmin Connect mobile app**:

| Setting | Description |
|---------|-------------|
| Backend | `Generic Webhook` or `Firefly III` |
| URL / Base URL | Your endpoint or Firefly III base URL |
| Token / Password | Bearer token sent with every request. Required for Firefly III; optional for Generic Webhook |
| Currency | Currency code shown on screen, e.g. `EUR` |
| Whole numbers only | Enable for currencies without cents (JPY, HUF, …) |
| Categories | Comma-separated category names |
| Require Category | Toggle the category step on/off |
| Allow custom category | Show a "Custom…" option in the category picker |
| Description | Comma-separated description presets |
| Require Description | Toggle the description step on/off |
| Allow custom description | Show a "Custom…" option in the description picker |
| Default description | Value used when "none" is selected; leave blank for no default |
| From: names or IDs | Comma-separated source account names or Firefly III IDs |
| Allow custom 'From' account | Show a "Custom…" option in the From picker |
| To: names or IDs | Comma-separated destination/payee names or Firefly III IDs |
| Allow custom 'To' account | Show a "Custom…" option in the To picker |
| Require 'Account To' | Toggle the destination account step on/off |

## Usage

1. Open the widget from the glance loop
2. Enter the amount — scroll digits with UP/DOWN (or swipe up/down on touchscreen); tap a digit to jump to it; swipe left or press START to confirm
3. Pick category → source account → (destination account) → description
4. Press START (or tap) to submit on the confirm screen

Steps toggled off in settings are skipped automatically.

The glance shows the last logged amount, category, and time.

## Building

Requires the [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) and a developer key.

```
monkeyc -o bin/Tally.iq -w -y developer_key -r -f monkey.jungle --package-app
```

Or use **F5** in VS Code with the Connect IQ extension.

## Support

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-khynir-yellow?logo=buymeacoffee)](https://buymeacoffee.com/khynir)
