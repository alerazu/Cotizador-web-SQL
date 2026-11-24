# cotizador-sql

Modelo SQL (SQLite, el motor de Android) de la app de cotizaciones: ítems con producto, cantidad y precio, total con IVA incluido o no, moneda por país, impuesto personalizable, datos de empresa y cliente, y plantilla de PDF.

## Versionamiento
- Cada cambio al esquema es una migración numerada y nunca se edita después de publicarla: `migrations/NNN_descripcion.sql`.
- `migrate.py` aplica las pendientes y las registra en `schema_migrations`.
- Los totales viven en la vista `v_cotizacion_totales`.

## Uso
```
python3 migrate.py cotizador.db
python3 tests/test_totales.py
```
