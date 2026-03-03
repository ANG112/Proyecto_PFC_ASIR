# ARchivo de ejecución de proceso ETL

#  Creando tablas staging
echo ""
echo "Paso 1/5: Creando tablas staging.."
echo ""
psql -h localhost -U admin -d erp_db -f 01_tablas_stg.sql

#  Creando tablas definitivas
echo ""
echo " Paso 2/5: Creando tablas definitivas.."
echo ""
psql -h localhost -U admin -d erp_db -f 02_tablas_definitivas.sql

#  Cargando los datos desde los archivos .csv
echo ""
echo "Paso 3/5: Cargando datos desde los archivos .csv ... "
echo ""
./03_carga_datos.sh

#  Ejecutando porceso ETL
echo ""
echo "Paso 4/5: Ejecutando ETL..."
echo ""
psql -h localhost -U admin -d erp_db -f 04_proceso_ETL.sql

# Informe final a modo auditoria
echo ""
echo "Paso 5/5: Generando informe de auditoría..."
echo ""
psql -h localhost -U admin -d erp_db -f 05_auditoria.sql

# Fin
echo ""
echo "Fin del proceso ETL"


