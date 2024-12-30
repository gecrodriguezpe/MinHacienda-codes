# Codigo con las funciones para el procesamiento de las bases descargadas vía Web Scraping en R

### Paquetes

# Paquete multiproposito de R (De lejos el paquete más importante de todo R. Fundamental para hacer "análisis de datos" en R!!)
library(tidyverse)

# Paquetes adicionales del Tidyverse
library(lubridate) # Para el manejo de fechas en R
library(stringr) # Para el manejo de "Strings" en R

# Paquetes para realizar "Web scraping" en R

## Paquetes para trabajar con páginas web que no necesiten Javascript
library(rvest)
library(xml2)

## Paquetes para trabajar con páginas web que necesiten Javascript
library(RSelenium)

## Paquetes adicionales que falicitan el "Web Scraping" en R
library(httr2) # Paquete para enviar HTTP request a "servidores web"
library(polite) # Paquete para hacer uso responsable del "Web Scraping" en la web

# Paquetes estandáres para manejo de archivos de Excel (xlsx) en R
library(readxl)
library(openxlsx)
library(data.table)
library(writexl)

# Paquetes para lidiar con "archivos complejos" de Excel que tengan información no rectangular
library(tidyxl) # Importar datos de Excel sin forzarlos a formar un rectángulo
library(unpivotr) # Para lidiar con información no tabular de Excel

# Paquete para manejo avanzado de series de tiempo en R 
library(xts)

# Paquete para manejo f-string en R 
library(glue)

# Funciones para el procesamiento de las bases descargadas por Web Scraping

# 0. Funciones auxiliares ---------------------------------------------------

# 0.1 Función para la conversión de archivos ".xls" a ".xlsx" ----

# Función de transformación de la bases en formato ".xls" a formato ".xlsx"
verificar_si_es_xls = function(nombre_base, path_microsoft_office, path_bases_descargadas, tmp_sleep){
  
  if (is.na(nombre_base)){
    
    # Pass
    
  }else if (str_ends(nombre_base, "\\.xls$")){
    
    # Nombre de la base de datos sin formato (i.e. sin ".xls" o ".xlsx")
    nombre_base_limpio = str_remove(nombre_base, "\\.(xls|xlsx)$")
    
    # Path donde se encuentra el programa de Microsoft Office necesario para transformar archivos ".xls" en archivos ".xlsx"
    path_microsoft_office_backslash = str_replace_all(path_microsoft_office, "/", "\\\\")
    
    # Path donde se encuentran las bases descargadas
    path_bases_descargadas_backslash = str_replace_all(path_bases_descargadas, "/", "\\\\")
    
    # Comando de consola de Microsoft Office que permite trasnformar un archivo ".xls" en ".xlsx"
    xls2xlsx = glue("\"{path_microsoft_office_backslash}\\excelcnv.exe\" -oice")
    
    # Ruta del archivo ".xls" y del archivo ".xlsx" al que se va a transformar
    ruta_xls = glue("\"{path_bases_descargadas_backslash}\\{nombre_base_limpio}.xls\"")
    ruta_xlsx = glue("\"{path_bases_descargadas_backslash}\\{nombre_base_limpio}.xlsx\"")
    
    args = paste(xls2xlsx, ruta_xls, ruta_xlsx)
    system("cmd.exe" , input = args)
    
    # Se pausa el programa "tmp_sleep" segundos mientras se crea el archivo ".xlsx"
    Sys.sleep(tmp_sleep)
    
    # Nombre de la base transformada a formato ".xlsx"
    return(paste0(nombre_base_limpio, ".xlsx"))
    
  }else if(str_ends(nombre_base, "\\.xlsx$")){
    
    return(nombre_base)
    
  }
  
}

# 0.2 Función para limpiar y aplanar una cadena de texto ingresada por el usario ----

# Función para procesar la cadena de texto ingresada por el usuario
limpiar_cadena_de_texto <- function(input_string) {
  
  # Remover acentos
  input_string <- stringi::stri_trans_general(input_string, "Latin-ASCII")
  
  # Convertir todo a minúscula
  input_string <- tolower(input_string)
  
  # Eliminar espacios iniciales antes de la cadena de texto y finales después de la cadena de texto
  input_string <- trimws(input_string)
  
  # Retornar la cadena de carácteres limpia
  return(input_string)
}

# 0.3 Función para preguntarle al operario si quiere o no descargar las bases de datos ----

# Función que le pregunta al operario si quiere o no descargar las bases de datos  
decision_operario_descargar_bases = function(funcion_descarga_bases, input_MF_descarga, tmp_sleep = 40, tmp_falla = 210){
  
  # Agregar while y condicional para 
  flag_descarga = TRUE
  
  # Interroga al operario frente a que acción hacer respecto a la descarga de las bases 
  while(flag_descarga){
    
    # Respuesta del operario frente a si decide o no descargar la base de datos
    respuesta_operador = readline("¿Quiere descargar las bases de datos? Responda porfa solo 'si' o 'no' para poder continuar. Respuesta: ")
    
    # Se limpia la respuesta del operario para que 1) no tenga acentos, 2) esté en minúscula y 3) no tenga espacios delanteros o traseros 
    respuesta_clean = limpiar_cadena_de_texto(respuesta_operador)
    
    if(respuesta_clean == "si"){
      # Condición que ocurre si el operario decide descargar las bases de datos
      
      # Descarga de todas las bases de datos
      funcion_descarga_bases(input_MF_descarga, tmp_sleep, tmp_falla)  
      
      # Sale del bucle
      flag_descarga = FALSE
      
      
    }else if(respuesta_clean == "no"){
      # Condición que ocurre si el operario decide NO descargar las bases de datos
      
      # Sale del bucle
      flag_descarga = FALSE
      
    }else{
      # Condición que ocurre si el operario da una opción incorrecta, es decir responde algo diferente a si o no.
      
      # Permanece en el bucle y vuelve a preguntar 
      flag_descarga = TRUE
      
    }
    
  }
  
}

# 1. Funciones para la extracción de la primera fecha de cada base ---------------------------------------------------

# 1.1 Función para la extracción del primera mes de cada base ----

# Función para la extracción del primer mes de cada base
deteccion_primer_mes = function(mes_text){
  
  if(str_detect(mes_text, regex("enero|ene", ignore_case = TRUE))){
    
    mes = 1
    
  }else if(str_detect(mes_text, regex("febrero|feb", ignore_case = TRUE))){
    
    mes = 2
    
  }else if(str_detect(mes_text, regex("marzo|mar", ignore_case = TRUE))){
    
    mes = 3
    
  }else if(str_detect(mes_text, regex("abril|abr", ignore_case = TRUE))){
    
    mes = 4
    
  }else if(str_detect(mes_text, regex("mayo|may", ignore_case = TRUE))){
    
    mes = 5
    
  }else if(str_detect(mes_text, regex("junio|jun", ignore_case = TRUE))){
    
    mes = 6
    
  }else if(str_detect(mes_text, regex("julio|jul", ignore_case = TRUE))){
    
    mes = 7
    
  }else if(str_detect(mes_text, regex("agosto|ago", ignore_case = TRUE))){
    
    mes = 8
    
  }else if(str_detect(mes_text, regex("septiembre|sep", ignore_case = TRUE))){
    
    mes = 9
    
  }else if(str_detect(mes_text, regex("octubre|oct", ignore_case = TRUE))){
    
    mes = 10
    
  }else if(str_detect(mes_text, regex("noviembre|nov", ignore_case = TRUE))){
    
    mes = 11
    
  }else if(str_detect(mes_text, regex("diciembre|dic", ignore_case = TRUE))){
    
    mes = 12
    
  }
  
  return(mes)
  
}

# 1.2 Función para la extracción del primera trimestre de cada base ----

