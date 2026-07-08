-- Cloud inventory movement history sync only.
-- This migration intentionally does not create checkout workflow, purchase
-- order, cycle count session, or server-side balance calculation tables.

create table if not exists public.workspace_inventory_transactions (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  workspace_item_id uuid references public.workspace_items(id) on delete set null,
  local_transaction_id text not null,
  local_item_id text not null,
  transaction_type text not null,
  quantity_delta numeric not null,
  quantity_before numeric,
  quantity_after numeric,
  location_id text,
  location_name text,
  bin_id text,
  bin_name text,
  related_checkout_id text,
  related_purchase_order_id text,
  related_count_id text,
  assignment_type text,
  assignment_id text,
  assignment_label text,
  reason text,
  notes text,
  performed_by_user_id uuid references auth.users(id),
  performed_by_name text,
  performed_by_email text,
  source_device_id text,
  occurred_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint workspace_inventory_transactions_workspace_local_txn_unique
    unique (workspace_id, local_transaction_id)
);

create index if not exists workspace_inventory_transactions_workspace_id_idx
on public.workspace_inventory_transactions (workspace_id);

create index if not exists workspace_inventory_transactions_workspace_item_id_idx
on public.workspace_inventory_transactions (workspace_item_id);

create index if not exists workspace_inventory_transactions_local_item_id_idx
on public.workspace_inventory_transactions (local_item_id);

create index if not exists workspace_inventory_transactions_occurred_at_idx
on public.workspace_inventory_transactions (occurred_at);

create index if not exists workspace_inventory_transactions_type_idx
on public.workspace_inventory_transactions (transaction_type);

create index if not exists workspace_inventory_transactions_assignment_idx
on public.workspace_inventory_transactions (assignment_type, assignment_id);

drop trigger if exists workspace_inventory_transactions_set_updated_at
on public.workspace_inventory_transactions;
create trigger workspace_inventory_transactions_set_updated_at
before update on public.workspace_inventory_transactions
for each row execute function public.set_updated_at();

alter table public.workspace_inventory_transactions enable row level security;

drop policy if exists "Workspace members can select transactions"
on public.workspace_inventory_transactions;
create policy "Workspace members can select transactions"
on public.workspace_inventory_transactions for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Managers can insert transactions"
on public.workspace_inventory_transactions;
create policy "Managers can insert transactions"
on public.workspace_inventory_transactions for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can update transactions"
on public.workspace_inventory_transactions;
create policy "Managers can update transactions"
on public.workspace_inventory_transactions for update
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
)
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Workers can insert issue and return transactions"
on public.workspace_inventory_transactions;
create policy "Workers can insert issue and return transactions"
on public.workspace_inventory_transactions for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['worker'])
  and transaction_type in ('issue', 'checkout', 'returnItem', 'markLost', 'markDamaged')
);

drop policy if exists "Workers can update issue and return transactions"
on public.workspace_inventory_transactions;
create policy "Workers can update issue and return transactions"
on public.workspace_inventory_transactions for update
to authenticated
using (
  public.has_workspace_role(workspace_id, array['worker'])
  and transaction_type in ('issue', 'checkout', 'returnItem', 'markLost', 'markDamaged')
)
with check (
  public.has_workspace_role(workspace_id, array['worker'])
  and transaction_type in ('issue', 'checkout', 'returnItem', 'markLost', 'markDamaged')
);

drop policy if exists "Managers can delete transactions"
on public.workspace_inventory_transactions;
create policy "Managers can delete transactions"
on public.workspace_inventory_transactions for delete
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

grant select, insert, update, delete
on public.workspace_inventory_transactions to authenticated;
