-- Pruebas de las reglas del modelo. Falla (ON_ERROR_STOP) si alguna no se cumple.
\set ON_ERROR_STOP on

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'a@test.cl'),
  ('00000000-0000-0000-0000-00000000000b', 'b@test.cl');

-- 1. Al registrarse se crea el perfil con ~15 días de prueba
do $$ begin
  assert (select count(*) from public.profiles) = 2, 'se crea un perfil por usuario';
  assert (select min(trial_ends_at) > now() + interval '14 days 23 hours' from public.profiles), 'prueba de 15 días';
end $$;

-- 2. El usuario puede cambiar settings, pero no trial_ends_at
set role authenticated;
select set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-00000000000a', false);
update public.profiles set settings = '{"country":"CL"}' where id = auth.uid();
do $$ begin
  begin
    update public.profiles set trial_ends_at = now() + interval '10 years' where id = auth.uid();
    assert false, 'no debía permitir cambiar trial_ends_at';
  exception when insufficient_privilege then null;
  end;
end $$;

-- 3. Numeración correlativa por usuario y número inmutable
insert into public.quotes (client_name, total) values ('Cliente 1', 100), ('Cliente 2', 200);
update public.quotes set number = 99 where client_name = 'Cliente 1';
do $$ begin
  assert (select array_agg(number order by number) from public.quotes) = array[1,2], 'numeración 1,2 e inmutable';
end $$;

-- 4. Cada usuario ve solo lo suyo
select set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-00000000000b', false);
insert into public.quotes (client_name) values ('Cliente de B');
do $$ begin
  assert (select count(*) from public.quotes) = 1, 'B solo ve su cotización';
  assert (select min(number) from public.quotes) = 1, 'la numeración de B parte en 1';
end $$;

-- 5. Cliente borrado: la cotización conserva el nombre y client_id queda en null
insert into public.clients (name) values ('Ferretería Sur');
update public.quotes set client_id = (select id from public.clients limit 1);
delete from public.clients;
do $$ begin
  assert (select client_id is null and client_name = 'Cliente de B' from public.quotes), 'cotización conserva el nombre';
end $$;

-- 6. Prueba vencida: se puede ver el historial, pero no crear ni borrar
reset role;
update public.profiles set trial_ends_at = now() - interval '1 day'
  where id = '00000000-0000-0000-0000-00000000000b';
set role authenticated;
select set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-00000000000b', false);
do $$ begin
  assert (select count(*) from public.quotes) = 1, 'el historial sigue visible';
  begin
    insert into public.quotes (client_name) values ('No debería');
    assert false, 'no debía permitir crear con la prueba vencida';
  exception when insufficient_privilege or check_violation then null;
  end;
  delete from public.quotes;
  assert (select count(*) from public.quotes) = 1, 'no se puede borrar con la prueba vencida';
end $$;

reset role;
select 'OK: todas las pruebas pasaron' as resultado;