# Función para la extracción del primer trimestre de cada base
deteccion_primer_trimestre = function(trimestre_text){
  
  if(str_detect(trimestre_text, regex("I", ignore_case = TRUE))){
    
    trimestre = 1
    
  }else if(str_detect(trimestre_text, regex("II", ignore_case = TRUE))){
    
    trimestre = 2
    
  }else if(str_detect(trimestre_text, regex("III", ignore_case = TRUE))){
    
    trimestre = 3
    
  }else if(str_detect(trimestre_text, regex("IV", ignore_case = TRUE))){
    
    trimestre = 4
    
  }
  
  return(trimestre)
  
}


# 2. Función para el procesamiento de las bases descargadas del DANE ---------------------------------------------------

# 2.1 Función para procesar las bases mensuales del DANE ----

# Función para procesar las bases mensuales del DANE
procesamiento_DANE = function(nombre_base, nombre_sheet, palabra_identificacion_tabla, nombre_variable, filtro1, filtro2, filtro3){
  
  # Importación de la base de datos mediante la función "xlsx_cells"
  base = tidyxl::xlsx_cells(nombre_base, sheets = nombre_sheet) 
  
  
  # Identificación de la esquina superior izquierda de la tabla
  esquina_sup_izq_tabla = dplyr::filter(base, character == palabra_identificacion_tabla)  
  
  # Particion de la base que contiene la informacion de la tabla de interés dentro de la hoja de excel
  particion = partition(base, esquina_sup_izq_tabla)
  
  # ==== Inicio: Específico para cada base ====
  
  # La selección de la información cambia dependiendo de la base de datos 
  if ((nombre_base == "DANE_ISE_9_actividades.xlsx") || (nombre_base == "DANE_ISE_12_actividades.xlsx")){
    
    # 2.1.1 DANE_ISE_9_actividades.xlsx ó DANE_ISE_12_actividades.xlsx ----
    
    # Código para la base de datos que contiene las variables del "ISE"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up-left", "año") %>%
      behead("up", "mes") %>%
      behead("left", "actividad") %>%
      select(row, col, data_type, numeric, character, date, año, mes, actividad) 
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(actividad == filtro1) %>%
      filter(!is.na(numeric))      
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    year_init = tabla_selection$año[1]
    
    ## Mes inicial
    mes_init = deteccion_primer_mes(tabla_selection$mes[1])
    
  }else if(nombre_base == "DANE_EMMET_territorial.xlsx"){
    
    # 2.1.2 DANE_EMMET_territorial.xlsx ----  
    
    # Código para las variables de la base "EMMET" (Industria)
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up", "encabezados") %>%
      select(row, col, data_type, numeric, character, date, encabezados) 
    
    # El condicional se hace necesario por el espacio que hay a la hora de buscar "Producción \r\nreal"
    if (filtro1 == "Producción \\r\\nreal"){
      
      # Selección de la columna con la información de interés
      tabla_selection = tabla %>%
        filter(encabezados == "Producción \r\nreal ") %>%
        filter(!is.na(numeric))       
      
    }else{
      
      # Selección de la columna con la información de interés
      tabla_selection = tabla %>%
        filter(encabezados == filtro1) %>%
        filter(!is.na(numeric)) 
      
    }
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    tabla_year_init = tabla %>% filter(encabezados == "Año")
    year_init = tabla_year_init$numeric[1]
    
    ## Mes inicial
    tabla_mes_init = tabla %>% filter(encabezados == "Mes")
    mes_init = tabla_mes_init$numeric[1]
    
  }else if(nombre_base == "DANE_EMC.xlsx"){
    
    # 2.1.3 DANE_EMC.xlsx ----  
    
    # Código para las variables de la base "EMC" (Comercio)
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up", "encabezados") %>%
      select(row, col, data_type, numeric, character, date, encabezados) 
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(encabezados == filtro1) %>%
      filter(!is.na(numeric))
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    tabla_year_init = tabla %>% filter(encabezados == "Año")
    year_init = tabla_year_init$numeric[1]
    
    ## Mes inicial
    tabla_mes_init = tabla %>% filter(encabezados == "Mes")
    mes_init = deteccion_primer_mes(tabla_mes_init$character[1])
    
  }else if(nombre_base == "DANE_Importaciones.xlsx"){
    
    # 2.1.4 DANE_Importaciones.xlsx ----  
    
    # Se filtra la base para que solo se seleccione la celda que tiene la información "Mes (Año-Año)p"
    base_init_year_mes = base %>% 
      filter(str_detect(base$character, regex(".*\\(\\d{4} - \\d{4}\\).*", ignore_case = TRUE)))
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    year_init = str_extract(base_init_year_mes$character, regex("\\d{4}"))
    
    ## Mes inicial
    mes_init = deteccion_primer_mes(str_extract(base_init_year_mes$character, regex("[A-Za-z]+")))
    
    # Código para la base de datos que contiene las variables de "importación"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up-left", "encabezados1") %>%
      behead("up-left", "encabezados2") %>%
      behead("left", "CUODE") %>%
      behead("left", "descripcion_importacion") %>%
      select(row, col, data_type, numeric, character, date, encabezados1, encabezados2, CUODE, descripcion_importacion) 
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(descripcion_importacion == filtro1) %>%
      filter(encabezados1 == paste0(year_init, "p")) %>% 
      filter(!is.na(numeric))    
    
    # Dependiendo de si la base es de Enero u otra mes del año, el archivo Excel cambia
    if (nrow(tabla_selection) == 1){
      
      # Creación del objeto ts 
      ts_obj = ts(tabla_selection[1,]$numeric, start = c(year_init, mes_init), frequency = 12)
      
      # Creación del objeto xts
      xts_obj = as.xts(ts_obj)
      colnames(xts_obj) = c(nombre_variable)
      
      # Retorna el objeto xts
      return(xts_obj)        
      
    }else if (nrow(tabla_selection) == 2){
      
      # Creación del objeto ts 
      ts_obj = ts(tabla_selection[2,]$numeric, start = c(year_init, mes_init), frequency = 12)
      
      # Creación del objeto xts
      xts_obj = as.xts(ts_obj)
      colnames(xts_obj) = c(nombre_variable)
      
      # Retorna el objeto xts
      return(xts_obj)
      
    }
    
  }else if(nombre_base == "DANE_Exportaciones.xlsx"){
    
    # 2.1.5 DANE_Exportaciones.xlsx ----  
    
    # Código para la base de datos que contiene las variables de "exportación"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up-left", "tipo_exportacion") %>%
      behead("up-left", "producto_exportacion") %>%
      behead("up", "metrica_exportacion") %>%
      behead("left", "mes") %>%
      select(row, col, data_type, numeric, character, date, tipo_exportacion, producto_exportacion, metrica_exportacion, mes) 
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    year_init = str_extract(tabla$mes[1], regex("\\d{4}"))
    
    ## Mes inicial
    mes_init = as.numeric(str_extract_all(tabla$mes[1], regex("\\d{2}"))[[1]][3]) # Toca hacer todo esto para lograr extraer el -mes- de la variables "Mes"
    
    # Se filtra la información dependiendo de la variable de exportación de interés
    if (filtro1 == "Exportaciones tradicionales"){
      
      if (filtro2 == "Total Exportaciones Tradicionales"){
        
        # Selección de la columna con la información de interés
        tabla_selection = tabla %>%
          filter(tipo_exportacion == filtro1) %>%
          filter(producto_exportacion == paste0(filtro2, " ")) %>%
          filter(metrica_exportacion == filtro3) %>%
          filter(!str_detect(mes, "Totales")) %>%
          filter(!is.na(numeric))        
        
      }else{
        
        # Selección de la columna con la información de interés
        tabla_selection = tabla %>%
          filter(tipo_exportacion == filtro1) %>%
          filter(producto_exportacion == filtro2) %>%
          filter(metrica_exportacion == filtro3) %>%
          filter(!str_detect(mes, "Totales")) %>%
          filter(!is.na(numeric))        
        
      }
      
    }else{
      
      # Selección de la columna con la información de interés
      tabla_selection = tabla %>%
        filter(tipo_exportacion == filtro1) %>%
        filter(metrica_exportacion == filtro2) %>%
        filter(!str_detect(mes, "Totales")) %>%
        filter(!is.na(numeric)) 
      
    }
    
  }else if(nombre_base == "DANE_ECG.xlsx"){
    
    # 2.1.6 DANE_ECG.xlsx ----  
    
    # Código para la base de datos que contiene a la variable "despachos_cemento"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up-left", "encabezados1") %>%
      behead("up", "encabezados2") %>%
      behead("left-up", "año") %>%
      behead("left", "mes") %>%
      select(row, col, data_type, numeric, character, date, encabezados1, encabezados2, año, mes)
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(encabezados1 == paste0(filtro1, " ")) %>%
      filter(encabezados2 == filtro2) %>%
      filter(!is.na(numeric))
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    year_init = tabla_selection$año[1]
    
    ## Mes inicial
    mes_init = deteccion_primer_mes(tabla_selection$mes[1])
    
  }else if(nombre_base == "DANE_ELIC.xlsx"){
    
    # 2.1.7 DANE_ELIC.xlsx ----  
    
    # Código para la base de datos que contiene a la variable "area_construccion"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up-left", "encabezados1") %>%
      behead("up", "encabezados2") %>%
      behead("left-up", "año") %>%
      behead("left", "mes") %>%
      select(row, col, data_type, numeric, character, date, encabezados1, encabezados2, año, mes)
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(encabezados1 == filtro1) %>%
      filter(encabezados2 == "302 \r\nmunicipios") %>%
      filter(!is.na(numeric)) 
    
    # Promedio area construida año 2015
    promedio_area_construida_2015 = 2616877
    
    # Estandarización de la variable
    tabla_final = tabla_selection %>% 
      mutate(area_construccion =  (numeric * 100) / promedio_area_construida_2015)
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    year_init = tabla_final$año[1]
    
    ## Mes inicial
    mes_init = deteccion_primer_mes(tabla_final$mes[1])
    
    # Creación del objeto ts 
    ts_obj = ts(tabla_final$area_construccion, start = c(year_init, mes_init), frequency = 12)
    
    # Creación del objeto xts
    xts_obj = as.xts(ts_obj)
    colnames(xts_obj) = c(nombre_variable)
    
    # Retorna el objeto xts
    return(xts_obj)  
    
  }else if(nombre_base == "DANE_IPP.xlsx"){
    
    # 2.1.8 DANE_IPP.xlsx ----  
    
    # Código para la base de datos que contiene a la variable "despachos_cemento"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up-left", "encabezado1") %>%
      behead("up", "encabezado2") %>%
      select(row, col, data_type, numeric, character, date, encabezado1, encabezado2) 
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(encabezado1 == filtro1) %>%
      filter(encabezado2 == filtro2) %>%
      filter(!is.na(numeric)) 
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    year_init = na.omit(str_extract(base$character, regex("\\d{4}")))[2]
    
    # Esquina superior izquierda de la tabla
    esquina_sup_izq_tabla2 = dplyr::filter(base, character == year_init)
    
    # Particion de la base que contiene la informacion de la tabla de interés dentro de la hoja de excel
    particion2 = partition(base, esquina_sup_izq_tabla2)
    
    tabla2 = particion2$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("left-up", "año") %>%
      behead("left", "mes") %>%
      select(row, col, data_type, numeric, character, date, año, mes)
    
    ## Mes inicial
    mes_init = deteccion_primer_mes(tabla2$mes[1])
    
  }else if(nombre_base == "DANE_IPC.xlsx"){
    
    # 2.1.9 DANE_IPC.xlsx ----  
    
    # Código para la base de datos que contiene a la variable "despachos_cemento"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up", "año") %>%
      behead("left", "mes") %>%
      select(row, col, data_type, numeric, character, date, año, mes)
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      arrange(año) %>%
      filter(!is.na(numeric)) 
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    year_init = tabla_selection$año[1]
    
    ## Mes inicial
    mes_init = deteccion_primer_mes(tabla_selection$mes[1])
    
  }else if(nombre_base == "DANE_EMA.xlsx"){
    
    # 2.1.10 DANE_EMA.xlsx ----  
    
    # Código para la base de datos que contiene a la variable "despachos_cemento"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up", "encabezados") %>%
      behead("left-up", "año") %>%
      behead("left", "mes") %>%
      select(row, col, data_type, numeric, character, date, encabezados, año, mes)
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(encabezados == filtro1) %>%
      filter(!is.na(numeric)) 
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    year_init = tabla_selection$año[1]
    
    ## Mes inicial
    mes_init = deteccion_primer_mes(tabla_selection$mes[1])
    
  }else if(nombre_base == "DANE_Mercado_laboral.xlsx"){
    
    # 2.1.11 DANE_Mercado_laboral.xlsx ----  
    
    # Código para la base de datos que contiene las variables de "mercado laboral"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up-left", "año") %>%
      behead("up", "mes") %>%
      behead("left", "concepto_mercado_laboral") %>%
      select(row, col, data_type, numeric, character, date, año, mes, concepto_mercado_laboral)
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(concepto_mercado_laboral == filtro1) %>%
      filter(!is.na(numeric)) 
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    year_init = tabla$año[1]
    
    ## Mes inicial
    mes_init = deteccion_primer_mes(tabla$mes[1])
    
  }else if(nombre_base == "DANE_Sacrificio_ganado.xlsx"){
    
    # 2.1.12 DANE_Sacrificio_ganado.xlsx ----  
    
    # Código para la base de datos que contiene las variables de "Sacrificio de ganado"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up-left", "encabezados1") %>%
      behead("up", "encabezados2") %>%
      behead("left", "periodo") %>%
      select(row, col, data_type, numeric, character, date, encabezados1, encabezados2, periodo)
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(encabezados1 == filtro1) %>%
      filter(encabezados2 == filtro2) %>%
      filter(periodo != "Total general") %>%
      filter(!is.na(numeric)) 
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    year_init = na.omit(str_extract(base$character, regex("\\d{4}")))[1]
    
    ## Mes inicial
    mes_init = deteccion_primer_mes(tabla_selection$periodo[1])
    
  }else if(nombre_base == "DANE_IPI.xlsx"){
    
    # 2.1.13 DANE_IPI.xlsx ----  
    
    # Código para la base de datos que contiene a la variable "produccion_carbon_volum"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up", "encabezados") %>%
      behead("left", "dominios") %>%
      behead("left", "año") %>%
      behead("left", "mes") %>%
      behead("left", "clases_industriales") %>%
      select(row, col, data_type, numeric, character, date, encabezados, año, mes, clases_industriales)
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(clases_industriales == filtro1) %>%
      filter(!is.na(numeric)) 
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    year_init = tabla_selection$año[1]
    
    ## Mes inicial
    mes_init = tabla_selection$mes[1]
    
  }else if(nombre_base == "DANE_EC.xlsx"){
    
    # 2.1.14 DANE_EC.xlsx ----  
    
    # Código para la base de datos que contiene las variables de "estadísticas de concreto"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up-left", "encabezados1") %>%
      behead("up", "encabezados2") %>%
      behead("left", "año") %>%
      behead("left", "mes") %>%
      select(row, col, data_type, numeric, character, date, encabezados1, encabezados2, año, mes) 
    
    # Se filtra la información dependiendo de la variable de "estadística de concreto" de interés
    if (filtro1 == "Edificaciones"){
      
      # Selección de la columna con la información de interés
      
      # Selección 1 
      tabla_selection1 = tabla %>%
        filter(encabezados1 == filtro1) %>%
        filter(!is.na(numeric))
      
      # Selección 2 
      tabla_selection2 = tabla %>%
        filter(encabezados1 == filtro2) %>%
        filter(encabezados2 == filtro3) %>%
        filter(!is.na(numeric))
      
      # Vector numérico con la información de interés 
      numeric = tabla_selection1$numeric + tabla_selection2$numeric
      
      # Data frame que contiene el vector numérico de interés 
      tabla_selection = as.data.frame(numeric)
      
      # Data frame que también contiene los años y los meses
      tabla_selection = tabla_selection %>% 
        mutate(año = tabla_selection1$año,
               mes = tabla_selection1$mes)
      
      
    }else if(filtro1 == "Obras Civiles (desagregación CPC versión 2.1)"){
      
      # Selección de la columna con la información de interés
      tabla_selection = tabla %>%
        filter(encabezados1 == filtro1) %>%
        filter(encabezados2 == filtro2) %>%
        filter(!is.na(numeric))
      
    }
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    year_init = tabla_selection$año[1]
    
    ## Mes inicial
    mes_init = deteccion_primer_mes(tabla_selection$mes[1])
    
  }
  
  # ==== Fin: Específico para cada base ====
  
  if (!(nombre_base %in% c("DANE_Importaciones.xlsx", "DANE_ELIC.xlsx"))){
    
    # Creación del objeto ts 
    ts_obj = ts(tabla_selection$numeric, start = c(year_init, mes_init), frequency = 12)
    
    # Creación del objeto xts
    xts_obj = as.xts(ts_obj)
    colnames(xts_obj) = c(nombre_variable)
    
    # Retorna el objeto xts
    return(xts_obj)  
    
  }
  
}

