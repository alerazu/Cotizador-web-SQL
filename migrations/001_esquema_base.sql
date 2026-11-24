-- 001: cotización con ítems (producto, cantidad, precio)
CREATE TABLE cotizacion (
  id                        INTEGER PRIMARY KEY,
  numero                    TEXT,
  fecha                     TEXT NOT NULL DEFAULT (date('now')),
  precios_incluyen_impuesto INTEGER NOT NULL DEFAULT 1 CHECK (precios_incluyen_impuesto IN (0,1)),
  impuesto_tasa             REAL NOT NULL DEFAULT 0.19 CHECK (impuesto_tasa >= 0),
  notas                     TEXT
);

CREATE TABLE cotizacion_item (
  id              INTEGER PRIMARY KEY,
  cotizacion_id   INTEGER NOT NULL REFERENCES cotizacion(id) ON DELETE CASCADE,
  orden           INTEGER NOT NULL DEFAULT 0,
  producto        TEXT NOT NULL,
  cantidad        REAL NOT NULL CHECK (cantidad > 0),
  precio_unitario REAL NOT NULL CHECK (precio_unitario >= 0)
);
CREATE INDEX ix_item_cotizacion ON cotizacion_item(cotizacion_id);

-- Totales: si los precios incluyen impuesto, el total es la suma y el neto se deriva
CREATE VIEW v_cotizacion_totales AS
SELECT c.id AS cotizacion_id,
       s.suma,
       CASE c.precios_incluyen_impuesto WHEN 1 THEN s.suma / (1 + c.impuesto_tasa) ELSE s.suma END AS neto,
       CASE c.precios_incluyen_impuesto WHEN 1 THEN s.suma - s.suma / (1 + c.impuesto_tasa)
            ELSE s.suma * c.impuesto_tasa END AS impuesto,
       CASE c.precios_incluyen_impuesto WHEN 1 THEN s.suma ELSE s.suma * (1 + c.impuesto_tasa) END AS total
FROM cotizacion c
JOIN (SELECT cotizacion_id, SUM(cantidad * precio_unitario) AS suma
      FROM cotizacion_item GROUP BY cotizacion_id) s ON s.cotizacion_id = c.id;
