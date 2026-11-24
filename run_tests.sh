#!/usr/bin/env bash
# Aplica las migraciones en una base temporal con un Supabase simulado y corre las pruebas.
# Uso: PGHOST=/ruta/socket PGUSER=postgres ./run_tests.sh   (o con DATABASE_URL del servidor)
set -euo pipefail
cd "$(dirname "$0")"
DB="cotizador_test_$$"
psql -q -v ON_ERROR_STOP=1 -d postgres -c "create database $DB"
trap 'psql -q -d postgres -c "drop database if exists $DB" >/dev/null' EXIT
run() { psql -q -v ON_ERROR_STOP=1 -d "$DB" -f "$1"; }
run supabase/tests/00_stub_supabase.sql
for f in supabase/migrations/*.sql; do echo "migración: $f"; run "$f"; done
psql -q -v ON_ERROR_STOP=1 -d "$DB" -f supabase/tests/01_reglas.sql