# 2.2 Función para procesar las bases trimestrales del DANE ----

# Función para procesar las bases mensuales del DANE
procesamiento_DANE_trimestral = function(nombre_base, nombre_sheet, palabra_identificacion_tabla, nombre_variable, filtro1){
  
  # Importación de la base de datos mediante la función "xlsx_cells"
  base = tidyxl::xlsx_cells(nombre_base, sheets = nombre_sheet) 
  
  
  # Identificación de la esquina superior izquierda de la tabla
  esquina_sup_izq_tabla = dplyr::filter(base, character == palabra_identificacion_tabla)  
  
  # Particion de la base que contiene la informacion de la tabla de interés dentro de la hoja de excel
  particion = partition(base, esquina_sup_izq_tabla)
  
  # ==== Inicio: Específico para cada base ====
  
  # La selección de la información cambia dependiendo de la base de datos 
  if (nombre_base == "DANE_PIB_demanda.xlsx"){
    
    # 2.2.1 DANE_PIB_demanda.xlsx ----
    
    # Código para la base de datos que contiene las variables del"PIB por demanda"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up-left", "año") %>%
      behead("up", "trimestre") %>%
      behead("left", "actividad") %>%
      select(row, col, data_type, numeric, character, date, año, trimestre, actividad) 
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(actividad == filtro1) %>%
      filter(!is.na(numeric))         
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    year_init = tabla_selection$año[1]
    
    ## Trimestre inicial
    trimestre_init = deteccion_primer_trimestre(tabla_selection$trimestre[1])
    
  }else if(nombre_base == "DANE_PIB_oferta.xlsx"){
    
    # 2.2.2 DANE_PIB_oferta.xlsx ----
    
    # Código para la base de datos que contiene las variables del"PIB por oferta"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up-left", "año") %>%
      behead("up", "trimestre") %>%
      behead("left", "actividad") %>%
      select(row, col, data_type, numeric, character, date, año, trimestre, actividad) 
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(actividad == filtro1) %>%
      filter(!is.na(numeric))         
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    year_init = tabla_selection$año[1]
    
    ## Trimestre inicial
    trimestre_init = deteccion_primer_trimestre(tabla_selection$trimestre[1])
    
  }
  
  # ==== Fin: Específico para cada base ====
  
  # Selección del año y trimestre de inicio 
  
  # Creación del objeto ts 
  ts_obj = ts(tabla_selection$numeric, start = c(year_init, trimestre_init), frequency = 4)
  
  # Creación del objeto xts
  xts_obj = as.xts(ts_obj)
  colnames(xts_obj) = c(nombre_variable)
  
  # Retorna el objeto xts
  return(xts_obj)
  
}

