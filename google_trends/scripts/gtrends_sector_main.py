# Descripcion del script: Descarga las palabras de Google Trends por sector

# Librerias de trabajo 
import time 
import os   # Funcionalidades que permiten trabajar con el sistema operativo directamente 
import pandas as pd  # Liberaría pandas para trabajar con "dataframes" en python
from pytrends.request import TrendReq 
import urllib3

# Importar la función del script "gtrends_functions" que permite hacer la descarga de las palabras de Google Trends por sector
from gtrends_functions_mejorada import busqueda_google_trends

# Especificar el directorio de trabajo principal del Script actual 
main = f"{os.getcwd()}/../"

# Especificar tamaño de grupos y palabras para descargar a la vez
GROUP_SIZE = 5
WORDS_BEFORE_STOP = 1

# Espeificar tiempos de ejecucióngternf
SLP_TIME_WORDS = 30
SLP_TIME_GROUPS = 60
SLP_TIME_SECTORS = 300


# 1. PIB (Agregado)

busqueda_google_trends(input_file = f"{main}bases_de_datos/input/gtrends_input.xlsx",
                       output_file = f"{main}bases_de_datos/output/pib_agregado_gtrends.csv",
                       sector_name = "PIB_agregado", 
                       group_size = GROUP_SIZE,
                       words_before_stop = WORDS_BEFORE_STOP, 
                       slp_time_words = SLP_TIME_WORDS, 
                       slp_time_groups = SLP_TIME_GROUPS)

# Suspendo "60 segundos" después de descargar las palabras de GTrends para un sector
print("\nNext Sector. Sleeping 60 segs\n" )
time.sleep(SLP_TIME_SECTORS)            

# 2. Valores agregados sectoriales  

## 2.1 Informacion y comunicaciones

busqueda_google_trends(input_file = f"{main}bases_de_datos/input/gtrends_input.xlsx",
                       output_file = f"{main}bases_de_datos/output/info_comun_gtrends.csv",
                       sector_name = "info_comun", 
                       group_size = GROUP_SIZE,
                       words_before_stop = WORDS_BEFORE_STOP, 
                       slp_time_words = SLP_TIME_WORDS, 
                       slp_time_groups = SLP_TIME_GROUPS)

# Suspendo "60 segundos" después de descargar las palabras de GTrends para un sector
print("\nNext Sector. Sleeping 60 segs\n" )
time.sleep(SLP_TIME_SECTORS)            

## Actividades artisticas 

busqueda_google_trends(input_file = f"{main}bases_de_datos/input/gtrends_input.xlsx",
                       output_file = f"{main}bases_de_datos/output/act_arts_gtrends.csv",
                       sector_name = "act_arts", 
                       group_size = GROUP_SIZE,
                       words_before_stop = WORDS_BEFORE_STOP, 
                       slp_time_words = SLP_TIME_WORDS, 
                       slp_time_groups = SLP_TIME_GROUPS)

# Suspendo "60 segundos" después de descargar las palabras de GTrends para un sector
print("\nNext Sector. Sleeping 60 segs\n" )
time.sleep(SLP_TIME_SECTORS)            

## Consumo privado 

busqueda_google_trends(input_file = f"{main}bases_de_datos/input/gtrends_input.xlsx",
                       output_file = f"{main}bases_de_datos/output/cons_priv_gtrends.csv",
                       sector_name = "cons_priv", 
                       group_size = GROUP_SIZE,
                       words_before_stop = WORDS_BEFORE_STOP, 
                       slp_time_words = SLP_TIME_WORDS, 
                       slp_time_groups = SLP_TIME_GROUPS)

# Suspendo "60 segundos" después de descargar las palabras de GTrends para un sector
print("\nNext Sector. Sleeping 60 segs\n" )
time.sleep(SLP_TIME_SECTORS)            

## Comercio minorista mayorista

busqueda_google_trends(input_file = f"{main}bases_de_datos/input/gtrends_input.xlsx",
                       output_file = f"{main}bases_de_datos/output/comercio_gtrends.csv",
                       sector_name = "comercio", 
                       group_size = GROUP_SIZE,
                       words_before_stop = WORDS_BEFORE_STOP, 
                       slp_time_words = SLP_TIME_WORDS, 
                       slp_time_groups = SLP_TIME_GROUPS)

# Suspendo "60 segundos" después de descargar las palabras de GTrends para un sector
print("\nNext Sector. Sleeping 60 segs\n" )
time.sleep(SLP_TIME_SECTORS)            

## Transporte y almacenamiento 

busqueda_google_trends(input_file = f"{main}bases_de_datos/input/gtrends_input.xlsx",
                       output_file = f"{main}bases_de_datos/output/trans_almac_gtrends.csv",
                       sector_name = "trans_almac", 
                       group_size = GROUP_SIZE,
                       words_before_stop = WORDS_BEFORE_STOP, 
                       slp_time_words = SLP_TIME_WORDS, 
                       slp_time_groups = SLP_TIME_GROUPS)

# Suspendo "60 segundos" después de descargar las palabras de GTrends para un sector
print("\nNext Sector. Sleeping 60 segs\n" )
time.sleep(SLP_TIME_SECTORS)            

## Alojamiento y comida

busqueda_google_trends(input_file = f"{main}bases_de_datos/input/gtrends_input.xlsx",
                       output_file = f"{main}bases_de_datos/output/aloj_comida_gtrends.csv",
                       sector_name = "aloj_comida", 
                       group_size = GROUP_SIZE,
                       words_before_stop = WORDS_BEFORE_STOP, 
                       slp_time_words = SLP_TIME_WORDS, 
                       slp_time_groups = SLP_TIME_GROUPS)

# Suspendo "60 segundos" después de descargar las palabras de GTrends para un sector
print("\nNext Sector. Sleeping 60 segs\n" )
time.sleep(SLP_TIME_SECTORS)            

## Profesionales

busqueda_google_trends(input_file = f"{main}bases_de_datos/input/gtrends_input.xlsx",
                       output_file = f"{main}bases_de_datos/output/profesionales_gtrends.csv",
                       sector_name = "profesionales", 
                       group_size = GROUP_SIZE,
                       words_before_stop = WORDS_BEFORE_STOP, 
                       slp_time_words = SLP_TIME_WORDS, 
                       slp_time_groups = SLP_TIME_GROUPS)

# Suspendo "60 segundos" después de descargar las palabras de GTrends para un sector
print("\nNext Sector. Sleeping 60 segs\n" )
time.sleep(SLP_TIME_SECTORS)            

## Industria 

busqueda_google_trends(input_file = f"{main}bases_de_datos/input/gtrends_input.xlsx",
                       output_file = f"{main}bases_de_datos/output/industria_gtrends.csv",
                       sector_name = "industria", 
                       group_size = GROUP_SIZE,
                       words_before_stop = WORDS_BEFORE_STOP, 
                       slp_time_words = SLP_TIME_WORDS, 
                       slp_time_groups = SLP_TIME_GROUPS)

# Suspendo "60 segundos" después de descargar las palabras de GTrends para un sector
print("\nNext Sector. Sleeping 60 segs\n" )
time.sleep(SLP_TIME_SECTORS)            




