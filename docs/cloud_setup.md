# Issued Cloud Setup

Issued can run in Local-Only Mode without cloud configuration. Cloud Account and Workspace features are enabled only when the app is built with Supabase dart-defines.

## 1. Create a Supabase Project

Create a Supabase project and copy:

- Project URL
- Publishable/anon key

Do not put these values directly in source files.

## 2. Run the Workspace SQL Migration

Open the Supabase SQL editor and run:

```sql
-- supabase/migrations/0001_workspace_auth_foundation.sql
-- supabase/migrations/0002_workspace_invite_flow.sql
-- supabase/migrations/0003_workspace_member_role_safeguards.sql
-- supabase/migrations/0004_sync_foundation.sql
-- supabase/migrations/0005_cloud_item_catalog.sql
-- supabase/migrations/0006_cloud_inventory_balances.sql
-- supabase/migrations/0007_cloud_inventory_transactions.sql
```

This creates:

- `profiles`
- `workspaces`
- `workspace_members`
- `workspace_invites`
- RLS helper functions
- `create_workspace_with_owner(workspace_name text)`
- `accept_workspace_invite(invite_id uuid)`
- `revoke_workspace_invite(invite_id uuid)`
- sync metadata tables: `workspace_sync_state`, `sync_clients`
- item catalog metadata table: `workspace_items`
- current inventory balance table: `workspace_inventory_balances`
- inventory movement history table: `workspace_inventory_transactions`

## 3. Deploy Workspace Invites

Workspace invite emails are sent from a Supabase Edge Function. The service
role key is used only by the Edge Function and must never be put in Flutter.

Set the function secret, then deploy:

```sh
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<your-service-role-key>
supabase functions deploy invite-workspace-member
```

Optional local testing:

```sh
supabase functions serve invite-workspace-member --env-file ./supabase/.env.local
```

The function reads:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `INVITE_REDIRECT_URL`, optional for Supabase invite links

## 4. Build or Run with Dart Defines

```sh
flutter run --dart-define=SUPABASE_URL=<your-project-url> --dart-define=SUPABASE_ANON_KEY=<your-publishable-or-anon-key>
```

Without these values, Issued stays usable in Local-Only Mode.

## Invite Flow Test

1. Sign in as a workspace owner/admin.
2. Open Settings -> Cloud Account / Workspace -> Members / Invites.
3. Invite a manager, worker, or view-only user by email.
4. Confirm the row appears under Pending Invites.
5. Sign in as the invited email with an email code.
6. Accept the pending workspace invite on the Workspace screen.
7. Confirm the workspace appears and the member role is active.

Supabase Magic Link / OTP templates should include `{{ .Token }}` when Issued
uses code entry. Supabase invite templates can be used for invite email
delivery. Custom SMTP/Resend should be configured in Supabase for reliable
delivery and template editing.

## Security Notes

- Do not use the Supabase service role key in Flutter.
- Do not call admin auth APIs from Flutter.
- Admin invite/auth operations run in the Edge Function.
- The Flutter app calls only normal authenticated RPCs and Edge Functions.

## Current Scope

This foundation adds auth, workspace membership, workspace selection, and
invites. It also adds sync metadata, item catalog upload, and current inventory
balance and movement history upload for future workspace-based sync. It does
not fully sync checkout workflows, purchase orders, cycle count sessions, or
background conflict resolution yet.
