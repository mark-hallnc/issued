# Issued Cloud Sync Plan

## Current foundation status

Issued now has a workspace-scoped cloud sync foundation. The Flutter app can
report sync readiness, verify a signed-in user's active workspace membership,
and register a sync client metadata row in Supabase.

This is not full inventory sync.

## Synced now

- Supabase Auth sessions
- Workspaces
- Workspace members
- Workspace invites
- Sync metadata only: `workspace_sync_state` and `sync_clients`

## Not synced yet

- Inventory items
- Item location balances
- Inventory transactions
- Checkout records
- Suppliers
- Purchase orders or reorder requests
- Cycle counts
- Local files or item photos

Do not claim cloud backup is available until item, balance, and transaction
sync exist and have been verified.

## Next phases

1. Cloud item catalog table
2. Cloud inventory balances
3. Cloud transactions
4. Conflict handling
5. Offline outbox
6. Audit/reconciliation

## Apply the migration

Run the migration in Supabase SQL editor or with the Supabase CLI:

```sh
supabase db push
```

The migration is:

```text
supabase/migrations/0004_sync_foundation.sql
```

It creates sync metadata tables only. It intentionally does not create cloud
inventory tables and does not migrate local data.
