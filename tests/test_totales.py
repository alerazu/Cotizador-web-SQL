import sys, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).parent.parent))
from migrate import migrar

def nueva(incluye, tasa=0.19):
    con = migrar()
    con.execute("INSERT INTO cotizacion(id, precios_incluyen_impuesto, impuesto_tasa) VALUES (1, ?, ?)", (incluye, tasa))
    con.executemany("INSERT INTO cotizacion_item(cotizacion_id, producto, cantidad, precio_unitario) VALUES (1,?,?,?)",
                    [("Tubo PVC", 2, 5000), ("Llave", 1, 10000)])
    return con

def test_precios_incluyen_iva():
    r = nueva(1).execute("SELECT suma, neto, impuesto, total FROM v_cotizacion_totales").fetchone()
    assert r[3] == 20000 and round(r[1] + r[2]) == 20000 and round(r[1]) == 16807

def test_precios_sin_iva():
    r = nueva(0).execute("SELECT neto, impuesto, total FROM v_cotizacion_totales").fetchone()
    assert r[0] == 20000 and round(r[1]) == 3800 and round(r[2]) == 23800

def test_impuesto_personalizado():
    r = nueva(0, 0.16).execute("SELECT total FROM v_cotizacion_totales").fetchone()
    assert round(r[0]) == 23200

def test_cantidad_invalida():
    con = nueva(1)
    try:
        con.execute("INSERT INTO cotizacion_item(cotizacion_id, producto, cantidad, precio_unitario) VALUES (1,'x',0,1)")
        assert False
    except Exception as e:
        assert "CHECK" in str(e)

if __name__ == "__main__":
    for n, f in list(globals().items()):
        if n.startswith("test_"):
            f(); print("ok", n)
