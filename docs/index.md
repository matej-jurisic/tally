---
title: Tally — Garmin Expense Logger
---

## Overview

Tally is a Garmin Connect IQ widget that lets you log expenses directly from your wrist in under 10 seconds. It POSTs each entry to your finance app of choice — no server required, no OAuth dance.

**Supported backends:** Firefly III · Generic Webhook

---

## Quick Start

1. Install Tally from the Connect IQ Store
2. Open **Garmin Connect** → your device → **Apps** → **Tally** → **Settings**
3. Pick your backend, enter a URL and token, set your categories
4. On your watch: open Tally → enter amount → pick category → accounts → description → confirm

---

## Backend Setup

### Generic Webhook

Best for custom automations (n8n, Make, Home Assistant, etc.) or any service that can accept an HTTP POST.

| Setting | Value |
|---------|-------|
| Backend | Generic Webhook |
| URL | Your HTTPS endpoint |
| Token | Leave blank (auth is your endpoint's concern) |

See [Payload Schema](#payload-schema--v1) below for the exact JSON shape sent.

### Firefly III

| Setting | Value |
|---------|-------|
| Backend | Firefly III |
| URL | Your Firefly III base URL, e.g. `https://firefly.example.com` |
| Token | A Personal Access Token — Profile → OAuth → Personal Access Tokens → Create New |
| Currency | Your default currency code, e.g. `EUR` |
| From: names or IDs | Source account name or numeric ID (e.g. `Checking` or `3`) |
| To: names or IDs | Destination account or payee name/ID |

Transactions are posted as `type: withdrawal`. The description field becomes the transaction description; if skipped it defaults to `"Expense"`.

**Tip:** The currency code must match one configured in Firefly III, or you'll get a 422 error.

---

## Settings Reference

### Require 'Account To'

When enabled (default), the flow includes a destination account picker after the source account. Disable this if your backend doesn't need a destination — for example, a webhook that only cares about amount and category.

### Categories

Enter a comma-separated list in Settings → **Categories**:

```
Food,Transport,Coffee,Shopping,Health
```

Default: `Food,Transport,Shopping`.

### Description

Preset description options shown at the end of the flow. Select **none** to skip. Enter a comma-separated list:

```
lunch,coffee,groceries,transport
```

### Accounts

- **From: names or IDs** — source accounts (e.g. your spending account). For Firefly III, you can use the numeric account ID for a reliable match.
- **To: names or IDs** — destination accounts or payees. Only shown when **Require 'Account To'** is on.

Both support "Custom..." for on-the-spot text entry.

---

## Payload Schema — v1

The Generic Webhook backend sends this versioned JSON payload. The `schema` field lets your endpoint detect breaking changes in future releases.

```json
{
  "schema": "v1",
  "amount": 12.50,
  "category": "Food",
  "note": "lunch",
  "account_from": "Checking",
  "account_to": "Restaurant",
  "currency": "USD",
  "timestamp": "2026-06-11T14:30:00Z"
}
```

| Field | Type | Notes |
|-------|------|-------|
| `schema` | string | Always `"v1"` in this release |
| `amount` | float | Positive decimal |
| `category` | string | Selected category name |
| `note` | string | Empty string `""` if skipped |
| `account_from` | string | Selected source account |
| `account_to` | string | Selected destination; empty string `""` if **Require 'Account To'** is off |
| `currency` | string | ISO 4217 code from settings (default: `USD`) |
| `timestamp` | string | ISO 8601 UTC — watch system time |

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| "No URL set" | URL field is empty | Open Garmin Connect → app settings → enter a URL |
| "No token set" | Token required for Firefly III | Enter a valid Personal Access Token |
| HTTP 401 | Invalid or expired token | Re-generate the token in Firefly III |
| HTTP 422 | Malformed request | Check the currency code matches one configured in Firefly III |
| HTTP 400 | Bad request | Ensure the URL has no trailing slash |
| "Sent!" instead of "Logged!" | Server response too large to read on-device | The request went through — check your backend to confirm |
| Network error | Phone not connected | Ensure Bluetooth is active; the watch needs the phone for all HTTP requests |
| Settings not updating | Sync delay | Force-sync via Garmin Connect → device page → pull to refresh |

---

## Privacy

Tally sends data only to the URL you configure. No analytics, no Tally servers. Your token is stored in Garmin Connect's encrypted app settings store.
