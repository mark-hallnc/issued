-- Cloud checkout record sync only.
-- This migration intentionally does not create purchasing, supplier document,
-- cycle count session, push notification, or background worker tables.

create table if not exists public.workspace_checkouts (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  workspace_item_id uuid references public.workspace_items(id) on delete set null,
  local_checkout_id text not null,
  local_item_id text not null,
  quantity numeric not null,
  quantity_returned numeric not null default 0,
  status text not null,
  checked_out_to_type text,
  checked_out_to_id text,
  checked_out_to_label text,
  person_id text,
  person_name text,
  assignment_type text,
  assignment_id text,
  assignment_label text,
  due_at timestamptz,
  checked_out_at timestamptz not null,
  returned_at timestamptz,
  checked_out_by_user_id uuid references auth.users(id),
  checked_out_by_name text,
  checked_out_by_email text,
  returned_by_user_id uuid references auth.users(id),
  returned_by_name text,
  returned_by_email text,
  notes text,
  source_device_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint workspace_checkouts_workspace_local_checkout_unique
    unique (workspace_id, local_checkout_id),
  constraint workspace_checkouts_status_check
    check (
      status in (
        'open',
        'partiallyReturned',
        'returned',
        'damaged',
        'lost',
        'cancelled',
        'checkedOut'
      )
    )
);

create index if not exists workspace_checkouts_workspace_id_idx
on public.workspace_checkouts (workspace_id);

create index if not exists workspace_checkouts_workspace_item_id_idx
on public.workspace_checkouts (workspace_item_id);

create index if not exists workspace_checkouts_local_item_id_idx
on public.workspace_checkouts (local_item_id);

create index if not exists workspace_checkouts_status_idx
on public.workspace_checkouts (status);

create index if not exists workspace_checkouts_due_at_idx
on public.workspace_checkouts (due_at);

create index if not exists workspace_checkouts_checked_out_to_idx
on public.workspace_checkouts (checked_out_to_type, checked_out_to_id);

create index if not exists workspace_checkouts_person_id_idx
on public.workspace_checkouts (person_id);

drop trigger if exists workspace_checkouts_set_updated_at
on public.workspace_checkouts;
create trigger workspace_checkouts_set_updated_at
before update on public.workspace_checkouts
for each row execute function public.set_updated_at();

alter table public.workspace_checkouts enable row level security;

drop policy if exists "Workspace members can select checkouts"
on public.workspace_checkouts;
create policy "Workspace members can select checkouts"
on public.workspace_checkouts for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Managers can insert checkouts"
on public.workspace_checkouts;
create policy "Managers can insert checkouts"
on public.workspace_checkouts for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can update checkouts"
on public.workspace_checkouts;
create policy "Managers can update checkouts"
on public.workspace_checkouts for update
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
)
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Workers can insert and return checkouts"
on public.workspace_checkouts;
create policy "Workers can insert and return checkouts"
on public.workspace_checkouts for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['worker'])
);

drop policy if exists "Workers can update checkouts"
on public.workspace_checkouts;
create policy "Workers can update checkouts"
on public.workspace_checkouts for update
to authenticated
using (
  public.has_workspace_role(workspace_id, array['worker'])
)
with check (
  public.has_workspace_role(workspace_id, array['worker'])
);

drop policy if exists "Managers can delete checkouts"
on public.workspace_checkouts;
create policy "Managers can delete checkouts"
on public.workspace_checkouts for delete
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

grant select, insert, update, delete
on public.workspace_checkouts to authenticated;
