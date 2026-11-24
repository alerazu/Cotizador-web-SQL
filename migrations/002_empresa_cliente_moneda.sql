-- 002: datos de la empresa y del cliente, moneda por país, nombre de impuesto personalizable
CREATE TABLE moneda (
  codigo    TEXT PRIMARY KEY,
  simbolo   TEXT NOT NULL,
  decimales INTEGER NOT NULL DEFAULT 2
);
INSERT INTO moneda VALUES ('CLP','$',0),('USD','US$',2),('EUR','€',2),('MXN','$',2),('ARS','$',2),('COP','$',0),('PEN','S/',2);

CREATE TABLE empresa (
  id        INTEGER PRIMARY KEY,
  nombre    TEXT NOT NULL,
  id_fiscal TEXT,
  direccion TEXT,
  telefono  TEXT,
  correo    TEXT,
  logo_path TEXT
);

CREATE TABLE cliente (
  id       INTEGER PRIMARY KEY,
  nombre   TEXT NOT NULL,
  contacto TEXT
);

ALTER TABLE cotizacion ADD COLUMN empresa_id INTEGER REFERENCES empresa(id);
ALTER TABLE cotizacion ADD COLUMN cliente_id INTEGER REFERENCES cliente(id);
ALTER TABLE cotizacion ADD COLUMN moneda TEXT NOT NULL DEFAULT 'CLP' REFERENCES moneda(codigo);
ALTER TABLE cotizacion ADD COLUMN impuesto_nombre TEXT NOT NULL DEFAULT 'IVA';