# 3. Función para el procesamiento de las bases descargadas de Camacol ---------------------------------------------------

# Función para procesar las bases de Camacol
procesamiento_Camacol = function(nombre_base, nombre_sheet, palabra_identificacion_tabla, nombre_variable, filtro1, filtro2){
  
  # Importación base de datos
  base = tidyxl::xlsx_cells(nombre_base, sheets = nombre_sheet) %>% 
    select(row, col, data_type, numeric, character, date)
  
  # Esquina superior izquierda de la tabla
  esquina_sup_izq_tabla = dplyr::filter(base, character == palabra_identificacion_tabla)
  
  # Particion de la base que contiene la informacion de la tabla de interés dentro de la hoja de excel
  particion = partition(base, esquina_sup_izq_tabla)
  
  # Tabla de datos con la información de interés
  tabla = particion$cells[[1]] %>%
    behead("NNW", "regiones") %>%
    behead("N", "tipo_de_vivienda")
  
  # Tabla de datos filtrada solo con la variable de interés
  tabla_selection = tabla %>%
    filter(regiones == filtro1) %>%
    filter(tipo_de_vivienda == filtro2) %>%
    filter(!is.na(numeric))
  
  # Para que no me seleccione las últimas 6 filas, que no hacen parte de la tabla
  tabla_selection = head(tabla_selection, nrow(tabla_selection) - 6)
  
  # Selección del año y mes de inicio 
  
  ## Año inicial
  year_init = year(na.omit(tabla$date)[1])
  
  ## Mes inicial
  mes_init = month(na.omit(tabla$date)[1])
  
  # Creación del objeto ts 
  ts_obj = ts(tabla_selection$numeric, start = c(year_init, mes_init), frequency = 12)
  
  # Creación del objeto xts
  xts_obj = as.xts(ts_obj)
  colnames(xts_obj) = c(nombre_variable)
  
  # Retorna el objeto xts
  return(xts_obj)  
  
}

# 4. Función para el procesamiento de las bases descargadas de la Aerocivil ---------------------------------------------------

# Función para procesar las bases de la Aerocivil
procesamiento_Aerocivil = function(nombre_base, nombre_sheet, palabra_identificacion_tabla, nombre_variable, filtro1){
  
  # Importación base de datos
  base = tidyxl::xlsx_cells(nombre_base) 
  
  # Esquina superior izquierda de la tabla
  esquina_sup_izq_tabla = dplyr::filter(base, character == palabra_identificacion_tabla)
  
  # Particion de la base que contiene la informacion de la tabla de interés dentro de la hoja de excel
  particion = partition(base, esquina_sup_izq_tabla)
  
  # Selección de las celdas de Excel que contienen la info de la tabla
  tabla = particion$cells[[1]] %>%
    filter(!is_blank) %>%
    behead("up", "encabezados") %>%
    select(row, col, data_type, numeric, character, date, encabezados) 
  
  # Selección del año y mes de inicio 
  
  ## Año inicial
  year_init =  year(na.omit(tabla$date)[1])
  
  ## Mes inicial
  mes_init = month(na.omit(tabla$date)[1])
  
  # Selección de la columna con la información de interés
  tabla_selection = tabla %>%
    filter(encabezados == filtro1) %>%
    filter(!is.na(numeric)) 
  
  # Suma de los valores de la columna de interés
  tabla_sum = tabla_selection %>% 
    summarize(suma = sum(numeric))
  
  # Creación del objeto ts
  ts_obj = ts(tabla_sum$suma, start = c(year_init, mes_init), frequency = 12)
  
  # Creación del objeto xts
  xts_obj = as.xts(ts_obj)
  colnames(xts_obj) = c(nombre_variable)
  
  # Retorna el objeto xts
  return(xts_obj)  
  
}


# 5. Función para el procesamiento de las bases descargadas de la FNC ---------------------------------------------------

