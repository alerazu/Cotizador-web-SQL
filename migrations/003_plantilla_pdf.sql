-- 003: formato personalizable de exportación a PDF
CREATE TABLE plantilla_pdf (
  id             INTEGER PRIMARY KEY,
  nombre         TEXT NOT NULL,
  color_primario TEXT NOT NULL DEFAULT '#1F4E79',
  mostrar_logo   INTEGER NOT NULL DEFAULT 1 CHECK (mostrar_logo IN (0,1)),
  pie_de_pagina  TEXT
);
ALTER TABLE cotizacion ADD COLUMN plantilla_id INTEGER REFERENCES plantilla_pdf(id);
