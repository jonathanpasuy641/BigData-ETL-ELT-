# -*- coding: utf-8 -*-
"""
@Institución: IU Pascual Bravo
@Docente    : Jaime E Soto U
@asignatura : ET0155 - Fundamentos de BigData
@Grupo      : G0100 - Equipo 8
@Tarea      : Tarea Unidad 2
@Módulo     : Carga aleatoria de operaciones de venta
@Función    : Calculo de tiempo de procesamiento y tamaño de almacenamiento

MODIFICACIONES DEL EQUIPO respecto al algoritmo original:
 1) Se corrigió el nombre de la base de datos (v_database) para que
    coincida con la base "bigdata" usada en el resto de la tarea, y la
    consulta de pg_database_size() que apuntaba a "bigdata-g050".
 2) Se agregó el control de tiempo de procesamiento (time_inicio /
    time_fin) pedido en el punto 10 del informe.
 3) Se cambió la selección aleatoria de municipio: en vez de lanzar un
    SELECT ... ORDER BY RANDOM() contra la base de datos en CADA
    iteración (que es muy costoso), se trae la lista de municipios UNA
    sola vez a memoria y se elige con random.choice(). Con esto se
    pudieron correr las 10.000 y 100.000 filas en un tiempo razonable.
"""
import time
import sys
import random
import psycopg2
from   psycopg2 import Error

# Variables globales
error_con = False

# Parámetros de conexión de la Base de datos local
v_host     = "localhost"
v_port     = "5432"
v_database = "bigdata"
v_user     = "postgres"
v_password = "postgres"


# -----------------------------------------------------------------------
# Función:  Cargar Operaciones
# -----------------------------------------------------------------------
def cargarOperaciones(conn, cur, reg, dep, mun, prod, fec, cant):
    command = '''INSERT INTO tamanio (id_registro,
                                    id_departamento, id_municipio, id_producto,
                                    fecha, cantidad, estado)
                 VALUES (%s,%s,%s,%s,%s,%s,%s);'''
    cur.execute(command, (reg, dep, mun, prod, fec, cant, 'V'))
    # Fin función cargarOperaciones


# --------------------------------------------------------------------------
# CONEXIÓN A LA BASE DE DATOS
# --------------------------------------------------------------------------
try:
    connection = psycopg2.connect(user=v_user, password=v_password, host=v_host,
                                   port=v_port, database=v_database)
    cursor = connection.cursor()
    cursor.execute("SELECT version();")
    record = cursor.fetchone()
    print("PostgreSQL Información del Servidor")
    print("Python version: ", sys.version)
    print("Estás conectado a - ", record, "\n")
    print("Base de datos:", v_database, "\n")
    command = '''TRUNCATE tamanio;'''
    cursor.execute(command)
    connection.commit()
except (Exception, Error) as error:
    print("Error: ", error)
    error_con = True
finally:
    if error_con:
        sys.exit("Error de conexión con servidor PostgreSQL")


# --------------------------------------------------------------------------
# Generación aleatoria de operaciones de ventas
# --------------------------------------------------------------------------
try:
    registros = int(sys.argv[1]) if len(sys.argv) > 1 else 10000
    lote = 500000  # commit cada 500.000 filas, para no perder avance

    # Se trae la lista de municipios una sola vez (mejora de rendimiento)
    cursor.execute("SELECT id_departamento, id_municipio FROM municipios;")
    lista_municipios = cursor.fetchall()

    # -------------------------------------------------------------------
    # TIEMPO INICIO
    # -------------------------------------------------------------------
    tiempo_inicio = time.time()

    for iteracion in range(1, registros + 1):
        id_producto = random.randint(1, 4)
        cantidad = random.randint(1, 5000)
        dia = str(random.randint(1, 28)).zfill(2)
        mes = str(random.randint(1, 12)).zfill(2)
        anio = "2023"
        fecha = f"{anio}-{mes}-{dia}"  # ya se genera en formato AAAA-MM-DD

        id_departamento, id_municipio = random.choice(lista_municipios)

        cargarOperaciones(connection, cursor, iteracion, id_departamento,
                           id_municipio, id_producto, fecha, cantidad)

        if iteracion % lote == 0:
            connection.commit()

    connection.commit()

    # -------------------------------------------------------------------
    # TIEMPO FINAL
    # -------------------------------------------------------------------
    tiempo_fin = time.time()
    tiempo_procesamiento_ms = round((tiempo_fin - tiempo_inicio) * 1000, 2)
    print(f"Registros generados: {registros}")
    print(f"Tiempo de procesamiento: {tiempo_procesamiento_ms} milisegundos")

    # -------------------------------------------------------------------
    # Tamaño de la Base de datos "bigdata" y de la tabla "tamanio"
    # -------------------------------------------------------------------
    cursor.execute("SELECT pg_size_pretty(pg_database_size('bigdata'));")
    tam_bd = cursor.fetchall()
    print("Tamaño de la base de datos: ", tam_bd)

    cursor.execute("""SELECT relname as "Table",
                       pg_size_pretty(pg_total_relation_size(relid)) As "Size"
                       FROM pg_catalog.pg_statio_user_tables
                       WHERE relname = 'tamanio'
                       ORDER BY pg_total_relation_size(relid) DESC;""")
    tam_tabla = cursor.fetchall()
    print("Tamaño de la tabla 'tamanio': ", tam_tabla)

    # Resultados en bytes, para poder tabularlos con precisión en el informe
    cursor.execute("SELECT pg_database_size('bigdata');")
    bytes_bd = cursor.fetchall()[0][0]
    cursor.execute("SELECT pg_total_relation_size('tamanio');")
    bytes_tabla = cursor.fetchall()[0][0]
    print(f"Base de datos (bytes): {bytes_bd}")
    print(f"Tabla 'tamanio' (bytes): {bytes_tabla}")
    print(f"Porcentaje de 'tamanio' sobre el total: {round(bytes_tabla/bytes_bd*100, 2)} %")

except (Exception, Error) as error:
    print("Error de procesamiento de operaciones!", error)
    sys.exit("Error ->  Generación aleatoria de datos")
finally:
    if connection:
        connection.close()
        print("Conexión PostgreSQL cerrada")

print("Fin del proceso de carga aleatoria de operaciones - LOADING")
# Fin del algoritmo
