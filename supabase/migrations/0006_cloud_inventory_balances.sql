-- Cloud inventory balance current-state sync only.
-- This migration intentionally does not create transaction, checkout,
-- purchase order, cycle count history, or audit log tables.

create table if not exists public.workspace_inventory_balances (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  workspace_item_id uuid references public.workspace_items(id) on delete cascade,
  local_item_id text not null,
  location_id text not null,
  location_name text,
  bin_id text,
  bin_name text,
  quantity numeric not null default 0,
  reserved_quantity numeric not null default 0,
  counted_at timestamptz,
  last_movement_at timestamptz,
  deleted_at timestamptz,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint workspace_inventory_balances_workspace_item_location_unique
    unique (workspace_id, local_item_id, location_id)
);

create index if not exists workspace_inventory_balances_workspace_id_idx
on public.workspace_inventory_balances (workspace_id);

create index if not exists workspace_inventory_balances_workspace_item_id_idx
on public.workspace_inventory_balances (workspace_item_id);

create index if not exists workspace_inventory_balances_local_item_id_idx
on public.workspace_inventory_balances (local_item_id);

drop trigger if exists workspace_inventory_balances_set_updated_at
on public.workspace_inventory_balances;
create trigger workspace_inventory_balances_set_updated_at
before update on public.workspace_inventory_balances
for each row execute function public.set_updated_at();

alter table public.workspace_inventory_balances enable row level security;

drop policy if exists "Workspace members can select balances"
on public.workspace_inventory_balances;
create policy "Workspace members can select balances"
on public.workspace_inventory_balances for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Inventory editors can insert balances"
on public.workspace_inventory_balances;
create policy "Inventory editors can insert balances"
on public.workspace_inventory_balances for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager', 'worker'])
);

drop policy if exists "Inventory editors can update balances"
on public.workspace_inventory_balances;
create policy "Inventory editors can update balances"
on public.workspace_inventory_balances for update
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager', 'worker'])
)
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager', 'worker'])
);

drop policy if exists "Managers can delete balances"
on public.workspace_inventory_balances;
create policy "Managers can delete balances"
on public.workspace_inventory_balances for delete
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

grant select, insert, update, delete
on public.workspace_inventory_balances to authenticated;
