# Codigo con las funciones para el proceso de Descarga de datos vía Web Scraping en R

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

# Funciones para el proceso de Descarga

# 1. Función para descarga de datos DANE ---------------------------------------------------

# Función para hacer web scraping en el DANE
descarga_DANE = function(global_url, enlace_variable, tag_selector_descarga, tipo_selector, nombre_base){
  
  # Archivo HTML de la página web importada a R
  html = read_html(enlace_variable)  
  
  # La selección del tag cambia dependiente de si se uso el "xpath" o el "CSS selector" del tag para identificarlo dentro del archivo HTML
  if(tipo_selector == "xpath"){
    
    # URL del archivo Excel para descargar 
    excel_url = html %>% 
      html_elements(xpath = tag_selector_descarga) %>% 
      html_attr("href")      
    
  }else if(tipo_selector == "css_selector"){
    
    # URL del archivo Excel para descargar 
    excel_url = html %>% 
      html_elements(tag_selector_descarga) %>% 
      html_attr("href")
  }
  
  # Descarga del archivo
  download.file(paste0(global_url, excel_url), destfile = nombre_base, mode = "wb")  
}

# 2. Función para descarga de datos camacol ---------------------------------------------------

# Función para hacer web scraping en Camacol
descarga_Camacol = function(global_url, enlace_variable, tag_selector_descarga, tipo_selector, nombre_base){

  # Archivo HTML de la página web importada a R
  html = read_html(enlace_variable)  
  
  # La selección del tag cambia dependiente de si se uso el "xpath" o el "CSS selector" del tag para identificarlo dentro del archivo HTML
  if(tipo_selector == "xpath"){
    
    # URL del archivo Excel para descargar 
    excel_url = html %>% 
      html_elements(xpath = tag_selector_descarga) %>% 
      html_attr("href")      
    
  }else if(tipo_selector == "css_selector"){
    
    # URL del archivo Excel para descargar 
    excel_url = html %>% 
      html_elements(tag_selector_descarga) %>% 
      html_attr("href")
  }

  # Descargar del archivo 
  download.file(paste0(global_url, excel_url), destfile = nombre_base, mode = "wb")
  
}

# 3. Función para descarga de datos aerocivil ---------------------------------------------------

# Función para hacer web scraping en la Aerocivil
descarga_Aerocivil = function(enlace_variable, tag_selector_descarga, tipo_selector, nombre_base){
  
  # Archivo HTML de la página web importada a R
  html = read_html(enlace_variable)
  
  # La selección del tag cambia dependiente de si se uso el "xpath" o el "CSS selector" del tag para identificarlo dentro del archivo HTML
  if(tipo_selector == "xpath"){
    
    # URL del archivo para descargar 
    excel_url = html %>% 
      html_elements(xpath = tag_selector_descarga) %>% 
      html_elements("li:first-child") %>% 
      html_elements("div:first-child") %>% 
      html_elements(xpath = "./a[1]") %>% 
      html_attr("href")    
    
  }
  
  # Para que no tenga problemas con la base de datos
  encoded_url <- URLencode(excel_url)  
  
  # Descargar del archivo 
  download.file(encoded_url, destfile = nombre_base, mode = "wb")
  
}

# 4. Función para descarga de datos Federación Nacional de Cafeteros ---------------------------------------------------

# Función para hacer web scraping en la Federación Nacionl de Cafeteros
descarga_FNC = function(enlace_variable, tag_selector_descarga, tipo_selector, nombre_base){
  
  # Archivo HTML de la página web importada a R
  html = read_html(enlace_variable)  
  
  # La selección del tag cambia dependiente de si se uso el "xpath" o el "CSS selector" del tag para identificarlo dentro del archivo HTML
  if(tipo_selector == "xpath"){
    
    # URL del archivo Excel para descargar 
    excel_url = html %>% 
      html_elements(xpath = tag_selector_descarga) %>% 
      html_attr("href")      
    
  }else if(tipo_selector == "css_selector"){
    
    # URL del archivo Excel para descargar 
    excel_url = html %>% 
      html_elements(tag_selector_descarga) %>% 
      html_attr("href")
  }
  
  
  # Descarga del archivo
  download.file(excel_url, destfile = nombre_base, mode = "wb")  
}

# 5. Función para descarga de datos en la DIAN ---------------------------------------------------

# Función para hacer web scraping en la DIAN
descarga_DIAN = function(global_url, enlace_variable, tag_selector_descarga, tipo_selector, nombre_base){
  
  # Archivo HTML de la página web importada a R
  html = read_html(enlace_variable)  

  # La selección del tag cambia dependiente de si se uso el "xpath" o el "CSS selector" del tag para identificarlo dentro del archivo HTML
  if(tipo_selector == "xpath"){
    
    # URL del archivo Excel para descargar 
    excel_url = html %>% 
      html_elements(xpath = tag_selector_descarga) %>% 
      html_attr("href")      
    
  }else if(tipo_selector == "css_selector"){
    
    # URL del archivo Excel para descargar 
    excel_url = html %>% 
      html_elements(tag_selector_descarga) %>% 
      html_attr("href")
  }
  
  # Creción del archivo temporal para almacenar el archivo .zip
  temp <- tempfile()
  
  # Descarga del archivo ".zip"
  download.file(paste0(global_url, excel_url), temp, mode = "wb")
  
  # Descompresión del archivo ".zip". Se obtiene el archivo ".xlsx"
  unzip(zipfile = temp, exdir = "./")

  # Borra el archivo temporal del sistema
  unlink(temp)
}


