# Issued Cloud Sync Plan

## Current foundation status

Issued now has a workspace-scoped cloud sync foundation. The Flutter app can
report sync readiness, verify a signed-in user's active workspace membership,
register a sync client metadata row in Supabase, and upload item catalog
metadata, current inventory balances, and inventory movement history.

This is not full workflow sync. Balance sync captures current state, while
transaction sync captures the local movement records that explain quantity
changes. Checkout, purchasing, and cycle count workflows still need their own
cloud records in later phases.

## Synced now

- Supabase Auth sessions
- Workspaces
- Workspace members
- Workspace invites
- Sync metadata only: `workspace_sync_state` and `sync_clients`
- Item definitions/catalog metadata in `workspace_items`
- Current item-location quantity balances in `workspace_inventory_balances`
- Inventory movement history in `workspace_inventory_transactions`

## Not synced yet

- Full checkout workflow records
- Suppliers
- Purchase orders or reorder requests
- Cycle count sessions and line history
- Local files or item photos

Cloud sync is closer to backup now, but do not claim complete cloud backup until
workflow-specific records and conflict handling are implemented. Transaction
sync is upload-first; it does not replay cloud transactions onto local devices
or recalculate balances from cloud history yet.

## Next phases

1. Checkouts
2. Purchase orders/reorders
3. Cycle count sessions and line history
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

The inventory transaction migration is:

```text
supabase/migrations/0007_cloud_inventory_transactions.sql
```

It creates `workspace_inventory_transactions` only. It intentionally does not
create cloud checkout workflow, purchase order, cycle count session, or
server-side balance calculation tables.
