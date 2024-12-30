# Código proceso de Web Scraping completo en R

# 1. Preliminares ---------------------------------------------------------

# Limpieza del entorno de trabajo
rm(list = ls())

# Directorio de trabajo 

## Scripts
scripts = "C:/Users/germa/Desktop/UNAL/BID/Proyecto_web_scraping_personal/web_scraping_3PRF/V4/scripts"

## Bases de datos

# Entrada 
input = "C:/Users/germa/Desktop/UNAL/BID/Proyecto_web_scraping_personal/web_scraping_3PRF/V4/bases_datos/input_web_scraping"

# Salida
bases_descargadas = "C:/Users/germa/Desktop/UNAL/BID/Proyecto_web_scraping_personal/web_scraping_3PRF/V4/bases_datos/output_web_scraping/bases_descargadas"
bases_finales = "C:/Users/germa/Desktop/UNAL/BID/Proyecto_web_scraping_personal/web_scraping_3PRF/V4/bases_datos/output_web_scraping/bases_finales"

## Directorio de instalación de Microsoft office
path_microsoft_office = "C:/Program Files/Microsoft Office/root/Office16"

# Imporación de las funciones para realizar el proceso de Research
setwd(scripts)

# Se traen de los scripts las funciones para el proceso de Web Scraping

## Script con las funciones de descarga
source("web_scraping_R_funciones_descarga.R")

## Script con las funciones para el procesamiento de las bases de datos 
source("web_scraping_R_funciones_procesamiento_bases.R")

# 2. Importación de datos -------------------------------------------------
setwd(input)

# 2.1 Excel con el input necesario para la descarga de las bases de datos de las fuentes originales de Intenet ----
input_3PRF_descarga = read_xlsx("input_web_scraping_3PRF.xlsx", sheet = "descarga")

# 2.2 Excel con el input necesario para el procesamiento de las bases de datos de las fuentes originales ----

## Input para el procesamiento de las bases mensuales
input_3PRF_procesamiento_bases_mensuales = read_xlsx("input_web_scraping_3PRF.xlsx", sheet = "procesamiento_bases")

# 2.3 Excel con las bases finales pre-actualización de los datos ----

## Input para el procesamiento de las bases mensuales (Excel con la "base original del 3PRF" antes de la actualización de los datos)
base_final_pre_actualizada_mensual = read.xlsx("nuevo_variables 3PRF(pre_actualizada).xlsx", sheet = "Variables (Base)", startRow = 5)

# 3. Descarga de las bases de datos vía Web Scraping ----------------------------------------------------
setwd(bases_descargadas)

# ¿El operario quiere descargar las bases de datos? Sí o No?
decision_operario_descargar_bases(funcion_descarga_bases = descarga_automatica_bases, 
                                  input_3PRF_descarga, 
                                  tmp_sleep = 40, 
                                  tmp_falla = 210) 

# 4. Procesamiento de las bases de datos descargadas por Web Scraping -------------------------------------------------

# 4.1 Procesamiento de las bases de datos ----

## Procesamiento de las bases mensuales
setwd(bases_descargadas)

base_actualizada_xts = procesamiento_datos_modelos(input_3PRF_procesamiento_bases_mensuales,
                                               year_filter = 2000,
                                               generar_base = TRUE,
                                               name_excel = "base_variables_descargadas_mensuales_3PRF.xlsx",
                                               dir_salida = bases_finales,
                                               path_microsoft_office = path_microsoft_office,
                                               path_bases_descargadas = bases_descargadas,
                                               tmp_sleep = 3)

# 4.2 Actualización de las bases de datos ----

## Función que realiza la actualización de la base mensual del modelo del 3PRF
base_3PRF_final_xts = actualizacion_bases_finales(base_final_pre_actualizada_mensual,
                                              base_actualizada_xts,
                                              year_filter = 2000,
                                              periodicidad = "1 month",
                                              generar_base = TRUE,
                                              name_excel = "base_3PRF_actualizada.xlsx",
                                              start_fecha = "2000-01-01",
                                              dir_salida = bases_finales)
