# Issued Cloud Sync Plan

## Current foundation status

Issued now has a workspace-scoped cloud sync foundation. The Flutter app can
report sync readiness, verify a signed-in user's active workspace membership,
register a sync client metadata row in Supabase, and upload item catalog
metadata.

This is not full inventory sync. It does not sync quantities.

## Synced now

- Supabase Auth sessions
- Workspaces
- Workspace members
- Workspace invites
- Sync metadata only: `workspace_sync_state` and `sync_clients`
- Item definitions/catalog metadata in `workspace_items`

## Not synced yet

- Item location balances and on-hand quantities
- Inventory transactions
- Checkout records
- Suppliers
- Purchase orders or reorder requests
- Cycle counts
- Local files or item photos

Do not claim cloud backup is available until item, balance, and transaction
sync exist and have been verified.

## Next phases

1. Inventory balances
2. Transactions/audit log
3. Checkouts
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

It creates `workspace_items` only. It intentionally does not create cloud
quantity, balance, transaction, checkout, or purchase order tables.
