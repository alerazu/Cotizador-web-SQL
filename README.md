# Cotizador-web-SQL

Modelo de datos en Supabase (PostgreSQL) de [Cotizador Rápido](https://github.com/alerazu/cotizador_web), versionado como migraciones y con pruebas automáticas.

## Qué contiene
- `profiles`: perfil por usuario con prueba de 15 días (`trial_ends_at`) y preferencias (`settings`).
- `quotes`: historial de cotizaciones, con numeración correlativa por usuario.
- `clients`: clientes guardados; si se borra uno, la cotización conserva el nombre.
- Seguridad a nivel de fila (RLS): cada usuario ve solo lo suyo, y con la prueba vencida solo puede ver el historial.

## Versionamiento
Cada cambio al esquema es una migración nueva en `supabase/migrations/`, con nombre `AAAAMMDDHHMMSS_descripcion.sql` (el formato de la CLI de Supabase). Una migración ya publicada no se edita: los cambios van en una nueva.

## Pruebas
`run_tests.sh` crea una base temporal, simula lo mínimo de Supabase (`auth.users`, `auth.uid()`, roles), aplica las migraciones en orden y verifica las reglas de `supabase/tests/01_reglas.sql`:
perfil automático al registrarse, `trial_ends_at` protegido, numeración correlativa e inmutable, aislamiento entre usuarios, cliente borrado y prueba vencida.

```
PGHOST=/ruta/socket PGUSER=postgres ./run_tests.sh
```
