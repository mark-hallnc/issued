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

The app now includes a Sync Health screen for reconciliation review. It compares
local record counts with cloud record counts, shows pending and failed outbox
entries, surfaces merge conflicts, and gives operators safe actions to refresh,
sync now, retry failed uploads, view the queue, and view conflicts. A mismatch
does not always mean data loss; it can mean an upload is pending, a migration is
missing, or a workflow record is intentionally fetch-only until conflict
resolution is stronger.

The app also includes a cloud adoption wizard for the first time a device uses a
workspace. It appears after sign-in and workspace selection/creation when local
business data or cloud business data needs a setup decision. The wizard prevents
automatic business-data upload until the user chooses how this device should use
the workspace.

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
- Sync Health reconciliation counts for items, balances, transactions,
  checkouts, suppliers, purchasing/reorders, cycle count sessions, and cycle
  count lines

## Not synced yet

- Background sync workers
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

## Sync Health and Reconciliation

The Sync Health screen is available from Settings under Cloud Account /
Workspace. It is diagnostic and non-destructive:

- Local counts come from Drift.
- Cloud counts come from authenticated Supabase reads and respect RLS.
- Pending and failed counts come from the local `sync_outbox`.
- Conflict counts come from the safe merge conflict list.
- Count mismatches are shown as review signals, not automatic overwrite
  instructions.

Conflict review is conservative. Operators can choose local/cloud only for safe
metadata cases, and complex workflow conflicts stay review-only.

## User-Driven Conflict Resolution

The Sync Review screen supports conservative user-driven conflict actions:

- Keep local: queues the local record for upload and requires a follow-up sync.
- Use cloud: applies cloud metadata locally for item and supplier conflicts.
- Mark reviewed: removes the conflict notice without changing local or cloud
  data.
- Retry: leaves the conflict visible and lets the operator run sync again.

Keep local/use cloud are enabled only where the app can avoid risky side
effects. Item and supplier metadata can use both actions. Transactions,
checkouts, purchasing records, and cycle count records may keep local by
queueing an upload, but cloud overwrite is disabled until workflow-safe merge
rules exist. Inventory balance conflicts are review-only because balances
should usually be resolved by reviewing transactions or doing a count.

Transaction history remains append-only. Conflict resolution must not edit old
movement rows or re-apply quantity effects. Dangerous conflicts should be
reviewed against source activity before a count or correction is created.

## Cloud Adoption Wizard

The cloud adoption wizard has three choices:

- Upload this device's data: uses this device's inventory as the starting data
  for the workspace and runs the existing sync order: items, balances,
  transactions, checkouts, suppliers, purchasing, and cycle counts.
- Start fresh in this workspace: keeps existing local inventory on this device
  but does not upload rows that existed before the setup decision. New local
  changes after the decision timestamp can sync.
- Keep this device local-only for now: leaves the cloud account signed in, but
  disables active workspace sync on this device until the user returns to setup.

If both local and cloud business data exist, uploading requires an explicit
confirmation checkbox because it may merge data from different sources. Workers
and view-only users cannot seed a workspace; they should ask an admin or manager
to set it up first.

Recommended clean setup path before real release:

1. Clear test data from the device if it should not become workspace data.
2. Sign in as the workspace owner/admin.
3. Create or select the workspace.
4. Upload clean starting data from the intended seed device.
5. Invite other users.

## Next phases

1. Entity-specific outbox push processing
2. User-driven conflict resolution
3. Initial workspace upload/download wizard
4. Background sync
5. Real-time updates
6. Optional file/document attachment sync

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

The production security hardening migration is:

```text
supabase/migrations/0011_security_hardening.sql
```

It reasserts active-member workspace isolation, tightens sync table write
policies to owner/admin/manager roles, restricts sync-client rows to the signed
in user, protects the last active workspace owner, and documents the remaining
cost privacy limitation: cost columns are still row-readable to active members
until column-level views/RPCs or separate cost tables are added.
