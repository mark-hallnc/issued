-- Production sync security hardening.
-- This migration is intentionally data-preserving. It tightens workspace RLS,
-- member-management rules, sync-client ownership, and hard-delete exposure.

create or replace function public.is_workspace_member(workspace uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.workspace_members wm
    where wm.workspace_id = workspace
      and wm.user_id = (select auth.uid())
      and wm.status = 'active'
  );
$$;

create or replace function public.has_workspace_role(workspace uuid, allowed_roles text[])
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.workspace_members wm
    where wm.workspace_id = workspace
      and wm.user_id = (select auth.uid())
      and wm.status = 'active'
      and wm.role = any(allowed_roles)
  );
$$;

create or replace function public.is_workspace_owner(workspace uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.has_workspace_role(workspace, array['owner']);
$$;

create or replace function public.workspace_owner_count(workspace uuid)
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select count(*)::integer
  from public.workspace_members wm
  where wm.workspace_id = workspace
    and wm.role = 'owner'
    and wm.status = 'active';
$$;

revoke all on function public.is_workspace_member(uuid) from public, anon;
revoke all on function public.has_workspace_role(uuid, text[]) from public, anon;
revoke all on function public.is_workspace_owner(uuid) from public, anon;
revoke all on function public.workspace_owner_count(uuid) from public, anon;
grant execute on function public.is_workspace_member(uuid) to authenticated;
grant execute on function public.has_workspace_role(uuid, text[]) to authenticated;
grant execute on function public.is_workspace_owner(uuid) to authenticated;
grant execute on function public.workspace_owner_count(uuid) to authenticated;

create or replace function public.prevent_last_workspace_owner_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    if old.role = 'owner'
        and old.status = 'active'
        and public.workspace_owner_count(old.workspace_id) <= 1 then
      raise exception 'A workspace must keep at least one active owner';
    end if;
    return old;
  end if;

  if old.role = 'owner'
      and old.status = 'active'
      and (
        new.role <> 'owner'
        or new.status <> 'active'
        or new.workspace_id <> old.workspace_id
      )
      and public.workspace_owner_count(old.workspace_id) <= 1 then
    raise exception 'A workspace must keep at least one active owner';
  end if;

  return new;
end;
$$;

drop trigger if exists workspace_members_prevent_last_owner
on public.workspace_members;
create trigger workspace_members_prevent_last_owner
before update or delete on public.workspace_members
for each row execute function public.prevent_last_workspace_owner_change();

-- Workspace membership and invites.
alter table public.workspaces enable row level security;
alter table public.workspace_members enable row level security;
alter table public.workspace_invites enable row level security;

drop policy if exists "Workspace members can select workspaces" on public.workspaces;
create policy "Workspace members can select workspaces"
on public.workspaces for select
to authenticated
using (public.is_workspace_member(id));

drop policy if exists "Owners and admins can update workspaces" on public.workspaces;
create policy "Owners and admins can update workspaces"
on public.workspaces for update
to authenticated
using (public.has_workspace_role(id, array['owner', 'admin']))
with check (public.has_workspace_role(id, array['owner', 'admin']));

drop policy if exists "Workspace members can select members" on public.workspace_members;
create policy "Workspace members can select members"
on public.workspace_members for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Owners and admins can manage members" on public.workspace_members;
drop policy if exists "Users can insert their owner membership" on public.workspace_members;
drop policy if exists "Owners can insert members" on public.workspace_members;
create policy "Owners can insert members"
on public.workspace_members for insert
to authenticated
with check (
  public.is_workspace_owner(workspace_id)
);

drop policy if exists "Admins can insert non-owner members" on public.workspace_members;
create policy "Admins can insert non-owner members"
on public.workspace_members for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin'])
  and role <> 'owner'
);

drop policy if exists "Owners can update all members" on public.workspace_members;
create policy "Owners can update all members"
on public.workspace_members for update
to authenticated
using (public.is_workspace_owner(workspace_id))
with check (public.is_workspace_owner(workspace_id));

drop policy if exists "Admins can update non-owner members" on public.workspace_members;
create policy "Admins can update non-owner members"
on public.workspace_members for update
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin'])
  and role <> 'owner'
)
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin'])
  and role <> 'owner'
);

drop policy if exists "Owners can delete members" on public.workspace_members;
create policy "Owners can delete members"
on public.workspace_members for delete
to authenticated
using (public.is_workspace_owner(workspace_id));

drop policy if exists "Admins can delete non-owner members" on public.workspace_members;
create policy "Admins can delete non-owner members"
on public.workspace_members for delete
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin'])
  and role <> 'owner'
);