# Función para procesar las bases de la FNC
procesamiento_FNC = function(nombre_base, nombre_sheet, palabra_identificacion_tabla, nombre_variable, filtro1){
  
  # Importación base de datos
  base = tidyxl::xlsx_cells(nombre_base, sheets = nombre_sheet)  
  
  # Esquina superior izquierda de la tabla
  esquina_sup_izq_tabla = dplyr::filter(base, character == palabra_identificacion_tabla)
  
  # Particion de la base que contiene la informacion de la tabla de interés dentro de la hoja de excel
  particion = partition(base, esquina_sup_izq_tabla)
  
  # Selección de las celdas de Excel que contienen la info de la tabla
  tabla = particion$cells[[1]] %>%
    filter(!is_blank) %>%
    behead("up", "encabezados") %>%
    behead("left", "fecha") %>%
    select(row, col, data_type, numeric, character, date, encabezados, fecha)
  
  # Selección de la columna con la información de interés
  tabla_selection = tabla %>%
    filter(encabezados == filtro1) %>%
    filter(!is.na(numeric))
  
  # Selección del año y mes de inicio 
  
  ## Año inicial
  year_init = year(na.omit(tabla_selection$fecha)[1])
  
  ## Mes inicial
  mes_init = month(na.omit(tabla_selection$fecha)[1])
  
  # Creación del objeto ts
  ts_obj = ts(tabla_selection$numeric, start = c(year_init, mes_init), frequency = 12)
  
  # Creación del objeto xts
  xts_obj = as.xts(ts_obj)
  colnames(xts_obj) = c(nombre_variable)
  
  # Retorna el objeto xts
  return(xts_obj)  
  
}

# 6. Función para el procesamiento de las bases descargadas de la DIAN ---------------------------------------------------

# Función para procesar las bases de la DIAN
procesamiento_DIAN = function(nombre_base, nombre_sheet, palabra_identificacion_tabla, nombre_variable, filtro1){
  
  # Importación base de datos
  base = tidyxl::xlsx_cells(nombre_base)  
  
  # Esquina superior izquierda de la tabla
  esquina_sup_izq_tabla = dplyr::filter(base, character == palabra_identificacion_tabla)
  
  # Particion de la base que contiene la informacion de la tabla de interés dentro de la hoja de excel
  particion = partition(base, esquina_sup_izq_tabla)
  
  # Selección de las celdas de Excel que contienen la info de la tabla
  tabla = particion$cells[[1]] %>%
    filter(!is_blank) %>%
    behead("up", "encabezados") %>%
    behead("left", "año") %>%
    behead("left", "mes") %>%
    select(row, col, data_type, numeric, character, date, encabezados, año, mes)
  
  # Selección de la columna con la información de interés
  tabla_selection = tabla %>%
    filter(encabezados == filtro1) %>% 
    filter(!str_detect(año, "TOTAL")) %>%
    filter(!is.na(numeric)) 
  
  # Selección del año y mes de inicio   
  
  ## Año inicial
  year_init = tabla_selection$año[1]
  
  ## Mes inicial
  mes_init = deteccion_primer_mes(tabla_selection$mes[1])
  
  # Creación del objeto ts
  ts_obj = ts(tabla_selection$numeric, start = c(year_init, mes_init), frequency = 12)
  
  # Creación del objeto xts
  xts_obj = as.xts(ts_obj)
  colnames(xts_obj) = c(nombre_variable)
  
  # Retorna el objeto xts
  return(xts_obj)  
  
}

# 7. Función para el procesamiento de las bases descargadas del Banrep ---------------------------------------------------

