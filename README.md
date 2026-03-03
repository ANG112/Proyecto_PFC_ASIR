# Proyecto_PFC_ASIR
Proyecto de fin de grado ASIR

Se encuentran 8 carpetas:
-	La tres primeras, de la 1 a la 3, están relacionadas con los pasos iniciales para entender y preparar los datos para cargar en el ERP.
  - Carpeta 1: Los datos en formato .csv sobre los que se ha trabajado
  - Carpeta 2: el EDA básico realizado así como conclusiones
  - Carpeta 3:
      - Esquema general del proyecto a nivel de infraestructura
      -  Modelo de E-R de los datos de la carpeta 1 tras el EDA
      -  Modelo Lógico- relacional de los datos de la carpeta 1 tras el EDA
      -  Diseño del datawarehose a implementar en el postgres de la Pyme.
      
- La carpeta 4 y 5 contiene
  - Carpeta 4: el código de ejecución del ETL de carga inicial de datos en el postgres del ERP simulado incluyendo la limpieza y transformación de los datos (nivel bronce -> nivel plata) 
  - Carpeta 5: la configuración de la API en Python.
    
-	La carpeta 6 contiene capturas de wireshark para comprobar el cifrado de los datos así como capturas de los logs durante el proceso de ELT lanzado desde la Pyme. Una imagen son los logs del ERP y la otra los logs de la Pyme.
  
-	La carpeta 7 y 8, se corresponde con la Pyme:
  - Carpeta 7: Configuración completa del Docker usado para levantar toda la infraestructura de la Pyme.
  - Carpeta 8: archivo de ejecución de la transformación de los datos para crear el datawarehose en el postgres de la Pyme.