drop policy if exists "Workspace members can select invites" on public.workspace_invites;
create policy "Workspace members can select invites"
on public.workspace_invites for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Owners and admins can manage invites" on public.workspace_invites;
drop policy if exists "Owners and admins can insert invites" on public.workspace_invites;
create policy "Owners and admins can insert invites"
on public.workspace_invites for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin'])
  and role <> 'owner'
);

drop policy if exists "Owners and admins can update invites" on public.workspace_invites;
create policy "Owners and admins can update invites"
on public.workspace_invites for update
to authenticated
using (public.has_workspace_role(workspace_id, array['owner', 'admin']))
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin'])
  and role <> 'owner'
);

drop policy if exists "Owners and admins can delete invites" on public.workspace_invites;
create policy "Owners and admins can delete invites"
on public.workspace_invites for delete
to authenticated
using (public.has_workspace_role(workspace_id, array['owner', 'admin']));

-- Sync metadata.
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

drop policy if exists "Users can select own sync client" on public.sync_clients;
create policy "Users can select own sync client"
on public.sync_clients for select
to authenticated
using (
  user_id = (select auth.uid())
  and public.is_workspace_member(workspace_id)
);

drop policy if exists "Users can insert own sync client" on public.sync_clients;
create policy "Users can insert own sync client"
on public.sync_clients for insert
to authenticated
with check (
  user_id = (select auth.uid())
  and public.is_workspace_member(workspace_id)
);

drop policy if exists "Users can update own sync client" on public.sync_clients;
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

drop policy if exists "Users can delete own sync client" on public.sync_clients;
create policy "Users can delete own sync client"
on public.sync_clients for delete
to authenticated
using (
  user_id = (select auth.uid())
  and public.is_workspace_member(workspace_id)
);

-- Business sync tables. RLS is row-level isolation; cost columns remain
-- app-hidden for restricted roles until column-level views/RPCs are added.
alter table public.workspace_items enable row level security;
alter table public.workspace_inventory_balances enable row level security;
alter table public.workspace_inventory_transactions enable row level security;
alter table public.workspace_checkouts enable row level security;
alter table public.workspace_suppliers enable row level security;
alter table public.workspace_purchase_orders enable row level security;
alter table public.workspace_cycle_counts enable row level security;
alter table public.workspace_cycle_count_lines enable row level security;

drop policy if exists "Workspace members can select items" on public.workspace_items;
create policy "Workspace members can select items"
on public.workspace_items for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Managers can insert items" on public.workspace_items;
create policy "Managers can insert items"
on public.workspace_items for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can update items" on public.workspace_items;
create policy "Managers can update items"
on public.workspace_items for update
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
)
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can delete items" on public.workspace_items;
create policy "Managers can delete items"
on public.workspace_items for delete
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Workspace members can select balances"
on public.workspace_inventory_balances;
create policy "Workspace members can select balances"
on public.workspace_inventory_balances for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Inventory editors can insert balances"
on public.workspace_inventory_balances;
drop policy if exists "Managers can insert balances"
on public.workspace_inventory_balances;
create policy "Managers can insert balances"
on public.workspace_inventory_balances for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Inventory editors can update balances"
on public.workspace_inventory_balances;
drop policy if exists "Managers can update balances"
on public.workspace_inventory_balances;
create policy "Managers can update balances"
on public.workspace_inventory_balances for update
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
)
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can delete balances"
on public.workspace_inventory_balances;

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
drop policy if exists "Workers can update issue and return transactions"
on public.workspace_inventory_transactions;
drop policy if exists "Managers can delete transactions"
on public.workspace_inventory_transactions;

drop policy if exists "Workspace members can select checkouts"
on public.workspace_checkouts;
create policy "Workspace members can select checkouts"
on public.workspace_checkouts for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Managers can insert checkouts" on public.workspace_checkouts;
create policy "Managers can insert checkouts"
on public.workspace_checkouts for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can update checkouts" on public.workspace_checkouts;
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
drop policy if exists "Workers can update checkouts" on public.workspace_checkouts;
drop policy if exists "Managers can delete checkouts" on public.workspace_checkouts;

drop policy if exists "Workspace members can select suppliers"
on public.workspace_suppliers;
create policy "Workspace members can select suppliers"
on public.workspace_suppliers for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Managers can insert suppliers" on public.workspace_suppliers;
create policy "Managers can insert suppliers"
on public.workspace_suppliers for insert
to authenticated
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can update suppliers" on public.workspace_suppliers;
create policy "Managers can update suppliers"
on public.workspace_suppliers for update
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
)
with check (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

drop policy if exists "Managers can delete suppliers" on public.workspace_suppliers;
create policy "Managers can delete suppliers"
on public.workspace_suppliers for delete
to authenticated
using (
  public.has_workspace_role(workspace_id, array['owner', 'admin', 'manager'])
);

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
