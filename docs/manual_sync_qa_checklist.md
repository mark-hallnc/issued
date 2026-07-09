# Manual Sync QA Checklist

Use this checklist with two devices or two app profiles connected to the same
Supabase project. Create test records with the prefix `QA TEST -` and clean
them up through the normal app UI after testing.

## Setup

- Owner account can sign in.
- Workspace is selected on device A.
- Same workspace is selected on device B.
- Sync status is not blocked by the cloud setup wizard.
- Diagnostics can open Settings -> Sync QA Checklist.
- Supabase migrations through `0011_security_hardening.sql` are applied.

## Owner and Admin

- Owner creates `QA TEST - Item` on device A.
- Device B receives the item after sync.
- Owner edits item name, SKU, barcode, or category.
- Device B receives the item metadata update.
- Owner receives or adjusts stock for the item.
- Device B sees the current quantity update.
- Owner creates or edits a supplier.
- Device B receives the supplier update.
- Owner creates or edits a purchasing/reorder record.
- Device B receives the purchasing/reorder update.
- Owner creates a cycle count session and line.
- Device B receives the cycle count data.
- Owner invites a new user.
- Last active owner cannot be disabled, deleted, or demoted.

## Worker

- Worker can sign in and select the workspace.
- Worker can perform allowed checkout/return/count workflows.
- Worker cannot manage workspace users.
- Worker cannot see cost fields when cost permission is disabled.
- Worker cannot export restricted cost reports.
- Denied actions show a friendly permission message.

## View-Only

- View-only user can sign in and view allowed inventory.
- View-only user cannot create, edit, delete, adjust, checkout, return, or count.
- View-only user cannot manage users.
- View-only user cannot see restricted cost values.
- Denied actions show a friendly permission message.

## Offline and Recovery

- Turn off network on device A.
- Edit `QA TEST - Item` or create another small QA record.
- Confirm the app saves locally and remains usable.
- Confirm sync status says the change will sync later.
- Reconnect network.
- Confirm the change syncs to device B.
- If a failed upload appears in diagnostics, use Retry failed.
- Confirm the failed entry clears or returns a friendly error.

## Conflicts

- Edit the same QA item field on both devices before sync settles.
- Confirm a conflict appears in diagnostics if the merge is unsafe.
- Open Sync Conflicts.
- Confirm dangerous balance or transaction conflicts are review-only.
- Mark a safe conflict reviewed or choose a safe resolution where enabled.
- Run sync again and confirm the conflict count updates.

## Cost Privacy

- Confirm owner/admin can see cost fields where expected.
- Confirm worker/view-only cannot see item costs, purchasing totals, inventory
  value, variance value, or cost export columns when permission is disabled.
- Confirm Sync Health and conflict screens do not reveal cost values to
  restricted roles.

## Final Cleanup

- Archive or delete `QA TEST -` items through normal app actions.
- Clear completed sync queue entries from diagnostics if desired.
- Leave failed queue entries in place unless they are understood and safe to
  clear.
- Do not delete cloud rows directly unless performing a controlled reset.
