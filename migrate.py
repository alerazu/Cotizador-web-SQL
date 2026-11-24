"""Aplica en orden las migraciones pendientes. Uso: python3 migrate.py [cotizador.db]"""
import sqlite3, sys, pathlib

def migrar(db_path=":memory:"):
    con = sqlite3.connect(db_path)
    con.execute("PRAGMA foreign_keys = ON")
    con.execute("CREATE TABLE IF NOT EXISTS schema_migrations (version TEXT PRIMARY KEY, aplicada_en TEXT DEFAULT CURRENT_TIMESTAMP)")
    hechas = {r[0] for r in con.execute("SELECT version FROM schema_migrations")}
    for f in sorted(pathlib.Path(__file__).parent.joinpath("migrations").glob("*.sql")):
        if f.stem in hechas:
            continue
        con.executescript(f.read_text(encoding="utf-8"))
        con.execute("INSERT INTO schema_migrations(version) VALUES (?)", (f.stem,))
        con.commit()
        print("aplicada", f.stem)
    return con

if __name__ == "__main__":
    migrar(sys.argv[1] if len(sys.argv) > 1 else "cotizador.db")
