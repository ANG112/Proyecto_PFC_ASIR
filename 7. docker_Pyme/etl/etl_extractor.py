import os
import json  # Necesario para serializar a JSONB

import requests
import urllib3
from sqlalchemy import create_engine, text

# --- 0. AJUSTES SSL (LABORATORIO) ---
# Evita warnings feos cuando usamos verify=False con certificados autofirmados
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# --- 1. CONFIGURACIÓN ---
# URL base del ERP (configurable por entorno)
# Recomendado en tu caso:
#   ERP_BASE_URL=https://windows-gateway:8443
BASE_URL = os.getenv("ERP_BASE_URL", "http://windows-gateway:8088").rstrip("/")

# Verificación TLS:
# - En laboratorio con certificado self-signed: ERP_TLS_VERIFY=false
# - En producción con CA válida: ERP_TLS_VERIFY=true
TLS_VERIFY = os.getenv("ERP_TLS_VERIFY", "false").strip().lower() in ("1", "true", "yes", "y")

PAGE_SIZE = 500  # Tamaño del lote de paginación

ENDPOINT_MAP = {
    "customers": "dim_clientes_raw",
    "sellers": "dim_vendedores_raw",
    "geolocation": "dim_geografia_raw",
    "products": "dim_productos_raw",
    "order-items": "tbl_desglose_pedido_raw",
    "orders": "tbl_logistica_raw",
    "reviews": "tbl_resenas_raw",
    "payments": "tbl_pagos_raw",
}

# Conexión a la DB (servicio 'db' en docker-compose)
DB_USER = os.getenv("POSTGRES_USER", "postgres")
DB_PASS = os.getenv("POSTGRES_PASSWORD", "postgres")
DB_HOST = "db"
DB_PORT = os.getenv("POSTGRES_PORT", "5432")
DB_NAME = os.getenv("POSTGRES_DB", "erp_dw")

DB_URL = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"


# --- 2. FUNCIÓN DE EXTRACCIÓN Y CARGA ---
def run_etl():
    """Ejecuta el proceso de Extracción (E) y Carga (L) para todos los endpoints."""
    print("=" * 50)
    print("       INICIANDO PROCESO ETL (E -> L)          ")
    print("=" * 50)
    print(f"ERP_BASE_URL: {BASE_URL}")
    print(f"ERP_TLS_VERIFY: {TLS_VERIFY}")
    print("-" * 50)

    # Comprobación rápida: si vas por HTTPS y estás verificando, con self-signed fallará
    if BASE_URL.lower().startswith("https://") and TLS_VERIFY:
        print("AVISO: Estás usando HTTPS con verificación activada (ERP_TLS_VERIFY=true).")
        print("      Si el certificado es self-signed, las peticiones fallarán.")
        print("      Para laboratorio: exporta ERP_TLS_VERIFY=false")
        print("-" * 50)

    try:
        engine = create_engine(DB_URL)
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        print(f"Conexión exitosa a la DB: {DB_HOST}")
    except Exception as e:
        print(f"Error al conectar a la DB: {e}")
        return

    for endpoint, table_name in ENDPOINT_MAP.items():
        print(f"\n--- Procesando {endpoint} ---")
        offset = 0
        total_records = 0

        # 1) Crear tabla raw (si no existe) - limpiamos antes de cargar
        with engine.connect() as conn:
            conn.execute(text(f"DROP TABLE IF EXISTS {table_name}"))
            conn.execute(text(f"CREATE TABLE IF NOT EXISTS {table_name} (data JSONB)"))
            conn.commit()

        # 2) Extracción y carga paginada
        while True:
            route_url = f"{BASE_URL}/{endpoint}/"
            query_params = {"limit": PAGE_SIZE, "offset": offset}

            print(f"-> Iniciando extracción de: {route_url} con offset {offset}")

            try:
                response = requests.get(
                    route_url,
                    params=query_params,
                    timeout=30,
                    verify=TLS_VERIFY,  # false en lab (self-signed), true en prod
                )
                response.raise_for_status()
                records = response.json()
            except requests.exceptions.RequestException as e:
                print(f"Error en la petición API: {e}")
                break
            except Exception as e:
                print(f"Error al parsear JSON o desconocido: {e}")
                break

            if not records:
                break

            inserts = [{"data": json.dumps(record)} for record in records]

            with engine.connect() as conn:
                insert_statement = text(f"INSERT INTO {table_name} (data) VALUES (:data)")
                conn.execute(insert_statement, inserts)
                conn.commit()

            total_records += len(records)
            print(
                f"   [Carga] Lote con offset {offset}: {len(records)} registros cargados. Total: {total_records}"
            )

            offset += PAGE_SIZE

            if len(records) < PAGE_SIZE:
                break

    print("\nPROCESO ETL FINALIZADO.")


if __name__ == "__main__":
    run_etl()
