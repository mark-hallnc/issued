-- Cloud supplier and purchasing/reorder sync only.
-- This migration intentionally does not create supplier document storage,
-- invoice OCR, cycle count session, push notification, or background worker tables.

create table if not exists public.workspace_suppliers (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  local_supplier_id text not null,
  name text not null,
  contact_name text,
  email text,
  phone text,
  website text,
  address text,
  account_number text,
  notes text,
  default_lead_time_days integer,
  minimum_order_amount numeric,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint workspace_suppliers_workspace_local_supplier_unique
    unique (workspace_id, local_supplier_id)
);

create index if not exists workspace_suppliers_workspace_id_idx
on public.workspace_suppliers (workspace_id);

create unique index if not exists workspace_suppliers_workspace_name_key
on public.workspace_suppliers (workspace_id, lower(name))
where deleted_at is null;

drop trigger if exists workspace_suppliers_set_updated_at
on public.workspace_suppliers;
create trigger workspace_suppliers_set_updated_at
before update on public.workspace_suppliers
for each row execute function public.set_updated_at();

alter table public.workspace_suppliers enable row level security;

drop policy if exists "Workspace members can select suppliers"
on public.workspace_suppliers;
create policy "Workspace members can select suppliers"
on public.workspace_suppliers for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Managers can insert suppliers"
on public.workspace_suppliers;
create policy "Managers can insert suppliers"
on public.workspace_suppliers for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can update suppliers"
on public.workspace_suppliers;
create policy "Managers can update suppliers"
on public.workspace_suppliers for update
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
)
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can delete suppliers"
on public.workspace_suppliers;
create policy "Managers can delete suppliers"
on public.workspace_suppliers for delete
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

grant select, insert, update, delete
on public.workspace_suppliers to authenticated;

create table if not exists public.workspace_purchase_orders (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  workspace_item_id uuid references public.workspace_items(id) on delete set null,
  workspace_supplier_id uuid references public.workspace_suppliers(id) on delete set null,
  local_purchase_order_id text not null,
  local_item_id text,
  local_supplier_id text,
  supplier_name text,
  order_number text,
  status text not null,
  quantity_ordered numeric not null default 0,
  quantity_received numeric not null default 0,
  unit_cost numeric,
  total_cost numeric,
  ordered_at timestamptz,
  expected_at timestamptz,
  received_at timestamptz,
  created_by_user_id uuid references auth.users(id),
  updated_by_user_id uuid references auth.users(id),
  notes text,
  source_device_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint workspace_purchase_orders_workspace_local_po_unique
    unique (workspace_id, local_purchase_order_id),
  constraint workspace_purchase_orders_status_check
    check (
      status in (
        'needed',
        'ordered',
        'partiallyReceived',
        'received',
        'cancelled',
        'canceled'
      )
    )
);

create index if not exists workspace_purchase_orders_workspace_id_idx
on public.workspace_purchase_orders (workspace_id);

create index if not exists workspace_purchase_orders_workspace_item_id_idx
on public.workspace_purchase_orders (workspace_item_id);

create index if not exists workspace_purchase_orders_workspace_supplier_id_idx
on public.workspace_purchase_orders (workspace_supplier_id);

create index if not exists workspace_purchase_orders_status_idx
on public.workspace_purchase_orders (status);

create index if not exists workspace_purchase_orders_expected_at_idx
on public.workspace_purchase_orders (expected_at);

create index if not exists workspace_purchase_orders_ordered_at_idx
on public.workspace_purchase_orders (ordered_at);

drop trigger if exists workspace_purchase_orders_set_updated_at
on public.workspace_purchase_orders;
create trigger workspace_purchase_orders_set_updated_at
before update on public.workspace_purchase_orders
for each row execute function public.set_updated_at();

alter table public.workspace_purchase_orders enable row level security;

drop policy if exists "Workspace members can select purchase orders"
on public.workspace_purchase_orders;
create policy "Workspace members can select purchase orders"
on public.workspace_purchase_orders for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Managers can insert purchase orders"
on public.workspace_purchase_orders;
create policy "Managers can insert purchase orders"
on public.workspace_purchase_orders for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can update purchase orders"
on public.workspace_purchase_orders;
create policy "Managers can update purchase orders"
on public.workspace_purchase_orders for update
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
)
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can delete purchase orders"
on public.workspace_purchase_orders;
create policy "Managers can delete purchase orders"
on public.workspace_purchase_orders for delete
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

grant select, insert, update, delete
on public.workspace_purchase_orders to authenticated;
