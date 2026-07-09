-- Token-based workspace invite links for app links and web fallback pages.

alter table public.workspace_invites
add column if not exists invite_token text;

update public.workspace_invites
set invite_token = encode(gen_random_bytes(32), 'hex')
where invite_token is null;

alter table public.workspace_invites
alter column invite_token set not null;

create unique index if not exists workspace_invites_invite_token_key
on public.workspace_invites (invite_token);

create or replace function public.accept_workspace_invite_by_token(p_token text)
returns table (
  workspace_id uuid,
  workspace_name text,
  role text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  caller_id uuid := auth.uid();
  caller_email text := lower(coalesce(auth.jwt() ->> 'email', ''));
  clean_token text := nullif(trim(p_token), '');
  selected_invite public.workspace_invites%rowtype;
begin
  if caller_id is null then
    raise exception 'Not authenticated';
  end if;
  if caller_email = '' then
    raise exception 'Authenticated email is required';
  end if;
  if clean_token is null then
    raise exception 'Invite link is missing or invalid';
  end if;

  select *
  into selected_invite
  from public.workspace_invites wi
  where wi.invite_token = clean_token
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
  if selected_invite.role = 'owner' then
    raise exception 'Owner invites are not allowed';
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

  return query
  select w.id, w.name, selected_invite.role
  from public.workspaces w
  where w.id = selected_invite.workspace_id;
end;
$$;

revoke all on function public.accept_workspace_invite_by_token(text)
from public, anon;
grant execute on function public.accept_workspace_invite_by_token(text)
to authenticated;
