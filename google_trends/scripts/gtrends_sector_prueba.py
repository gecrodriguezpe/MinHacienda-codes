# Descripcion del script: Descarga las palabras de Google Trends por sector

# Librerias de trabajo 
import time 
import os   # Funcionalidades que permiten trabajar con el sistema operativo directamente 
import pandas as pd  # Liberaría pandas para trabajar con "dataframes" en python
from pytrends.request import TrendReq 
import urllib3

# Importar la función del script "gtrends_functions" que permite hacer la descarga de las palabras de Google Trends por sector
from gtrends_functions import busqueda_google_trends

# Especificar el directorio de trabajo principal del Script actual 
main = f"{os.getcwd()}\../"   

## Industria 

busqueda_google_trends(input_file = f"{main}bases_de_datos/input/gtrends_input.xlsx",
                       output_file = f"{main}bases_de_datos/output/info_comun_gtrends.csv",
                       sector_name = "info_comun", 
                       group_size = 1,
                       words_before_stop = 1, 
                       slp_time_words = 10, 
                       slp_time_groups = 30)

# Suspendo "60 segundos" después de descargar las palabras de GTrends para un sector
print("\nNext Sector. Sleeping 60 segs\n" )
time.sleep(60)            




