# main.py
from fastapi import FastAPI
# Importa todos los routers que has creado en la carpeta 'routers'
from routers import (
    orders, 
    order_items, 
    products, 
    customers, 
    sellers, 
    payments, 
    reviews, 
    geolocation
)

# Inicializa la aplicación FastAPI
app = FastAPI(title="ERP API")

# Incluye todos los routers para añadir los endpoints (rutas) a la aplicación
app.include_router(orders.router) 
app.include_router(order_items.router) 
app.include_router(products.router)
app.include_router(customers.router)
app.include_router(sellers.router)
app.include_router(payments.router)
app.include_router(reviews.router)
app.include_router(geolocation.router)

# Endpoint raíz para verificación (Health Check)
@app.get("/")
def read_root():
    return {"mensaje": "API funcionando! Accede a /docs para ver los endpoints."}

# Bloque de ejecución directa para desarrollo y pruebas
if __name__ == "__main__":
    import uvicorn
    # Inicia el servidor Uvicorn en 0.0.0.0 (accesible desde fuera de localhost)
    # y en el puerto 8000, que es al que apunta tu configuración de Nginx.
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
