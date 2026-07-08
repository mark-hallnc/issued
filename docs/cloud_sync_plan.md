# Issued Cloud Sync Plan

## Current foundation status

Issued now has a workspace-scoped cloud sync foundation. The Flutter app can
report sync readiness, verify a signed-in user's active workspace membership,
register a sync client metadata row in Supabase, and upload item catalog
metadata and current inventory balances.

This is not full inventory sync. Balance sync captures current state, not
history.

## Synced now

- Supabase Auth sessions
- Workspaces
- Workspace members
- Workspace invites
- Sync metadata only: `workspace_sync_state` and `sync_clients`
- Item definitions/catalog metadata in `workspace_items`
- Current item-location quantity balances in `workspace_inventory_balances`

## Not synced yet

- Inventory transactions and audit trail
- Checkout records
- Suppliers
- Purchase orders or reorder requests
- Cycle count history
- Local files or item photos

Do not claim complete cloud backup is available until transaction sync exists.
Current balance sync answers how many items are on hand now; it does not explain
how the quantity changed over time.

## Next phases

1. Transactions/audit log
2. Checkouts
3. Purchase orders/reorders
4. Conflict resolution and background sync
5. Offline outbox
6. Audit/reconciliation

## Apply the migration

Run the migration in Supabase SQL editor or with the Supabase CLI:

```sh
supabase db push
```

The sync metadata migration is:

```text
supabase/migrations/0004_sync_foundation.sql
```

The item catalog migration is:

```text
supabase/migrations/0005_cloud_item_catalog.sql
```

The current inventory balance migration is:

```text
supabase/migrations/0006_cloud_inventory_balances.sql
```

It creates `workspace_inventory_balances` only. It intentionally does not create
cloud transaction, checkout, purchase order, cycle count history, or audit log
tables.
