-- Cloud sync metadata foundation only.
-- This migration intentionally does not create inventory, balance, or
-- transaction cloud tables.

create table if not exists public.workspace_sync_state (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  entity_type text not null,
  last_sync_at timestamptz,
  last_changed_at timestamptz,
  version bigint not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(workspace_id, entity_type)
);

create table if not exists public.sync_clients (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  device_name text,
  platform text,
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique(workspace_id, user_id, device_name)
);

drop trigger if exists workspace_sync_state_set_updated_at
on public.workspace_sync_state;
create trigger workspace_sync_state_set_updated_at
before update on public.workspace_sync_state
for each row execute function public.set_updated_at();

alter table public.workspace_sync_state enable row level security;
alter table public.sync_clients enable row level security;

drop policy if exists "Workspace members can select sync state"
on public.workspace_sync_state;
create policy "Workspace members can select sync state"
on public.workspace_sync_state for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Managers can insert sync state"
on public.workspace_sync_state;
create policy "Managers can insert sync state"
on public.workspace_sync_state for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can update sync state"
on public.workspace_sync_state;
create policy "Managers can update sync state"
on public.workspace_sync_state for update
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
)
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Users can select own sync client"
on public.sync_clients;
create policy "Users can select own sync client"
on public.sync_clients for select
to authenticated
using (
  user_id = (select auth.uid())
  and public.is_workspace_member(workspace_id)
);

drop policy if exists "Users can insert own sync client"
on public.sync_clients;
create policy "Users can insert own sync client"
on public.sync_clients for insert
to authenticated
with check (
  user_id = (select auth.uid())
  and public.is_workspace_member(workspace_id)
);

drop policy if exists "Users can update own sync client"
on public.sync_clients;
create policy "Users can update own sync client"
on public.sync_clients for update
to authenticated
using (
  user_id = (select auth.uid())
  and public.is_workspace_member(workspace_id)
)
with check (
  user_id = (select auth.uid())
  and public.is_workspace_member(workspace_id)
);

drop policy if exists "Users can delete own sync client"
on public.sync_clients;
create policy "Users can delete own sync client"
on public.sync_clients for delete
to authenticated
using (
  user_id = (select auth.uid())
  and public.is_workspace_member(workspace_id)
);

grant select, insert, update on public.workspace_sync_state to authenticated;
grant select, insert, update, delete on public.sync_clients to authenticated;
