# Issued Cloud Sync Plan

## Current foundation status

Issued now has a workspace-scoped cloud sync foundation. The Flutter app can
report sync readiness, verify a signed-in user's active workspace membership,
register a sync client metadata row in Supabase, and upload item catalog
metadata, current inventory balances, inventory movement history, checkout
records, suppliers, purchasing/reorder records, and cycle count sessions and
lines.

This is not full workflow sync. Balance sync captures current state, while
transaction sync captures the local movement records that explain quantity
changes. Cycle count sync captures count sessions and counted lines, but it
does not recalculate balances from cloud count lines or create variance
transactions from pulled count data.

## Synced now

- Supabase Auth sessions
- Workspaces
- Workspace members
- Workspace invites
- Sync metadata only: `workspace_sync_state` and `sync_clients`
- Item definitions/catalog metadata in `workspace_items`
- Current item-location quantity balances in `workspace_inventory_balances`
- Inventory movement history in `workspace_inventory_transactions`
- Checkout records in `workspace_checkouts`
- Suppliers in `workspace_suppliers`
- Purchasing/reorder records in `workspace_purchase_orders`
- Cycle count sessions in `workspace_cycle_counts`
- Cycle count lines in `workspace_cycle_count_lines`

## Not synced yet

- Background sync workers
- Conflict resolution UI
- Local files or item photos
- Supplier attachments or documents
- Real-time push updates
- Column-level cost security hardening

Cloud sync is closer to backup now, but do not claim complete cloud backup until
background sync and conflict handling are implemented. Transaction sync is
upload-first; it does not replay cloud transactions onto local devices or
recalculate balances from cloud history yet. Checkout, purchasing, and cycle
count sync are also upload-first and do not merge cloud changes back to this
device yet.

## Next phases

1. Conflict resolution and background sync
2. Offline outbox
3. Audit/reconciliation
4. Optional file/document attachment sync

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
create cloud purchase order, cycle count session, or server-side balance
calculation tables.

The checkout migration is:

```text
supabase/migrations/0008_cloud_checkouts.sql
```

It creates `workspace_checkouts` only. It intentionally does not create cloud
purchase order, supplier document, cycle count session, push notification, or
background worker tables.

The purchasing migration is:

```text
supabase/migrations/0009_cloud_purchasing.sql
```

It creates `workspace_suppliers` and `workspace_purchase_orders` only. It
intentionally does not create supplier document storage, invoice OCR, accounting
integration, cycle count session, push notification, or background worker
tables.

The cycle count migration is:

```text
supabase/migrations/0010_cloud_cycle_counts.sql
```

It creates `workspace_cycle_counts` and `workspace_cycle_count_lines` only. It
intentionally does not create attachment storage, push notification, billing,
background worker, or conflict-resolution tables.
