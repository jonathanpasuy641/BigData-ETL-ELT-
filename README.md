# ETL Big Data — Gaseosas Poderosas (ET0155, Grupo 8)

Proceso ETL en PostgreSQL + Python para el caso de estudio "Gaseosas Poderosas": carga de departamentos/municipios del DANE, limpieza de 10.000 registros de ventas, consultas analíticas y visualización.

## Estructura del repo

```
.
├── algoritmo-etl-G8.py               # Carga departamentos/municipios y valoriza id_region
├── algoritmo-calculo-tamanio-G8.py   # Mide tiempo/tamaño para N registros aleatorios
├── colombia-dane-departamentos.csv   # Fuente de datos del DANE
├── sql/
│   ├── script-base-datos-creacion.sql        # Crea el esquema (tablas)
│   ├── script-base-datos-operaciones.sql     # Carga las 10.000 operaciones originales
│   ├── script-base-datos-vista.sql           # Crea vista_operaciones
│   ├── script-base-datos-regiones.sql        # Tabla regiones + campo id_region
│   ├── script-limpieza-transformacion.sql    # Limpieza de los 30 registros con errores
│   └── consultas/                            # Las 6 consultas SQL pedidas (q7.1 a q7.6)
├── docs/
│   ├── bigdata-et0155-tarea-ETL-v2-graficos-equipo_8.xlsx # Gráficos en Excel
│   └── bigdata-et0155-tarea-ETL-v2-informe-equipo_8.docx # Informe
```

## Cómo correrlo

Requiere PostgreSQL 16 (local o en Docker) y Python 3 con `psycopg2-binary`.

```bash
# 1. Crear el esquema y cargar los datos base
psql -d bigdata -f sql/script-base-datos-creacion.sql
psql -d bigdata -f sql/script-base-datos-operaciones.sql
psql -d bigdata -f sql/script-base-datos-vista.sql
psql -d bigdata -f sql/script-base-datos-regiones.sql

# 2. Cargar departamentos/municipios y valorizar id_region
python3 algoritmo-etl-G8.py

# 3. Limpiar los registros con errores (fechas, cantidades, códigos en 0)
psql -d bigdata -f sql/script-limpieza-transformacion.sql

# 4. Correr las consultas
psql -d bigdata -f sql/consultas/q71.sql   # ... hasta q76.sql

# 5. (Opcional) medir tiempo/tamaño de procesamiento
python3 algoritmo-calculo-tamanio-G8.py 10000
```

## Contenido

- **Diagrama E-R (Chen)** y **diccionario de datos**: dentro del informe.
- **30 registros con errores** detectados y corregidos (fechas mal formateadas, cantidades en 0/negativas, departamentos/productos sin código), documentados con `modificado`/`causa` en `operaciones`.
- **6 consultas SQL** sobre `vista_operaciones` con sus gráficos de Pareto/torta en el Excel.

## Equipo

Grupo 8 — Jonathan David Pasuy González

## Video de sustentación

(pegar aquí el enlace una vez grabado)
