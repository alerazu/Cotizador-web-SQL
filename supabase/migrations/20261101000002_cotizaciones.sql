-- Historial de cotizaciones.
create table if not exists public.quotes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  number integer not null default 0,
  client_name text not null default '',
  currency text not null default 'CLP',
  total numeric not null default 0,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists quotes_user_created_idx on public.quotes (user_id, created_at desc);

alter table public.quotes enable row level security;

-- Ver el historial siempre se puede; crear, editar y borrar exige acceso vigente.
create policy "quotes_select_own" on public.quotes
  for select using (auth.uid() = user_id);
create policy "quotes_insert_own" on public.quotes
  for insert with check (auth.uid() = user_id and public.has_access());
create policy "quotes_update_own" on public.quotes
  for update using (auth.uid() = user_id and public.has_access())
  with check (auth.uid() = user_id and public.has_access());
create policy "quotes_delete_own" on public.quotes
  for delete using (auth.uid() = user_id and public.has_access());

-- Numeración correlativa por usuario y marca de última edición.
create or replace function public.quotes_before_write()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    select coalesce(max(number), 0) + 1 into new.number
    from public.quotes where user_id = new.user_id;
  else
    new.number := old.number;
    new.user_id := old.user_id;
  end if;
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists quotes_before_write on public.quotes;
create trigger quotes_before_write
  before insert or update on public.quotes
  for each row execute function public.quotes_before_write();
