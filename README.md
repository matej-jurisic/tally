# Tally

A Garmin Connect IQ widget for logging expenses on-wrist to your budgeting backend.

## Supported backends

| # | Backend | Auth |
|---|---------|------|
| 0 | Generic Webhook | none |
| 1 | Firefly III | Personal Access Token |

## Supported devices

Forerunner 255/955/265/265S/965, Fenix 7/7S/7X/7 Pro/7X Pro, Epix 2/2 Pro, Venu 3/3S, Vivoactive 5

## Setup

Settings are configured via the **Garmin Connect mobile app**:

| Setting | Description |
|---------|-------------|
| Backend | `Generic Webhook` or `Firefly III` |
| URL / Base URL | Your endpoint or Firefly III base URL |
| Token / Password | Personal Access Token (Firefly III only) |
| Currency | Currency code shown on screen, e.g. `EUR` |
| From: names or IDs | Comma-separated source account names or IDs |
| To: names or IDs | Comma-separated destination/payee names or IDs |
| Require 'Account To' | Toggle the destination account step on/off |
| Categories | Comma-separated category names |
| Description | Comma-separated description presets |

## Usage

1. Open the widget from the glance loop
2. Enter the amount
3. Pick category → source account → (destination account) → description
4. Press START to submit

The destination account step is skipped when **Require 'Account To'** is off.

## Building

Requires the [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) and a developer key.

```
monkeyc -o bin/Tally.iq -w -y developer_key -r -f monkey.jungle --package-app
```

Or use **F5** in VS Code with the Connect IQ extension.

## Support

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-khynir-yellow?logo=buymeacoffee)](https://buymeacoffee.com/khynir)
