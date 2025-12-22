# Archivo para la carga de los datos de forma automática

#!/bin/bash

# Variables iniciales

DB_NAME="erp_db"
DB_USER="admin"
DB_HOST="localhost"
DB_PORT="5432"
DATA_PATH="~/bbdd_config/data"


echo "Cargando datos en tablas staging"

# Función

cargar_csv() {
    local tabla=$1 #Primer argumento de la función
    local archivo=$2 # Segundo argumento de la función
    echo "Cargando $tabla..."
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME \
    -c "\copy $tabla FROM '$DATA_PATH/$archivo' WITH (FORMAT CSV, HEADER, DELIMITER ','); "


}

# Llamadas a la función
cargar_csv "stg_sellers" "SELLERS.csv"
cargar_csv "stg_products" "PRODUCTS.csv"
cargar_csv "stg_geo_location" "GEO_LOCATION.csv"
cargar_csv "stg_customers" "CUSTOMERS.csv"
cargar_csv "stg_orders" "ORDERS.csv"
cargar_csv "stg_order_items" "ORDER_ITEMS.csv"
cargar_csv "stg_order_payments" "ORDER_PAYMENTS.csv"
cargar_csv "stg_order_review_ratings" "ORDER_REVIEW_RATINGS.csv"

echo "✅ Proceso de carga finalizado."
