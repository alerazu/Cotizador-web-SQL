-- Perfil por usuario: fecha de fin de la prueba y datos de empresa/preferencias.
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  trial_ends_at timestamptz not null default (now() + interval '15 days'),
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- El usuario solo puede modificar "settings". Nunca trial_ends_at.
revoke insert, update, delete on public.profiles from anon, authenticated;
grant update (settings) on public.profiles to authenticated;

-- Crea el perfil (y con él, los 15 días de prueba) al registrarse.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ¿Tiene el usuario acceso vigente (prueba o suscripción)?
create or replace function public.has_access()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and trial_ends_at > now()
  );
$$;
