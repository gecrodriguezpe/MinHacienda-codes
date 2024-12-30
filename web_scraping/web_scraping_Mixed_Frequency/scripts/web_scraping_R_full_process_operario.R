# Código proceso de Web Scraping completo en R

# 1. Preliminares ---------------------------------------------------------

# Limpieza del entorno de trabajo
rm(list = ls())

# Directorio de trabajo 

## Scripts
scripts = "C:/Users/germa/Desktop/UNAL/BID/Proyecto_web_scraping_personal/web_scraping_Mixed_Frequency/scripts"

# Bases de datos

# Entrada 
input = "C:/Users/germa/Desktop/UNAL/BID/Proyecto_web_scraping_personal/web_scraping_Mixed_Frequency/bases_datos/input_web_scraping"

# Salida
bases_descargadas = "C:/Users/germa/Desktop/UNAL/BID/Proyecto_web_scraping_personal/web_scraping_Mixed_Frequency/bases_datos/output_web_scraping/bases_descargadas"
bases_finales = "C:/Users/germa/Desktop/UNAL/BID/Proyecto_web_scraping_personal/web_scraping_Mixed_Frequency/bases_datos/output_web_scraping/bases_finales"

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
input_MF_descarga = read_xlsx("input_web_scraping_MF.xlsx", sheet = "descarga")

# 2.2 Excel con el input necesario para el procesamiento de las bases de datos de las fuentes originales ----

## Input para el procesamiento de las bases mensuales
input_MF_procesamiento_bases_mensuales = read_xlsx("input_web_scraping_MF.xlsx", sheet = "procesamiento_bases_M")

## Input para el procesamiento de las bases trismestrales
input_MF_procesamiento_bases_trimestrales = read_xlsx("input_web_scraping_MF.xlsx", sheet = "procesamiento_bases_T")

# 2.3 Excel con las bases finales pre-actualización de los datos ----

## Input para el procesamiento de las bases mensuales
base_final_pre_actualizada_mensual = read.xlsx("base_final_pre_actualizacion.xlsx", sheet = "variables_mensuales", startRow = 1)

## Input para el procesamiento de las bases trimestrales
base_final_pre_actualizada_trimestral = read.xlsx("base_final_pre_actualizacion.xlsx", sheet = "variables_trimestrales", startRow = 1)

# 3. Descarga de las bases de datos vía Web Scraping ----------------------------------------------------
setwd(bases_descargadas)

# ¿El operario quiere descargar las bases de datos? Sí o No?
decision_operario_descargar_bases(funcion_descarga_bases = descarga_automatica_bases, 
                                  input_MF_descarga, 
                                  tmp_sleep = 40, 
                                  tmp_falla = 210)

# 4. Procesamiento de las bases de datos descargadas por Web Scraping -------------------------------------------------

# 4.1 Procesamiento de las bases de datos ----

## Procesamiento de las bases mensuales
setwd(bases_descargadas)

base_procesada_mensual = procesamiento_datos_modelos(input_MF_procesamiento_bases_mensuales,
                                                     year_filter = 2000,
                                                     generar_base = FALSE,
                                                     name_excel = "base_variables_descargadas_mensuales_MF.xlsx",
                                                     dir_salida = bases_finales,
                                                     path_microsoft_office = path_microsoft_office,
                                                     path_bases_descargadas = bases_descargadas,
                                                     tmp_sleep = 2)

## Procesamiento de las bases trimestrales
setwd(bases_descargadas)

base_procesada_trimestral = procesamiento_datos_modelos(input_MF_procesamiento_bases_trimestrales,
                                                        year_filter = 2005,
                                                        generar_base = FALSE, 
                                                        name_excel = "base_variables_descargadas_trimestrales_MF.xlsx",
                                                        dir_salida = bases_finales,
                                                        path_microsoft_office = path_microsoft_office, 
                                                        path_bases_descargadas = bases_descargadas,
                                                        tmp_sleep = 2)

# 4.2 Actualización de las bases de datos ----

## Función que realiza la actualización de la base mensual de lo modelos de MF
base_final_actualizada_mensual = actualizacion_bases_finales(base_final_pre_actualizada_mensual,
                                                       base_procesada_mensual,
                                                       year_filter = 2000,
                                                       periodicidad = "1 month",
                                                       generar_base = TRUE,
                                                       name_excel = "base_variables_actualizadas_mensuales_MF.xlsx",
                                                       start_fecha = "2000-01-01",
                                                       dir_salida = bases_finales)

## Función que realiza la actualización de la base trimestral de lo modelos de MF
base_final_actualizada_trimestral = actualizacion_bases_finales(base_final_pre_actualizada_trimestral,
                                                       base_procesada_trimestral,
                                                       year_filter = 2005,
                                                       periodicidad = "3 months",
                                                       generar_base = TRUE,
                                                       name_excel = "base_variables_actualizadas_trimestrales_MF.xlsx",
                                                       start_fecha = "2005-01-01",
                                                       dir_salida = bases_finales)

# 4.3 Generación de la base de datos final ----

## Base que contiene tanto los datos finales actualizados
combinar_bases_en_un_solo_excel(name_excel = "base_todas_variables_actualizadas_MF.xlsx",
                                dir_salida = bases_finales,
                                variables_mensuales = base_final_actualizada_mensual,
                                variables_trimestrales = base_final_actualizada_trimestral)

