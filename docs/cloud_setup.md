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
```

This creates:

- `profiles`
- `workspaces`
- `workspace_members`
- `workspace_invites`
- RLS helper functions
- `create_workspace_with_owner(workspace_name text)`

## 3. Build or Run with Dart Defines

```sh
flutter run --dart-define=SUPABASE_URL=<your-project-url> --dart-define=SUPABASE_ANON_KEY=<your-publishable-or-anon-key>
```

Without these values, Issued stays usable in Local-Only Mode.

## Security Notes

- Do not use the Supabase service role key in Flutter.
- Do not call admin auth APIs from Flutter.
- Workspace invite delivery will be added later with an Edge Function.
- The future invite Edge Function will use the service role key server-side only.

## Current Scope

This foundation adds auth, workspace membership, and workspace selection. It does not sync local inventory data to Supabase yet.
