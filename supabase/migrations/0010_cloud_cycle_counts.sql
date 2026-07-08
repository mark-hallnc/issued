-- Cloud cycle count session and line sync only.
-- This migration intentionally does not create attachment storage, push
-- notification, billing, background worker, or conflict-resolution tables.

create table if not exists public.workspace_cycle_counts (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  local_count_id text not null,
  name text,
  status text not null,
  location_id text,
  location_name text,
  bin_id text,
  bin_name text,
  started_at timestamptz,
  completed_at timestamptz,
  approved_at timestamptz,
  counted_by_user_id uuid references auth.users(id),
  counted_by_name text,
  counted_by_email text,
  approved_by_user_id uuid references auth.users(id),
  approved_by_name text,
  approved_by_email text,
  notes text,
  source_device_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint workspace_cycle_counts_workspace_local_count_unique
    unique (workspace_id, local_count_id),
  constraint workspace_cycle_counts_status_check
    check (status in ('draft', 'assigned', 'submitted', 'approved'))
);

create index if not exists workspace_cycle_counts_workspace_id_idx
on public.workspace_cycle_counts (workspace_id);

create index if not exists workspace_cycle_counts_status_idx
on public.workspace_cycle_counts (status);

create index if not exists workspace_cycle_counts_started_at_idx
on public.workspace_cycle_counts (started_at);

create index if not exists workspace_cycle_counts_completed_at_idx
on public.workspace_cycle_counts (completed_at);

create index if not exists workspace_cycle_counts_location_id_idx
on public.workspace_cycle_counts (location_id);

drop trigger if exists workspace_cycle_counts_set_updated_at
on public.workspace_cycle_counts;
create trigger workspace_cycle_counts_set_updated_at
before update on public.workspace_cycle_counts
for each row execute function public.set_updated_at();

alter table public.workspace_cycle_counts enable row level security;

drop policy if exists "Workspace members can select cycle counts"
on public.workspace_cycle_counts;
create policy "Workspace members can select cycle counts"
on public.workspace_cycle_counts for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Managers can insert cycle counts"
on public.workspace_cycle_counts;
create policy "Managers can insert cycle counts"
on public.workspace_cycle_counts for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can update cycle counts"
on public.workspace_cycle_counts;
create policy "Managers can update cycle counts"
on public.workspace_cycle_counts for update
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
)
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can delete cycle counts"
on public.workspace_cycle_counts;
create policy "Managers can delete cycle counts"
on public.workspace_cycle_counts for delete
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

grant select, insert, update, delete
on public.workspace_cycle_counts to authenticated;

create table if not exists public.workspace_cycle_count_lines (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  workspace_cycle_count_id uuid references public.workspace_cycle_counts(id) on delete cascade,
  workspace_item_id uuid references public.workspace_items(id) on delete set null,
  local_count_line_id text not null,
  local_count_id text not null,
  local_item_id text not null,
  location_id text,
  location_name text,
  bin_id text,
  bin_name text,
  expected_quantity numeric,
  counted_quantity numeric not null default 0,
  variance_quantity numeric,
  variance_value numeric,
  status text,
  counted_at timestamptz,
  counted_by_user_id uuid references auth.users(id),
  counted_by_name text,
  counted_by_email text,
  notes text,
  source_device_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint workspace_cycle_count_lines_workspace_local_line_unique
    unique (workspace_id, local_count_line_id),
  constraint workspace_cycle_count_lines_status_check
    check (
      status is null or
      status in ('draft', 'assigned', 'submitted', 'approved')
    )
);

create index if not exists workspace_cycle_count_lines_workspace_id_idx
on public.workspace_cycle_count_lines (workspace_id);

create index if not exists workspace_cycle_count_lines_cycle_count_id_idx
on public.workspace_cycle_count_lines (workspace_cycle_count_id);

create index if not exists workspace_cycle_count_lines_workspace_item_id_idx
on public.workspace_cycle_count_lines (workspace_item_id);

create index if not exists workspace_cycle_count_lines_local_item_id_idx
on public.workspace_cycle_count_lines (local_item_id);

create index if not exists workspace_cycle_count_lines_local_count_id_idx
on public.workspace_cycle_count_lines (local_count_id);

drop trigger if exists workspace_cycle_count_lines_set_updated_at
on public.workspace_cycle_count_lines;
create trigger workspace_cycle_count_lines_set_updated_at
before update on public.workspace_cycle_count_lines
for each row execute function public.set_updated_at();

alter table public.workspace_cycle_count_lines enable row level security;

drop policy if exists "Workspace members can select cycle count lines"
on public.workspace_cycle_count_lines;
create policy "Workspace members can select cycle count lines"
on public.workspace_cycle_count_lines for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Managers can insert cycle count lines"
on public.workspace_cycle_count_lines;
create policy "Managers can insert cycle count lines"
on public.workspace_cycle_count_lines for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can update cycle count lines"
on public.workspace_cycle_count_lines;
create policy "Managers can update cycle count lines"
on public.workspace_cycle_count_lines for update
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
)
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can delete cycle count lines"
on public.workspace_cycle_count_lines;
create policy "Managers can delete cycle count lines"
on public.workspace_cycle_count_lines for delete
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

grant select, insert, update, delete
on public.workspace_cycle_count_lines to authenticated;
