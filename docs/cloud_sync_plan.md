# Issued Cloud Sync Plan

## Current foundation status

Issued now has a workspace-scoped cloud sync foundation. The Flutter app can
report sync readiness, verify a signed-in user's active workspace membership,
register a sync client metadata row in Supabase, and upload item catalog
metadata, current inventory balances, inventory movement history, checkout
records, suppliers, purchasing/reorder records, and cycle count sessions and
lines. It also has a safe two-way sync foundation that can pull cloud rows down
and apply low-risk local merges.

Issued also has a durable local Drift outbox, `sync_outbox`, for local-origin
changes. Local changes are queued by workspace/entity/operation, coalesced to
avoid repeated updates for the same row, retried with backoff after failures,
and kept on-device when the app closes or the user signs out.

This is not full workflow sync. Balance sync captures current state, while
transaction sync captures the local movement records that explain quantity
changes. Cycle count sync captures count sessions and counted lines, but it
does not recalculate balances from cloud count lines or create variance
transactions from pulled count data. Cloud-to-local apply is currently enabled
for item catalog metadata and supplier metadata. Other cloud rows are fetched
and reported as skipped/unsupported until durable conflict handling exists.

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
- Cloud-to-local item and supplier metadata where safe

## Not synced yet

- Background sync workers
- Full conflict resolution UI
- Local files or item photos
- Supplier attachments or documents
- Real-time push updates
- Column-level cost security hardening
- OS-level background retry when the app is not running

Cloud sync is closer to backup now, but do not claim complete cloud backup until
background sync and durable conflict handling are implemented. Safe
cloud-to-local merge currently creates or fills local items and suppliers. It
does not apply pulled balances, transactions, checkouts, purchasing rows, or
cycle counts into local workflow state yet because those rows can duplicate
quantity effects or overwrite local status without a stronger merge baseline.

## Safe Merge Rules

- Match cloud records by cloud `local_*_id` first.
- For items, fall back to unique barcode or SKU when present.
- For suppliers, fall back to an exact normalized unique supplier name.
- Create missing local items and suppliers only when required fields are
  present and a stable local id is available.
- On the first pull, fill blank local item/supplier fields but avoid
  overwriting populated local metadata.
- After a full sync baseline exists, update item/supplier metadata only when
  the cloud row is newer and the local row has not also changed since the last
  full sync.
- If local and cloud rows both changed after the last full sync, record a sync
  conflict and skip the local overwrite.
- Never hard-delete local records from cloud `deleted_at` in this foundation.

## Durable Outbox

The local `sync_outbox` table records pending uploads with:

- Workspace id
- Entity type and local id
- Operation
- Optional JSON payload
- Status: `pending`, `syncing`, `failed`, `done`, `skipped`
- Attempts, last error, next retry time, created/updated/synced timestamps

Retries use simple backoff: soon after the first failure, then about 1 minute,
5 minutes, and 15 minutes for later attempts. Failed entries stay visible in
Settings under the Sync Queue screen and can be retried manually.

Current upload processing still uses the existing full-entity cloud push
services as the transport. When a workspace sync succeeds, queued entries for
that workspace are marked done. If sync fails, queued entries are marked failed
with their next retry time.

## Automatic Sync Triggers

Automatic sync is app-lifecycle based only:

- After cloud login/session restoration
- After workspace selection/creation/invite acceptance
- On app startup when a cloud session and workspace exist
- On app resume when the last successful sync is more than 60 seconds old
- A short debounce after local changes enqueue outbox entries

Manual Sync Now remains available. There are no OS background workers,
push notifications, or realtime subscriptions yet.

## Next phases

1. Durable local sync outbox
2. Entity-specific outbox push processing
3. Automatic sync hardening on startup/resume/change
4. Conflict resolution UI
5. Background sync
6. Real-time updates
7. Audit/reconciliation
8. Optional file/document attachment sync

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
