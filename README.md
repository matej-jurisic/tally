# Tally

A Garmin Connect IQ widget for logging expenses on-wrist to your budgeting backend.

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
| Amount presets | Comma-separated quick-pick amounts, e.g. `5,10,20`. Leave empty for manual digit entry |
| Whole numbers only | Enable for currencies without cents (JPY, HUF, …) |
| Categories | Comma-separated category names |
| Require Category | Toggle the category step on/off |
| Description | Comma-separated description presets |
| Require Description | Toggle the description step on/off |
| From: names or IDs | Comma-separated source account names or IDs |
| To: names or IDs | Comma-separated destination/payee names or IDs |
| Require 'Account To' | Toggle the destination account step on/off |

## Usage

1. Open the widget from the glance loop
2. Enter the amount (pick a preset or scroll digits; hold BACK to reset)
3. Pick category → source account → (destination account) → description
4. Press START to submit

Steps marked optional in settings are skipped automatically. On touchscreen devices, tap the top or bottom third of the amount screen to scroll the digit up or down.

The glance shows the last logged amount, category, and time.

## Building

Requires the [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) and a developer key.

```
monkeyc -o bin/Tally.iq -w -y developer_key -r -f monkey.jungle --package-app
```

Or use **F5** in VS Code with the Connect IQ extension.

## Support

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-khynir-yellow?logo=buymeacoffee)](https://buymeacoffee.com/khynir)
