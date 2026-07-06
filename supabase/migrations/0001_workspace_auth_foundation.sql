-- Issued cloud auth/workspace foundation.
-- Invite delivery will be handled by a future Edge Function using a service role key.
-- The Flutter client must never receive the service role key or call admin auth APIs.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.workspaces (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.workspace_members (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  email text not null,
  display_name text,
  role text not null check (role in ('owner', 'admin', 'manager', 'worker', 'viewOnly')),
  status text not null check (status in ('active', 'invited', 'disabled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(workspace_id, user_id)
);

create table if not exists public.workspace_invites (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  email text not null,
  role text not null check (role in ('admin', 'manager', 'worker', 'viewOnly')),
  status text not null check (status in ('pending', 'accepted', 'revoked', 'expired')),
  invited_by uuid references auth.users(id),
  invited_user_id uuid references auth.users(id),
  created_at timestamptz not null default now(),
  accepted_at timestamptz,
  expires_at timestamptz,
  unique(workspace_id, email)
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists workspaces_set_updated_at on public.workspaces;
create trigger workspaces_set_updated_at
before update on public.workspaces
for each row execute function public.set_updated_at();

drop trigger if exists workspace_members_set_updated_at on public.workspace_members;
create trigger workspace_members_set_updated_at
before update on public.workspace_members
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.workspaces enable row level security;
alter table public.workspace_members enable row level security;
alter table public.workspace_invites enable row level security;

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

create or replace function public.has_workspace_role(
  workspace uuid,
  allowed_roles text[]
)
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

revoke all on function public.is_workspace_member(uuid) from public, anon;
revoke all on function public.has_workspace_role(uuid, text[]) from public, anon;
grant execute on function public.is_workspace_member(uuid) to authenticated;
grant execute on function public.has_workspace_role(uuid, text[]) to authenticated;

drop policy if exists "Users can select own profile" on public.profiles;
create policy "Users can select own profile"
on public.profiles for select
to authenticated
using ((select auth.uid()) = id);

drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile"
on public.profiles for insert
to authenticated
with check ((select auth.uid()) = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
on public.profiles for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

drop policy if exists "Authenticated users can create workspaces" on public.workspaces;
create policy "Authenticated users can create workspaces"
on public.workspaces for insert
to authenticated
with check ((select auth.uid()) = created_by);

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
create policy "Owners and admins can manage members"
on public.workspace_members for all
to authenticated
using (public.has_workspace_role(workspace_id, array['owner', 'admin']))
with check (public.has_workspace_role(workspace_id, array['owner', 'admin']));

drop policy if exists "Users can insert their owner membership" on public.workspace_members;
create policy "Users can insert their owner membership"
on public.workspace_members for insert
to authenticated
with check (
  user_id = (select auth.uid())
  and role = 'owner'
  and status = 'active'
);

drop policy if exists "Workspace members can select invites" on public.workspace_invites;
create policy "Workspace members can select invites"
on public.workspace_invites for select
to authenticated
using (public.is_workspace_member(workspace_id));

drop policy if exists "Owners and admins can manage invites" on public.workspace_invites;
create policy "Owners and admins can manage invites"
on public.workspace_invites for all
to authenticated
using (public.has_workspace_role(workspace_id, array['owner', 'admin']))
with check (public.has_workspace_role(workspace_id, array['owner', 'admin']));

create or replace function public.create_workspace_with_owner(workspace_name text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  new_workspace_id uuid;
  caller_id uuid := auth.uid();
  caller_email text := coalesce(auth.jwt() ->> 'email', '');
  clean_workspace_name text := nullif(trim(workspace_name), '');
begin
  if caller_id is null then
    raise exception 'Not authenticated';
  end if;
  if clean_workspace_name is null then
    raise exception 'Workspace name is required';
  end if;

  insert into public.profiles (id, email)
  values (caller_id, caller_email)
  on conflict (id) do update
  set email = excluded.email;

  insert into public.workspaces (name, created_by)
  values (clean_workspace_name, caller_id)
  returning id into new_workspace_id;

  insert into public.workspace_members (
    workspace_id,
    user_id,
    email,
    role,
    status
  )
  values (
    new_workspace_id,
    caller_id,
    caller_email,
    'owner',
    'active'
  );

  return new_workspace_id;
end;
$$;

revoke all on function public.create_workspace_with_owner(text) from public, anon;
grant execute on function public.create_workspace_with_owner(text) to authenticated;

grant usage on schema public to authenticated;
grant select, insert, update on public.profiles to authenticated;
grant select, insert, update on public.workspaces to authenticated;
grant select, insert, update, delete on public.workspace_members to authenticated;
grant select, insert, update, delete on public.workspace_invites to authenticated;
