-- Clientes guardados por usuario.
create table if not exists public.clients (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name text not null,
  tax_id text not null default '',
  email text not null default '',
  phone text not null default '',
  addr text not null default '',
  created_at timestamptz not null default now()
);

create index if not exists clients_user_name_idx on public.clients (user_id, lower(name));

alter table public.clients enable row level security;

drop policy if exists "clients_select_own" on public.clients;
drop policy if exists "clients_insert_own" on public.clients;
drop policy if exists "clients_update_own" on public.clients;
drop policy if exists "clients_delete_own" on public.clients;

create policy "clients_select_own" on public.clients
  for select using (auth.uid() = user_id);
create policy "clients_insert_own" on public.clients
  for insert with check (auth.uid() = user_id and public.has_access());
create policy "clients_update_own" on public.clients
  for update using (auth.uid() = user_id and public.has_access())
  with check (auth.uid() = user_id and public.has_access());
create policy "clients_delete_own" on public.clients
  for delete using (auth.uid() = user_id and public.has_access());

-- Cada cotización apunta a su cliente. Si se borra el cliente, la cotización conserva el nombre.
alter table public.quotes
  add column if not exists client_id uuid references public.clients (id) on delete set null;
