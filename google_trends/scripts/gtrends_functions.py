# Descripcion del script: Contiene la funcion en "pytrends" que me permite descargar las palabras de Google Trends

# Librerias de trabajo 
import time 
import os   # Funcionalidades que permiten trabajar con el sistema operativo directamente 
import pandas as pd  # Liberaria pandas para trabajar con "dataframes" en python
from pytrends.request import TrendReq 
import urllib3

# Funcion disenada para descargar palabras de Google Trends 
def busqueda_google_trends(input_file, output_file, sector_name, group_size, words_before_stop = 3, slp_time_words = 10, slp_time_groups = 30): 
    '''

    Parameters
    ----------
    df_input: pandas dataframe 
        Base de datos de entrada, que contiene todas las palabras que van a ser buscadas por google trends 

    slp_time: int 
        Tiempo de espera, entre cada grupo de 5 palabras. Se usa para evitar problemas de "RateLimit" con google trends 

    Returns 
    -------
    None: La función no retorna nada 

    '''
    # Se importan la bases de datos con las palabras de busqueda de google trends en un dataframe
    palabras_input_df = pd.read_excel(input_file, header=0, sheet_name = sector_name)    

    # Nombre del sector al que se le van a descargar las palabras de Google Trends 
    print(f"\n\nSector: {sector_name}\n\n")
    
    # 
    pytrends = TrendReq(tz=360, timeout=(10,25))

    # Base de datos que almacenara las variables recuperadas de google trends 
    gtrends_df = pd.DataFrame()

    # Contador que permitira saber en que palabra especi�fica de la lista de palabras de google trends se encuentra el ciclo
    cont_group = 0
    
    # Contador que permitira saber en que palabra especi�fica de la lista de palabras de google trends se encuentra el ciclo
    cont_word = 0

    # Ciclo que permite descargar/recuperar informacion de "google trends" palabra por palabra 
    for index, row in palabras_input_df.iterrows():   

        # 1. Condicionales para el "manejo del tiempo" de la función        

        # Los dos condicionales me garantizan que se suspenda adecuadamente el programa para que se pueda efecuar la descarga de palabras 
        # Esto se hace para evitar problemas de RateLimit

        ## Condición de pausa de tiempo cada vez que se encuentre un "group_size" de palabras
        if (cont_group == group_size):
            
            # Suspendo cada vez "group_size" de palabras
            print("\nNext set of words. Sleeping %d segs\n" %slp_time_groups)
            time.sleep(slp_time_groups)            
            
            # Actualizo el contador de palabras 
            cont_word = 0
            
            # Actualizo el contador de grupos
            cont_group = 0
            
        ## Condición de pausa de tiempo cada vez que descargue "words_before_stop" palabras
        if cont_word == words_before_stop: 
            
            # Suspendo cada "group_size" de palabras
            print("Sleeping %d segs" %slp_time_words)
            time.sleep(slp_time_words) 
            
            # Actualizo el contador de palabras 
            cont_word = 0             

        # 2. Proceso de Web Scraping de PyTrends

        ## Específica que palabra se está buscando en cada iteracion 
        print(f"Buscando: {row['palabra']}")
        
        #  
        t = "all"
        pytrends.build_payload([row["palabra"]], cat=0, timeframe=t, geo=row["origen"])
        
        # 
        data = pd.DataFrame(pytrends.interest_over_time())
        data.drop("isPartial", axis=1, inplace=True)
        gtrends_df = pd.merge(gtrends_df, data, how='outer', left_index=True, right_index=True)
        
        # La base de datos se almacena o guarda en el archivo "GTrends.csv" en la carpeta 
        gtrends_df.to_csv(output_file) # Creo que se puede mejorar esta parte, porque reescribe el archivo cada vez que genera una nueva palabra

        # 3. Actualización de los contadores 

        ## Se actualiza el contador "cont_group" después de cada busqueda de google trends
        cont_word  += 1
        
        ## Se actualiza el contador "cont_group" después de cada busqueda de google trends
        cont_group  += 1
        






    

