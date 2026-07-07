-- Harden workspace member role changes beyond UI checks.
-- Owners can manage owner rows. Admins can manage manager/worker/view-only rows.

create or replace function public.prevent_unsafe_workspace_member_role_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  caller_id uuid := auth.uid();
  caller_is_owner boolean := false;
begin
  if caller_id is null then
    if tg_op = 'DELETE' then
      return old;
    end if;
    return new;
  end if;

  select exists (
    select 1
    from public.workspace_members wm
    where wm.workspace_id = old.workspace_id
      and wm.user_id = caller_id
      and wm.role = 'owner'
      and wm.status = 'active'
  )
  into caller_is_owner;

  if old.role = 'owner' and not caller_is_owner then
    raise exception 'Only workspace owners can modify owners';
  end if;

  if tg_op = 'UPDATE' and new.role = 'owner' and not caller_is_owner then
    raise exception 'Only workspace owners can assign owner role';
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

drop trigger if exists workspace_members_prevent_unsafe_role_change
on public.workspace_members;
create trigger workspace_members_prevent_unsafe_role_change
before update or delete on public.workspace_members
for each row execute function public.prevent_unsafe_workspace_member_role_change();

revoke all on function public.prevent_unsafe_workspace_member_role_change()
from public, anon;
