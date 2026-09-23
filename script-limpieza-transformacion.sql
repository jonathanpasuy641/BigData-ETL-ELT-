-- ============================================================
-- ET0155 - Fundamentos de Big Data - Grupo 8
-- Script de LIMPIEZA / TRANSFORMACIÓN / IMPUTACIÓN de "operaciones"
-- Se detectaron 5 tipos de problema (30 registros en total sobre 10.000)
-- Cada UPDATE deja registrado en "modificado" y "causa" qué se hizo,
-- tal como pide el punto 6 del informe.
-- ============================================================

-- ------------------------------------------------------------
-- TIPO A - Fechas con formato distinto a AAAA-MM-DD (10 registros)
-- Cada fecha se revisó a mano: se ubicó cuál de los 3 bloques del
-- valor original NO podía ser mes (valor mayor a 12) para saber si
-- el bloque era el día, y así reconstruir la fecha real.
-- ------------------------------------------------------------
UPDATE operaciones SET fecha = '2024-08-21', modificado = 'S',
  causa = 'Tipo A - Fecha "2024-8-21" sin cero en el mes, se normaliza a AAAA-MM-DD'
  WHERE id_registro = 10001;
UPDATE operaciones SET fecha = '2024-02-08', modificado = 'S',
  causa = 'Tipo A - Fecha "24-02-08" con año de 2 dígitos, se completa el siglo'
  WHERE id_registro = 11599;
UPDATE operaciones SET fecha = '2024-07-17', modificado = 'S',
  causa = 'Tipo A - Fecha "024-07-17" con año incompleto (falta un dígito)'
  WHERE id_registro = 12110;
UPDATE operaciones SET fecha = '2024-12-13', modificado = 'S',
  causa = 'Tipo A - Fecha "13-12-2024" en formato DD-MM-AAAA'
  WHERE id_registro = 13945;
UPDATE operaciones SET fecha = '2024-10-28', modificado = 'S',
  causa = 'Tipo A - Fecha "24-28-10" en formato AA-DD-MM (28 no puede ser mes)'
  WHERE id_registro = 14368;
UPDATE operaciones SET fecha = '2024-09-27', modificado = 'S',
  causa = 'Tipo A - Fecha "24-27-09" en formato AA-DD-MM (27 no puede ser mes)'
  WHERE id_registro = 15955;
UPDATE operaciones SET fecha = '2024-02-01', modificado = 'S',
  causa = 'Tipo A - Fecha "01-02-24" en formato DD-MM-AA'
  WHERE id_registro = 16558;
UPDATE operaciones SET fecha = '2024-12-12', modificado = 'S',
  causa = 'Tipo A - Fecha "12-12-2024" en formato DD-MM-AAAA'
  WHERE id_registro = 17125;
UPDATE operaciones SET fecha = '2024-09-09', modificado = 'S',
  causa = 'Tipo A - Fecha "24-09-09" con año de 2 dígitos, se completa el siglo'
  WHERE id_registro = 18056;
UPDATE operaciones SET fecha = '2024-11-23', modificado = 'S',
  causa = 'Tipo A - Fecha "11-23-2024" en formato MM-DD-AAAA (23 no puede ser mes)'
  WHERE id_registro = 19680;

-- ------------------------------------------------------------
-- TIPO B - Cantidades en 0 (5 registros)
-- Se imputa con el promedio de cantidad vendida en ese MISMO municipio,
-- considerando solo registros con cantidad > 0 (para no contaminar el
-- promedio con ceros o negativos)
-- ------------------------------------------------------------
UPDATE operaciones o SET
    cantidad = sub.promedio,
    modificado = 'S',
    causa = 'Tipo B - Cantidad en 0, imputada con el promedio de ventas del municipio (' || sub.promedio || ')'
FROM (
    SELECT o2.id_municipio, ROUND(AVG(o2.cantidad)) AS promedio
    FROM operaciones o2
    WHERE o2.cantidad > 0
    GROUP BY o2.id_municipio
) sub
WHERE o.id_municipio = sub.id_municipio AND o.cantidad = 0;

-- ------------------------------------------------------------
-- TIPO C - Cantidades negativas (5 registros)
-- Error de digitación del operador: el dato es correcto, solo se
-- corrige el signo
-- ------------------------------------------------------------
UPDATE operaciones SET
    cantidad = ABS(cantidad),
    modificado = 'S',
    causa = 'Tipo C - Cantidad negativa por error de digitación, se corrige el signo'
WHERE cantidad < 0;

-- ------------------------------------------------------------
-- TIPO D - Falta el código de departamento (5 registros, id_departamento = 0)
-- Se recupera a partir del propio id_municipio, ya que este se
-- construyó como (id_departamento * 1000 + consecutivo)
-- ------------------------------------------------------------
UPDATE operaciones SET
    id_departamento = (id_municipio / 1000),
    modificado = 'S',
    causa = 'Tipo D - Código de departamento en 0, recuperado a partir del código de municipio'
WHERE id_departamento = 0;

-- ------------------------------------------------------------
-- TIPO E - Falta el código de producto en Tamesis, Antioquia
-- (en ese municipio solo se vende NARANJITA, id_producto = 4)
-- ------------------------------------------------------------
UPDATE operaciones SET
    id_producto = 4,
    modificado = 'S',
    causa = 'Tipo E - Código de producto en 0 en Tamesis (Antioquia), único producto vendido allí: NARANJITA'
WHERE id_producto = 0
  AND id_municipio = (SELECT id_municipio FROM municipios WHERE nombre = 'Tamesis' AND id_departamento = 5705);

-- ------------------------------------------------------------
-- Registros sin ningún problema -> se marcan como válidos
-- ------------------------------------------------------------
UPDATE operaciones SET modificado = 'N', causa = 'Registro válido, sin cambios'
WHERE modificado IS NULL OR modificado = 'N';

-- ------------------------------------------------------------
-- VALORIZACIÓN DEL CAMPO id_region (requerimiento del punto 5)
-- Se obtiene por el departamento de cada operación
-- ------------------------------------------------------------
UPDATE operaciones o SET id_region = d.codigo_region
FROM departamentos d
WHERE d.id_departamento = o.id_departamento;

-- ------------------------------------------------------------
-- Verificación final: la vista debe devolver el mismo total que
-- la tabla "operaciones" (10.000). Si aquí faltara algo, se
-- perdería en el JOIN de la vista
-- ------------------------------------------------------------
-- SELECT (SELECT count(*) FROM operaciones) AS total_operaciones,
--        (SELECT count(*) FROM vista_operaciones) AS total_vista;