# Función para procesar las bases del Banrep
procesamiento_Banrep = function(nombre_base, nombre_sheet, palabra_identificacion_tabla, nombre_variable, filtro1, filtro2){
  
  # Variable "flag" que contrala si hay que invertir el orden de un vector o no
  rev_vect = 0 # 0 no hay que revertir, 1 sí hay que revertir 
  
  # Imporatación de la base de datos mediante la función "xlsx_cells"
  base = tidyxl::xlsx_cells(nombre_base) 
  
  # Identificación de la esquina superior izquierda de la tabla
  esquina_sup_izq_tabla = dplyr::filter(base, character == palabra_identificacion_tabla)  
  
  # Particion de la base que contiene la informacion de la tabla de interés dentro de la hoja de excel
  particion = partition(base, esquina_sup_izq_tabla)
  
  # ==== Inicio: Específico para cada base ====
  
  # La selección de la información cambia dependiendo de la base de datos 
  if(nombre_base == "Banrep_Inflacion_basica.xlsx"){
    
    # 7.1 Banrep_Inflacion_basica.xlsx ----  
    
    # Código para la base de datos que contiene las variables de "inflación básica y de alimentos"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[2]] %>%
      filter(!is_blank) %>%
      behead("up-left", "encabezados1") %>%
      behead("up", "encabezados2") %>%
      select(row, col, data_type, numeric, character, date, encabezados1, encabezados2) 
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(encabezados1 == filtro1) %>%
      filter(encabezados2 == "Índice") %>%
      filter(!is.na(numeric))  
    
    # Selección del año y mes de inicio 
    
    # Se filtra la base de datos para que solo seleccione las observaciones que tengan fecha 
    fechas = base %>% 
      filter(!is.na(date))
    
    ## Año inicial
    year_init = str_extract(fechas$date[1], "\\d{4}")
    
    ## Mes inicial
    mes_init = str_extract(fechas$date[1], "(?<=-)\\d{2}")
    
  }else if (nombre_base == "Banrep_Medidas_inflacion.xlsx"){
    
    # 7.2 Banrep_Medidas_inflacion.xlsx ----
    
    # Código para la base de datos que contiene a la variable "ipc_regulados"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[2]] %>%
      filter(!is_blank) %>%
      behead("up-left", "encabezados1") %>%
      behead("up", "encabezados2") %>%
      select(row, col, data_type, numeric, character, date, encabezados1, encabezados2) 
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(encabezados1 == filtro1) %>%
      filter(encabezados2 == "Índice") %>%
      filter(!is.na(numeric))
    
    # Selección del año y mes de inicio 
    
    # Se filtra la base de datos para que solo seleccione las observaciones que tengan fecha 
    fechas = base %>% 
      filter(!is.na(date))
    
    ## Año inicial
    year_init = str_extract(fechas$date[1], "\\d{4}")
    
    ## Mes inicial
    mes_init = str_extract(fechas$date[1], "(?<=-)\\d{2}")
    
  }else if (nombre_base == "Banrep_tasa_cambio_real.xlsx"){
    
    # 7.3 Banrep_tasa_cambio_real.xlsx ----
    
    # Código para la base de datos que contiene a la variable "tasa_cambio_real"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up-left", "encabezados1") %>%
      behead("up", "encabezados2") %>%
      select(row, col, data_type, numeric, character, date, encabezados1, encabezados2) 
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(encabezados1 == filtro1) %>%
      filter(encabezados2 == filtro2) %>%
      filter(!is.na(numeric))
    
    # Selección del año y mes de inicio 
    
    ## Año inicial
    year_init =  str_sub(na.omit(str_extract(base$numeric, "\\b\\d{6}\\b"))[1], 1, 4)
    
    ## Mes inicial
    mes_init = str_sub(na.omit(str_extract(base$numeric, "\\b\\d{6}\\b"))[1], 5, 6)
    
  }else if (nombre_base == "Banrep_tasa_cambio_nominal.xlsx"){
    
    # 7.4 Banrep_tasa_cambio_nominal.xlsx ----
    
    # Hay que revertir la variable 
    rev_vect = 1
    
    # Código para la base de datos que contiene a la variable "tasa_cambio_nominal"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up", "encabezados1") %>%
      select(row, col, data_type, numeric, character, date, encabezados1) 
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(encabezados1 == filtro1) %>%
      filter(!is.na(numeric)) 
    
    # Selección del año y mes de inicio 
    
    # Indica el índice de la última observación del vector de interés
    num_fechas = length(na.omit(tabla$date))
    
    ## Año inicial
    year_init = str_extract(na.omit(tabla$date)[num_fechas], "\\d{4}")
    
    ## Mes inicial
    mes_init = str_extract(na.omit(tabla$date)[num_fechas], "(?<=-)\\d{2}")
    
  }else if(nombre_base == "Banrep_tasa_cero_cupon_pesos.xlsx"){
    
    # 7.5 Banrep_tasa_cero_cupon_pesos.xlsx ----  
    
    # Hay que revertir la variable 
    rev_vect = 1
    
    # Código para la base de datos que contiene las variables de las "tasas cero cupón"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up", "encabezados1") %>%
      select(row, col, data_type, numeric, character, date, encabezados1) 
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(encabezados1 == filtro1) %>%
      filter(!is.na(numeric))       
    
    # Selección del año y mes de inicio 
    
    # Indica el índice de la última observación del vector de interés
    num_fechas = length(na.omit(tabla$date))
    
    ## Año inicial
    year_init = str_extract(na.omit(tabla$date)[num_fechas], "\\d{4}")
    
    ## Mes inicial
    mes_init = str_extract(na.omit(tabla$date)[num_fechas], "(?<=-)\\d{2}")
    
  }else if(nombre_base == "Banrep_Cartera_sistema_financiero.xlsx"){
    
    # 7.6 Banrep_Cartera_sistema_financiero.xlsx ----  
    
    # Hay que revertir la variable 
    rev_vect = 1
    
    # Código para la base de datos que contiene las variables de la "cartera del sistemas financiero"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up-left", "encabezados1") %>%
      behead("up", "encabezados2") %>%
      select(row, col, data_type, numeric, character, date, encabezados1, encabezados2) 
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(encabezados1 == filtro1) %>%
      filter(!is.na(numeric))    
    
    # Selección del año y mes de inicio 
    
    # Se filtra la base de datos para que solo seleccione las observaciones que tengan fecha 
    fechas = base %>% 
      filter(!is.na(date))
    
    # Indica el índice de la última observación del vector de interés
    num_fechas = length(na.omit(fechas$date))
    
    ## Año inicial
    year_init = str_extract(fechas$date[num_fechas], "\\d{4}")
    
    ## Mes inicial
    mes_init = str_extract(fechas$date[num_fechas], "(?<=-)\\d{2}")
    
  }else if (nombre_base == "Banrep_Cartera_bruta_y_neta.xlsx"){
    
    # 7.7 Banrep_Cartera_bruta_y_neta.xlsx ----
    
    # Hay que revertir la variable 
    rev_vect = 1
    
    # Código para la base de datos que contiene a la variable "cartera_hipotecaria"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up-left", "encabezados1") %>%
      behead("up-left", "encabezados2") %>%
      behead("up", "encabezados3") %>%
      select(row, col, data_type, numeric, character, date, encabezados1, encabezados2, encabezados3) 
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(encabezados1 == filtro1) %>%
      filter(encabezados2 == filtro2) %>%
      filter(encabezados3 == "Legal") %>%
      filter(!is.na(numeric)) 
    
    # Selección del año y mes de inicio 
    
    # Se filtra la base de datos para que solo seleccione las observaciones que tengan fecha 
    fechas = base %>% 
      filter(!is.na(date))
    
    # Indica el índice de la última observación del vector de interés
    num_fechas = length(na.omit(fechas$date))
    
    ## Año inicial
    year_init = str_extract(fechas$date[num_fechas], "\\d{4}")
    
    ## Mes inicial
    mes_init = str_extract(fechas$date[num_fechas], "(?<=-)\\d{2}")
    
  }else if (nombre_base == "Banrep_Remesas_historico.xlsx"){
    
    # 7.8 Banrep_Remesas_historico.xlsx ----
    
    # Hay que revertir la variable 
    rev_vect = 1
    
    # Código para la base de datos que contiene a la variable "remesas_usd"
    
    # Selección de las celdas de Excel que contienen la info de la tabla
    tabla = particion$cells[[1]] %>%
      filter(!is_blank) %>%
      behead("up", "encabezados1") %>%
      select(row, col, data_type, numeric, character, date, encabezados1) 
    
    # Selección de la columna con la información de interés
    tabla_selection = tabla %>%
      filter(encabezados1 == filtro1) %>%
      filter(!is.na(numeric)) 
    
    # Selección del año y mes de inicio 
    
    # Indica el índice de la última observación del vector de interés
    num_fechas = length(na.omit(tabla$date))
    
    ## Año inicial
    year_init = str_extract(na.omit(tabla$date)[num_fechas], "\\d{4}")
    
    ## Mes inicial
    mes_init = str_extract(na.omit(tabla$date)[num_fechas], "(?<=-)\\d{2}")
    
  }
  
  # ==== Fin: Específico para cada base ====
  
  # Creación del objeto ts 
  
  if (rev_vect == 0){
    
    # Condición si no hay que invertir el vector
    ts_obj = ts(tabla_selection$numeric, start = c(year_init, mes_init), frequency = 12)
    
  }else if(rev_vect == 1){
    
    # Condición en caso de que haya que invertir el vector
    ts_obj = ts(rev(tabla_selection$numeric), start = c(year_init, mes_init), frequency = 12)
    
  }
  
  # Creación del objeto xts
  xts_obj = as.xts(ts_obj)
  colnames(xts_obj) = c(nombre_variable)
  
  # Retorna el objeto xts
  return(xts_obj)  
  
}



# Ultimo: Función para el procesamiento de todas las bases ----------------

# Ultimo 1: Función auxiliar "tryCatch" ----

# Función que ejecuta "try-catch" para cada variable procesada, dependiende de si el nombre de la hoja Excel en "nombre_sheet" está con un espacio al final o no
## Nota: Note que acá se hace una especie de programación funcional en la medida que dentro de esta función entra como parámetro "funcion_procesamiento_base" que puede ser una función arbitraria
##       de las que fuerón definidas arriba. El elipisis "..." denota un número arbitario de parámetros que pueden entrar dentro de las funciones "funcion_procesamiento_base"
funcion_try_catch = function(funcion_procesamiento_base, nombre_base, nombre_sheet, ...){
  
  # Nota:
  ### Try: Nombre de la "Sheet" de excel no tiene espacio al final del nombre de la hoja de excel
  ### Catch: Nombre de la "Sheet" de excel tiene espacio al final del nombre de la hoja de excel
  
  tryCatch({
    
    # Función que procesa las bases de datos cuándo 
    xts_obj = funcion_procesamiento_base(nombre_base, nombre_sheet, ...)
    
    return(xts_obj)
    
  }, error = function(e) {
    # Código que se ejecuta cuando no se puede desestacionalizar por default
    # En este caso se aplica la opción "outlier = NULL"
    
    nombre_sheet = paste0(nombre_sheet, " ")
    
    # Se emplea la desetacionalización con la opción "outlier = NULL"
    xts_obj = funcion_procesamiento_base(nombre_base, nombre_sheet, ...)
    
    return(xts_obj)
    
  })
}

# Ultimo 2: Función para procesar todas las variables descargadas de un mismo "grupo" de variables ----

# Nota: Revisar si la puedo mejorar usando purrr y programación funcional en R
## La idea es pasar una función como argumento, para simplificar el código 
### E.g. pasar la función "procesamiento_DANE" como argumento, con eso se simplifica más el código

# Nota: La función opera por "grupos" de variables, dependiendo de las variables que se encuentren específicadas en la base de datos "input_procesamiento_bases"

