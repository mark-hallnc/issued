-- Workspace invite acceptance and member safety.
-- Invite email delivery is handled by the invite-workspace-member Edge Function.

create or replace function public.accept_workspace_invite(invite_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  caller_id uuid := auth.uid();
  caller_email text := lower(coalesce(auth.jwt() ->> 'email', ''));
  selected_invite public.workspace_invites%rowtype;
begin
  if caller_id is null then
    raise exception 'Not authenticated';
  end if;
  if caller_email = '' then
    raise exception 'Authenticated email is required';
  end if;

  select *
  into selected_invite
  from public.workspace_invites wi
  where wi.id = invite_id
    and wi.status = 'pending'
  for update;

  if selected_invite.id is null then
    raise exception 'Invite is no longer available';
  end if;
  if lower(selected_invite.email) <> caller_email then
    raise exception 'Invite email does not match signed in user';
  end if;
  if selected_invite.expires_at is not null
      and selected_invite.expires_at < now() then
    update public.workspace_invites
    set status = 'expired'
    where id = selected_invite.id;
    raise exception 'Invite has expired';
  end if;

  insert into public.profiles (id, email)
  values (caller_id, caller_email)
  on conflict (id) do update
  set email = excluded.email;

  insert into public.workspace_members (
    workspace_id,
    user_id,
    email,
    display_name,
    role,
    status
  )
  values (
    selected_invite.workspace_id,
    caller_id,
    caller_email,
    null,
    selected_invite.role,
    'active'
  )
  on conflict (workspace_id, user_id) do update
  set email = excluded.email,
      role = excluded.role,
      status = 'active',
      updated_at = now();

  update public.workspace_invites
  set status = 'accepted',
      accepted_at = now(),
      invited_user_id = caller_id
  where id = selected_invite.id;

  return selected_invite.workspace_id;
end;
$$;

create or replace function public.revoke_workspace_invite(invite_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  invite_workspace_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  select workspace_id
  into invite_workspace_id
  from public.workspace_invites
  where id = invite_id;

  if invite_workspace_id is null then
    raise exception 'Invite not found';
  end if;
  if not public.has_workspace_role(
    invite_workspace_id,
    array['owner', 'admin']
  ) then
    raise exception 'Not allowed to revoke invites';
  end if;

  update public.workspace_invites
  set status = 'revoked'
  where id = invite_id
    and status = 'pending';
end;
$$;

create or replace function public.prevent_last_workspace_owner_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  other_owner_exists boolean;
begin
  if tg_op = 'DELETE' then
    if old.role = 'owner' and old.status = 'active' then
      select exists (
        select 1
        from public.workspace_members wm
        where wm.workspace_id = old.workspace_id
          and wm.id <> old.id
          and wm.role = 'owner'
          and wm.status = 'active'
      )
      into other_owner_exists;

      if not other_owner_exists then
        raise exception 'A workspace must keep at least one active owner';
      end if;
    end if;
    return old;
  end if;

  if old.role = 'owner'
      and old.status = 'active'
      and (
        new.role <> 'owner'
        or new.status <> 'active'
        or new.workspace_id <> old.workspace_id
      ) then
    select exists (
      select 1
      from public.workspace_members wm
      where wm.workspace_id = old.workspace_id
        and wm.id <> old.id
        and wm.role = 'owner'
        and wm.status = 'active'
    )
    into other_owner_exists;

    if not other_owner_exists then
      raise exception 'A workspace must keep at least one active owner';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists workspace_members_prevent_last_owner
on public.workspace_members;
create trigger workspace_members_prevent_last_owner
before update or delete on public.workspace_members
for each row execute function public.prevent_last_workspace_owner_change();

drop policy if exists "Invited users can select own pending invites"
on public.workspace_invites;
create policy "Invited users can select own pending invites"
on public.workspace_invites for select
to authenticated
using (
  status = 'pending'
  and lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
);

drop policy if exists "Invited users can select invited workspaces"
on public.workspaces;
create policy "Invited users can select invited workspaces"
on public.workspaces for select
to authenticated
using (
  exists (
    select 1
    from public.workspace_invites wi
    where wi.workspace_id = workspaces.id
      and wi.status = 'pending'
      and lower(wi.email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  )
);

revoke all on function public.accept_workspace_invite(uuid) from public, anon;
revoke all on function public.revoke_workspace_invite(uuid) from public, anon;
grant execute on function public.accept_workspace_invite(uuid) to authenticated;
grant execute on function public.revoke_workspace_invite(uuid) to authenticated;
