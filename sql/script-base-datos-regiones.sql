-- ============================================================
-- ET0155 - Fundamentos de Big Data - Grupo 8
-- Script: creación de tabla "regiones" y campo "id_region"
-- Este script agrega el nivel jerárquico "región" al modelo,
-- que originalmente solo llegaba hasta departamento/municipio.
-- ============================================================

-- Tabla de regiones (las 6 regiones que trae la hoja de cálculo del DANE)
-- DROP TABLE IF EXISTS public.regiones;
CREATE TABLE IF NOT EXISTS public.regiones(
    id_region integer NOT NULL,
    nombre    character varying(50) NOT NULL,
    CONSTRAINT regiones_pkey PRIMARY KEY (id_region)
);

INSERT INTO regiones (id_region, nombre) VALUES
    (1, 'Region Eje Cafetero - Antioquia'),
    (2, 'Region Centro Oriente'),
    (3, 'Region Centro Sur'),
    (4, 'Region Caribe'),
    (5, 'Region Llano'),
    (6, 'Region Pacifico')
ON CONFLICT (id_region) DO NOTHING;

-- La tabla "departamentos" ya traía un campo "codigo_region" (se llena
-- en el algoritmo-etl.py original), así que ahí no hace falta agregar
-- ninguna columna nueva; solo se documenta como clave foránea hacia
-- "regiones" en el diccionario de datos.
ALTER TABLE public.departamentos
    ADD CONSTRAINT departamentos_region_fkey
    FOREIGN KEY (codigo_region) REFERENCES public.regiones(id_region)
    NOT VALID; -- se valida después de la limpieza

-- Campo nuevo requerido por el enunciado: "operaciones" no traía región
ALTER TABLE public.operaciones
    ADD COLUMN IF NOT EXISTS id_region integer DEFAULT 0;

-- Campos de trazabilidad de la limpieza de datos (punto 6 del informe)
ALTER TABLE public.operaciones
    ADD COLUMN IF NOT EXISTS modificado character varying(1) DEFAULT 'N';
ALTER TABLE public.operaciones
    ADD COLUMN IF NOT EXISTS causa text;
