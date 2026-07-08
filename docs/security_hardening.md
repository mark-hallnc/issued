# Security Hardening

## Role Matrix

Issued cloud workspaces use these roles:

- Owner: full workspace administration, including owner/member management.
- Admin: workspace administration for non-owner members, invites, settings, inventory sync, and reports.
- Manager: inventory, purchasing, checkout, count, sync, and cost/report access.
- Worker: read workspace data and perform local worker workflows allowed by the app. Cloud write sync is blocked at the RLS layer until narrower worker-write policies or RPCs are added.
- View-only: read-only access.

## RLS Summary

Migration `0011_security_hardening.sql` reasserts the workspace helper
functions and RLS policies:

- `is_workspace_member(workspace_id)` requires an active member row.
- `has_workspace_role(workspace_id, roles)` requires an active member row with one of the allowed roles.
- `is_workspace_owner(workspace_id)` requires active owner membership.
- `workspace_owner_count(workspace_id)` counts active owners.

Workspace-scoped cloud tables allow `select` only for active members. Business
sync writes are limited to owner/admin/manager roles. Worker and view-only
roles are read-only at the table policy layer for production safety.

The migration also hardens `sync_clients` so users can manage only their own
client row, and `workspace_sync_state` so only owner/admin/manager roles can
insert or update sync state.

## Member Safety

Owners can manage owner rows. Admins can manage non-owner rows. Admins cannot
assign the owner role, modify owner rows, or remove owners. The database trigger
prevents disabling, demoting, or deleting the last active owner.

Invites are restricted to owner/admin callers. The invite Edge Function keeps
the service-role key server-side, verifies the caller before using privileged
writes, normalizes email addresses, rejects owner invites, and blocks duplicate
active members.

## Cost Privacy

The app hides cost-sensitive values unless `canViewCosts` is true. This covers
item unit cost, purchasing cost fields, inventory value reports, cycle-count
variance value, and sync conflict values that mention cost, price, value, or
amount.

Postgres RLS is row-level, not column-level. Current cloud business tables still
store cost columns on rows that active workspace members can select. App-side
privacy is therefore a UI and client behavior control, not a direct database
column security boundary.

For stronger cost isolation later, add either:

- restricted read views/RPCs that omit cost columns for non-cost roles, or
- separate cost tables with stricter RLS.

## Soft Delete Rule

Cloud workflow history should be preserved. Business delete actions should
prefer `deleted_at` or inactive flags over hard deletes. The hardening migration
removes normal hard-delete policies from balance, transaction, checkout,
purchasing, and cycle-count workflow tables. Items and suppliers still allow
manager hard delete at the table layer for administrative cleanup, but app
workflows should continue using soft-delete methods when cloud records exist.

Transaction history should be append-only. Reversals and corrections should be
new records, not edits to old movement history.

## Service Role Rule

The Flutter app must never contain or receive the Supabase service role key.
Service-role usage belongs only in trusted Supabase Edge Functions after the
function verifies the authenticated caller and workspace role.

## Pre-Release Checklist

- Apply migration `0011_security_hardening.sql`.
- Redeploy `invite-workspace-member` only when the Edge Function changes.
- Verify owner/admin/manager/worker/view-only roles against the app UI.
- Confirm worker/view-only users cannot upload sync writes.
- Confirm worker/view-only users cannot see cost values in reports, item detail,
  exports they can access, or sync conflict review.
- Confirm the last active owner cannot be disabled, demoted, or deleted.
- Confirm sign-out and cloud adoption flows warn before risky local/cloud data
  decisions.
- Decide whether column-level cost isolation is required before production.
