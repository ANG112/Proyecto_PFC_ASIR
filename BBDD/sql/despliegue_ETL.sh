-- ARchivo de ejecución de proceso ETL

-- Creando tablas staging
echo "Paso 1/4: Creando tablas staging.."
psql -h localhost -U admin -d erp_db -f 01_tablas_stg.sql

-- Creando tablas definitivas
echo " Paso 2/4: Creando tablas definitivas.."
psql -h localhost -U admin -d erp_db -f 02_tablas_definitivas.sql

-- Cargando los datos desde los archivos .csv
echo "Paso 3:4 Cargando datos desde los archivos .csv ... "
./03_carga_datos.sh

-- Ejecutando porceso ETL
echo "Paso 4/4: Ejecutando ETL..."
psql -h localhost -U admin -d erp_db -f 04_proceso_ETL.sql

-- Fin
echo "Fin del proceso ETL"