# Ultimo: Función para la descarga de todas las bases --------

# Función para descargar todas las bases necesarias para correr el modelo 
descarga_automatica_bases = function(input_descarga, tmp_sleep, tmp_falla){
  
  # Función auxiliar descarga: Indica que función se debe utilizar para hacer la descarga, dependiendo de la fuente de la base de datos
  funcion_auxiliar_descarga = function(input_descarga, i){
    
    if(input_descarga[i,]$Fuente == "DANE"){
      
      # Función para descargar bases del DANE 
      descarga_DANE(global_url = input_descarga[i,]$global_url, 
                    enlace_variable = input_descarga[i,]$enlace_variable, 
                    tag_selector_descarga = input_descarga[i,]$tag_selector_descarga, 
                    tipo_selector = input_descarga[i,]$tipo_selector, 
                    nombre_base = input_descarga[i,]$nombre_base_descarga)
      
      # Se pausa el programa "tmp_sleep" segudnos para que no haya problemas en la descarga de los archivos
      Sys.sleep(tmp_sleep)
      
    }else if (input_descarga[i,]$Fuente == "CAMACOL"){
      
      # Función para descargar bases de Camacol
      descarga_Camacol(global_url = input_descarga[i,]$global_url, 
                       enlace_variable = input_descarga[i,]$enlace_variable, 
                       tag_selector_descarga = input_descarga[i,]$tag_selector_descarga, 
                       tipo_selector = input_descarga[i,]$tipo_selector,
                       nombre_base = input_descarga[i,]$nombre_base_descarga)  
      
      # Se pausa el programa "tmp_sleep" segudnos para que no haya problemas en la descarga de los archivos
      Sys.sleep(tmp_sleep)
      
    }else if(input_descarga[i,]$Fuente == "AEROCIVIL"){
      
      # Función para descargar bases Aerocivil
      descarga_Aerocivil(enlace_variable = input_descarga[i,]$enlace_variable, 
                         tag_selector_descarga = input_descarga[i,]$tag_selector_descarga, 
                         tipo_selector = input_descarga[i,]$tipo_selector,
                         nombre_base = input_descarga[i,]$nombre_base_descarga)
      
      # Se pausa el programa "tmp_sleep" segudnos para que no haya problemas en la descarga de los archivos
      Sys.sleep(tmp_sleep)
      
    }else if(input_descarga[i,]$Fuente == "FNC"){
      
      # Función para descargar bases FNC
      descarga_FNC(enlace_variable = input_descarga[i,]$enlace_variable, 
                   tag_selector_descarga = input_descarga[i,]$tag_selector_descarga, 
                   tipo_selector = input_descarga[i,]$tipo_selector,
                   nombre_base = input_descarga[i,]$nombre_base_descarga)
      
      # Se pausa el programa "tmp_sleep" segudnos para que no haya problemas en la descarga de los archivos
      Sys.sleep(tmp_sleep)
      
    }else if(input_descarga[i,]$Fuente == "DIAN"){
      
      # Función para descargar bases DIAN
      descarga_DIAN(global_url = input_descarga[i,]$global_url, 
                    enlace_variable = input_descarga[i,]$enlace_variable, 
                    tag_selector_descarga = input_descarga[i,]$tag_selector_descarga, 
                    tipo_selector = input_descarga[i,]$tipo_selector,
                    nombre_base = input_descarga[i,]$nombre_base_descarga)
      
      # Se pausa el programa "tmp_sleep" segudnos para que no haya problemas en la descarga de los archivos
      Sys.sleep(tmp_sleep)
      
    }    
    
  }
  
  # Loop que itera a través de la base de datos "input_descarga", y permite descargar las bases de datos una por una vía "web scraping"
  for (i in 1:nrow(input_descarga)){
    
    # El TryCatch: Permite que si alguna base en específico tuvo problemas a la hora de hacer la descarga, el programa pause "tmp_falla" y reintete hacer la descarga de la base de datos que tuvo problemas
    ## Nota: Una de las ventajas del "TryCatch" es que si hay una base de datos que tuvo un problema en la descarga, el programa no se quieba si no vuelve a intentar hacer la descarga, y pasa a la siguiente 
    ##       base de datos, sin que el programa detenga su ejecución por el error encontrado. 
    tryCatch({
      # 1. Try: Intenta descargar la base de datos
      
      # Se ejecuta la función auxiliar "funcion_auxiliar_descarga" que permite descargar las bases de datos
      funcion_auxiliar_descarga(input_descarga, i)
      
    }, error = function(e) {
      # 2. Catch: En caso de que haya algún problema en la descarga, se pausa el programa "tmp_falla" segundos y luego se reintenta realizar la descarga de nuevo 
      
      # Mensaje que indica que hubo un error en la descarga de la base "input_descarga[i,]$nombre_base_descarga"
      print(paste0("Error en la descarga de la base ", 
                   input_descarga[i,]$nombre_base_descarga, 
                   ". Reintentando realizar la Descarga. Se pausará el programa ", 
                   tmp_falla, 
                   " segundos y luego del tiempo de espera se reiniciará la descarga."))
      
      # Tiempo que se suspende el programa, antes de reintentar de nuevo la descarga 
      Sys.sleep(tmp_falla)
      
      # Se vuelve a intentar la ejecución de la función auxiliar "funcion_auxiliar_descarga" que permite descargar la base de datos
      funcion_auxiliar_descarga(input_descarga, i)
      
    })
    
  }
  
}
