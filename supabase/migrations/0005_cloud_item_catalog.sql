-- Cloud item catalog metadata only.
-- This migration intentionally does not create quantity, balance, checkout,
-- transaction, purchase order, or cycle count tables.

create table if not exists public.workspace_items (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  local_item_id text,
  name text not null,
  sku text,
  barcode text,
  description text,
  category text,
  unit text,
  reorder_point numeric,
  reorder_quantity numeric,
  unit_cost numeric,
  is_active boolean not null default true,
  deleted_at timestamptz,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint workspace_items_workspace_local_item_id_unique
    unique (workspace_id, local_item_id)
);

create unique index if not exists workspace_items_workspace_local_item_id_key
on public.workspace_items (workspace_id, local_item_id)
where local_item_id is not null;

drop trigger if exists workspace_items_set_updated_at
on public.workspace_items;
create trigger workspace_items_set_updated_at
before update on public.workspace_items
for each row execute function public.set_updated_at();

alter table public.workspace_items enable row level security;

drop policy if exists "Workspace members can select items"
on public.workspace_items;
create policy "Workspace members can select items"
on public.workspace_items for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Managers can insert items"
on public.workspace_items;
create policy "Managers can insert items"
on public.workspace_items for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can update items"
on public.workspace_items;
create policy "Managers can update items"
on public.workspace_items for update
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
)
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can delete items"
on public.workspace_items;
create policy "Managers can delete items"
on public.workspace_items for delete
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

grant select, insert, update, delete on public.workspace_items to authenticated;
