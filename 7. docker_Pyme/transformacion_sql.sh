#!/bin/bash

# 1. Variables de configuración
# Asegúrate de que el nombre del contenedor coincide con 'docker ps'
CONTAINER_NAME="erp_db"
DB_USER="postgres"
DB_NAME="erp_dw"

echo "=========================================================="
echo "  INICIANDO TRANSFORMACIÓN: CAPA RAW -> DATA WAREHOUSE    "
echo "=========================================================="

# 2. Ejecutar DIMENSIONES
# Es vital que se ejecuten primero porque los HECHOS dependen de sus IDs
echo -e "\n[1/2] Procesando DIMENSIONES..."
for f in ./sql_transform/dimensions/*.sql; do
    echo "  -> Aplicando: $(basename $f)"
    docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME < "$f"
done

# 3. Ejecutar HECHOS
echo -e "\n[2/2] Procesando TABLAS DE HECHOS..."
for f in ./sql_transform/facts/*.sql; do
    echo "  -> Aplicando: $(basename $f)"
    docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME < "$f"
done

echo -e "\n=========================================================="
echo "      TRANSFORMACIÓN COMPLETADA CON ÉXITO                "
echo "=========================================================="
