# Descripción del script: Descarga las palabras de Google Trends por sector

# Librerías de trabajo
import time
import pandas as pd
from pathlib import Path  # Para manejo de rutas compatible con todos los sistemas operativos
from pytrends.request import TrendReq
from gtrends_functions import busqueda_google_trends

# Especificar el directorio de trabajo principal del Script actual
main = Path.cwd().parent  # Un nivel arriba del directorio actual

# Especificar tamaño de grupos y palabras para descargar a la vez
GROUP_SIZE = 21
WORDS_BEFORE_STOP = 3

# Especificar tiempos de ejecución
SLP_TIME_WORDS = 20
SLP_TIME_GROUPS = 40
SLP_TIME_SECTORS = 60

# Ruta común de entrada y salida
input_file = main / "bases_de_datos" / "input" / "gtrends_input.xlsx"
output_dir = main / "bases_de_datos" / "output"

# Lista de sectores a procesar (nombre interno y nombre de archivo de salida)
sectores = [
    ("PIB_agregado",       "pib_agregado_gtrends.csv"),
    ("info_comun",         "info_comun_gtrends.csv"),
    ("act_arts",           "act_arts_gtrends.csv"),
    ("cons_priv",          "cons_priv_gtrends.csv"),
    ("comercio",           "comercio_gtrends.csv"),
    ("trans_almac",        "trans_almac_gtrends.csv"),
    ("aloj_comida",        "aloj_comida_gtrends.csv"),
    ("profesionales",      "profesionales_gtrends.csv"),
    ("industria",          "industria_gtrends.csv"),
]

# Bucle para descargar datos de cada sector
for nombre_sector, archivo_salida in sectores:
    output_file = output_dir / archivo_salida

    print(f"\nProcesando sector: {nombre_sector}")
    busqueda_google_trends(
        input_file=input_file,
        output_file=output_file,
        sector_name=nombre_sector,
        group_size=GROUP_SIZE,
        words_before_stop=WORDS_BEFORE_STOP,
        slp_time_words=SLP_TIME_WORDS,
        slp_time_groups=SLP_TIME_GROUPS
    )

    print("\nNext Sector. Sleeping 60 segs\n")
    time.sleep(SLP_TIME_SECTORS)