# Función para el procesamiento de todos los datos 
procesamiento_datos_modelos = function(input_procesamiento_bases, year_filter, generar_base, name_excel, dir_salida, path_microsoft_office, path_bases_descargadas, tmp_sleep){
  
  # Vector con el nombre de las variables de "exportaciones" e "importaciones" que deben ser transformadas para tener las mismas unidades que la base del 3PRF
  variables_para_transformar_impo_expo = c("impo_total_usd", 
                                           "impo_consumo", 
                                           "impo_intermedios", 
                                           "impo_bienescapital", 
                                           "expo_total_usd", 
                                           "expo_tradicionales", 
                                           "expo_no_tradicionales", 
                                           "impo_capital_real",
                                           "expom",
                                           "impo_bienes_reales")
  
  # Iteración a traves de la base que contiene la información de las variables que fueron descargadas
  for (i in 1:nrow(input_procesamiento_bases)){
    
    # Verificación de si la base está en formato ".xls" y en caso de estarlo transforma la base a formato ".xlsx"
    nombre_base_verificado = verificar_si_es_xls(nombre_base = input_procesamiento_bases[i,]$nombre_base, 
                                      path_microsoft_office, 
                                      path_bases_descargadas, 
                                      tmp_sleep)
    
    # Condicional para crear los objetos xts por cada base procesada (i.e. cada base que se procesa, genera un objeto xts distinto)
    
    if(input_procesamiento_bases[i,]$Fuente == "DANE"){
      
      # Función para generar objeto xts de las bases del DANE 
      xts_obj = funcion_try_catch(funcion_procesamiento_base = procesamiento_DANE, 
                                  nombre_base = nombre_base_verificado, 
                                  nombre_sheet = input_procesamiento_bases[i,]$nombre_sheet,
                                  palabra_identificacion_tabla = input_procesamiento_bases[i,]$palabra_identificacion_tabla,
                                  nombre_variable = input_procesamiento_bases[i,]$nombre_variable, 
                                  filtro1 = input_procesamiento_bases[i,]$filtro1,
                                  filtro2 = input_procesamiento_bases[i,]$filtro2,
                                  filtro3 = input_procesamiento_bases[i,]$filtro3)
      
      
    }else if(input_procesamiento_bases[i,]$Fuente == "DANE_TRIMESTRAL"){
      
      # Función para generar objeto xts de las bases del DANE 
      xts_obj = funcion_try_catch(funcion_procesamiento_base = procesamiento_DANE_trimestral, 
                                  nombre_base = nombre_base_verificado, 
                                  nombre_sheet = input_procesamiento_bases[i,]$nombre_sheet,
                                  palabra_identificacion_tabla = input_procesamiento_bases[i,]$palabra_identificacion_tabla,
                                  nombre_variable = input_procesamiento_bases[i,]$nombre_variable, 
                                  filtro1 = input_procesamiento_bases[i,]$filtro1)
      
      
    }else if (input_procesamiento_bases[i,]$Fuente == "CAMACOL"){
      
      # Función para generar objeto xts de las bases de Camacol
      xts_obj = funcion_try_catch(funcion_procesamiento_base = procesamiento_Camacol, 
                                  nombre_base = nombre_base_verificado, 
                                  nombre_sheet = input_procesamiento_bases[i,]$nombre_sheet,
                                  palabra_identificacion_tabla = input_procesamiento_bases[i,]$palabra_identificacion_tabla,
                                  nombre_variable = input_procesamiento_bases[i,]$nombre_variable,
                                  filtro1 = input_procesamiento_bases[i,]$filtro1,
                                  filtro2 = input_procesamiento_bases[i,]$filtro2)
      
    }else if(input_procesamiento_bases[i,]$Fuente == "AEROCIVIL"){
      
      # Función para generar objeto xts de las bases de la Aerocivil
      xts_obj = funcion_try_catch(funcion_procesamiento_base = procesamiento_Aerocivil, 
                                  nombre_base = nombre_base_verificado, 
                                  nombre_sheet = input_procesamiento_bases[i,]$nombre_sheet,
                                  palabra_identificacion_tabla = input_procesamiento_bases[i,]$palabra_identificacion_tabla,
                                  nombre_variable = input_procesamiento_bases[i,]$nombre_variable,
                                  filtro1 = input_procesamiento_bases[i,]$filtro1)
      
    }else if(input_procesamiento_bases[i,]$Fuente == "FNC"){
      
      # Función para generar objeto xts de las bases de la FNC      
      xts_obj = funcion_try_catch(funcion_procesamiento_base = procesamiento_FNC, 
                                  nombre_base = nombre_base_verificado, 
                                  nombre_sheet = input_procesamiento_bases[i,]$nombre_sheet,
                                  palabra_identificacion_tabla = input_procesamiento_bases[i,]$palabra_identificacion_tabla,
                                  nombre_variable = input_procesamiento_bases[i,]$nombre_variable,
                                  filtro1 = input_procesamiento_bases[i,]$filtro1)
      
    }else if(input_procesamiento_bases[i,]$Fuente == "DIAN"){
      
      # Lista de archivos en el directorio
      nombres_bases_de_datos_descargadas = list.files()
      
      # Uso de la función "str_detect" del paquete "stringr" para detectar el archivo descargado de la DIAN con la palabra "recaudo-mensual"
      nombre_base_DIAN = nombres_bases_de_datos_descargadas[str_detect(nombres_bases_de_datos_descargadas, "recaudo-mensual")]
      
      # Función para generar objeto xts de las bases de la DIAN
      xts_obj = funcion_try_catch(funcion_procesamiento_base = procesamiento_DIAN,
                                  nombre_base = nombre_base_DIAN,
                                  nombre_sheet = input_procesamiento_bases[i,]$nombre_sheet,
                                  palabra_identificacion_tabla = input_procesamiento_bases[i,]$palabra_identificacion_tabla,
                                  nombre_variable = input_procesamiento_bases[i,]$nombre_variable,
                                  filtro1 = input_procesamiento_bases[i,]$filtro1)
      
    }else if(input_procesamiento_bases[i,]$Fuente == "BANREP"){
      
      # Función para generar objeto xts de las bases de la BANREP      
      xts_obj = funcion_try_catch(funcion_procesamiento_base = procesamiento_Banrep, 
                                  nombre_base = nombre_base_verificado, 
                                  nombre_sheet = input_procesamiento_bases[i,]$nombre_sheet,
                                  palabra_identificacion_tabla = input_procesamiento_bases[i,]$palabra_identificacion_tabla,
                                  nombre_variable = input_procesamiento_bases[i,]$nombre_variable,
                                  filtro1 = input_procesamiento_bases[i,]$filtro1,
                                  filtro2 = input_procesamiento_bases[i,]$filtro2)
      
    }
    
    # Condicional para generar la "matriz" de objetos xts
    
    # Si es la primer vez que se itera se crea el objeto "xts_matrix" que es la matriz que almacena todas las series de tiempo 
    if(i == 1){
      
      # Inicalización del objeto "xts_matrix" en la primera iteración
      xts_matrix = xts_obj
      
    }else{
      
      # En cada iteración se llenar la matriz de objetos xts con un nueva columna ("serie" para cada variable)
      xts_matrix = merge.xts(xts_matrix, xts_obj)
      
    }
    
    # Transformación de las variables para que tengan las mismas unidades que las variables que se encuentran en la base original del 3PRF 
    
    ## Transformación de las variables de importaciones y exportaciones para que tengan las mismas unidades que las variables análogas que se encuentran en la base original del 3PRF
    if(colnames(xts_obj) %in% variables_para_transformar_impo_expo){
      
      # Divide la columna "colnames(xts_obj)" de la matriz xts_matrix por 1000
      xts_matrix[, colnames(xts_obj)] = apply(xts_matrix[, colnames(xts_obj)], 2, function(x) x/1000)
      
    }
    
  }
  
  # Procesamiento luego de generar el objeto "xts_matrix" (i.e. la matriz de objetos xts)
  
  ## Se filtra las series, para que solo contengan información desde "year_filter" en adelante
  xts_filtered = xts_matrix[lubridate::year(index(xts_matrix)) >= year_filter]
  
  ## Se estrae las fechas del objeto "xts_filtered"
  Fecha = index(xts_filtered)
  
  ## Se transforma el objeto "xts_filtered" en una data frame
  todos_df_filter = as.data.frame(xts_filtered)
  
  ## Se transforma los rownames del dataframe en la columna de fechas
  todos_df_filter = rownames_to_column(todos_df_filter, var = "Fecha")
  
  ## Se guarda dicha columna de fechas con los valores que vienen del index de "xts_filtered"
  todos_df_filter = todos_df_filter %>% 
    mutate(Fecha = Fecha)
  
  ## Se específica el directorio de salida donde se almacenará la base de datos final 
  setwd(dir_salida)
 
  ## Condicional para decidir si se guarda o no como archivo excel la base de datos con las variables procesadas pero aún sin empalmarcon las bases originales
  if (generar_base){
    
    ## Se exporta el dataframe "todos_df_filter como un archivo Excel
    write.xlsx(todos_df_filter, name_excel)    
    
  }
  
  ## Se retorna el objeto "xts_filtered" que va a servir como insumo para la función "actualizacion_bases_finales" que actualiza las bases de datos originales
  return(xts_filtered)
  
}

# Ultimo 3: Función para actualizar las bases de datos originales ----

# Función para actualizar las bases de datos originales
actualizacion_bases_finales = function(base_original, base_actualizada_xts, year_filter, periodicidad, generar_base, name_excel, start_fecha, dir_salida){
  
  # Parte del código que prepara las base de datos antes del proceso de actualización de la base de datos original que se quiere actualizar
  
  ## "base_original_xts"
  
  # Fecha de inicio de la base de datos original ("base_original") que se quiere actualizar
  fecha_inicio = ymd(start_fecha)
  
  # Genera la variable que contiente todas las fechas de la base de datos original ("base_original") que se quiere actualizar
  fechas = as.yearmon(seq(fecha_inicio, by = periodicidad, length.out = nrow(base_original)))
  
  # Modifica "base_original" para que incluya las fechas de la base de datos 
  base_original = base_original %>% 
    mutate(Fecha = fechas)
  
  # Transforma "base_original" (base de datos que contiene las series originales de le base de datos original antes de ser actualizadas) en un objeto xts ("base_original_xts")
  base_original_xts = xts(base_original[, -1], order.by = base_original$Fecha)
  
  # Vector con los nombres de las variables que se encuentran en la base de datos con las series originales ("base_original_xts")
  names_base_original = names(base_original_xts)
  
  ## "base_original_xts"
  
  # Vector con los nombres de las variables que se encuentran en la base de datos con las series actualizadas ("base_actualizada_xts")
  names_base_actualizada = names(base_actualizada_xts)
  
  
  # Parte del código de la función que actualiza las bases de datos 
  
  # Loop1: Iteración a través de las variables de "base_original_xts" 
  for(i_orig in 1:length(names_base_original)){
    
    # Vector lógico que permite detectar en que parte de la "base_actualizada_xts" se encuentra la variable de la "base_original_xts" 
    # Lo que se está haciendo es una comparación de nombres de las dos bases ("base_actualizada_xts" y "base_original_xts") y ver en que momento dan exactamente igual (mismo nombre de la variable)
    logical_vector = names_base_original[i_orig] == names_base_actualizada
    
    # Condición para deterctar si es necesario actualizar los datos de la variable o no. 
    ## sum(logical_vector) == 1: Indica que sí, dado que se descargarón datos nuevos
    ## sum(logical_vector) == 0: Indica que no, dado que no se descargarón datos nuevos
    if (sum(logical_vector) == 1){
      
      # Vector que va almacenar los datos de la variable. Si no se han actualiado deja los de la variable de la base original, pero si hay actualizaciones coloca los de la base actualizada 
      new_vect = c()
      
      # Índice que indica en que posición de la "base_actualizada_xts" se encuentra la variable de la "base_original_xts"
      i_actual = which(logical_vector)
      
      # Genero el objeto xts que incluye las dos series de tiempo de la variable de interés, i.e., la anterior ("base_original_xts") y la actualizada ("base_actualizada_xts")
      xts_merge = merge.xts(base_original_xts[, i_orig], base_actualizada_xts[, i_actual])
      
      # Extraigo el ínidice temporal del objeto "xts_merge" que contiene las dos series de tiempo de la variable de ineterés
      xts_merge_index = index(xts_merge)
      
      # Extaigo el número de observacione que se encuentran en el objeto "xts_merge"
      xts_merge_nrow = dim(xts_merge)[1]
      
      # Lleno el nuevo vector que va a contener la información de la variable de interés en la base actualizada
      for (i_merge in 1:xts_merge_nrow){
        
        # Si la serie actualizada ("base_actualizada_xts") de la variable tiene NA, entonces se dejan los valores de la serie original ("base_original_xts") de la variable 
        if (is.na(xts_merge[, 2][i_merge])){
          
          # Se llena con los valores de la serie original ("base_original_xts") de la variable 
          new_vect[i_merge] = xts_merge[, 1][i_merge]
          
        }else{
          
          # De lo contrario, si la serie actualizada no tiene NA, entonces se llena con los valores de la serie actualizada ("base_actualizada_xts")
          new_vect[i_merge] = xts_merge[, 2][i_merge]
        }
        
      }
      
      # Se transforma el vector que se acaba de llenar en un objeto xts
      new_xts = xts(new_vect, order.by = xts_merge_index)
      
    }else{
      
      # En caso de que no haya un versión actualizada de la variable (i.e. la varible no se encuentre en "base_actualizada_xts"), entonces se deja la serie original de la variable (la que se encuentra en "base_original_xts")
      new_xts = base_original_xts[, i_orig]
      
    }
    
    # Condicional para generar la "matriz" de objetos xts
    
    # Si es la primer vez que se itera se crea el objeto "xts_matrix" que es la matriz que almacena todas las series de tiempo 
    if(i_orig == 1){
      
      # Inicalización del objeto "xts_matrix" en la primera iteración
      xts_matrix = new_xts
      
    }else{
      
      # En cada iteración se llenar la matriz de objetos xts con un nueva columna ("serie" para cada variable)
      xts_matrix = merge.xts(xts_matrix, new_xts)
      
    }
    
  }
  
  # Se renombran las variables de "xts_matrix" para que los nombres de las series correspondan a los mismos nombre de las variables que aparecen en "base_original_xts" 
  names(xts_matrix) = names_base_original
  
  # Se filtra las series, para que solo contengan información desde "year_filter" en adelante
  xts_filtered = xts_matrix[lubridate::year(index(xts_matrix)) >= year_filter]
  
  # Se estrae las fechas del objeto "xts_filtered"
  Fecha = index(xts_filtered)
  
  # Se transforma el objeto "xts_filtered" en una data frame
  todos_df_filter = as.data.frame(xts_filtered)
  
  # Se transforma los rownames del dataframe en la columna de fechas
  todos_df_filter = rownames_to_column(todos_df_filter, var = "Fecha")
  
  # Se guarda dicha columna de fechas con los valores que vienen del index de "xts_filtered"
  todos_df_filter = todos_df_filter %>% 
    mutate(Fecha = my(Fecha))
  
  # Se específica el directorio de salida donde se almacenará la base de datos final 
  setwd(dir_salida)
  
  if (generar_base){
    
    # Se exporta el dataframe "todos_df_filter como un archivo Excel
    write.xlsx(todos_df_filter, name_excel)
    
  }
  
  # Se retorna el data frame "todos_df_filter"
  return(todos_df_filter)
  
}

# Ultimo 4: Función para combinar múltiples bases en un solo Excel ----
combinar_bases_en_un_solo_excel = function(name_excel, dir_salida, ...){
  
  ## Se específica el directorio de salida donde se almacenará la base de datos final 
  setwd(dir_salida)
  
  ## 
  lista_bases = list(...)
  
  ## 
  write.xlsx(lista_bases, name_excel)  
  
} 