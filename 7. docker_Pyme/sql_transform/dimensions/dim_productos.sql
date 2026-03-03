-- sql_transform/dimensions/dim_productos.sql
-- Modelo: La Dimensión (dim_productos) modela al Producto Único.

-- 1. Eliminar la tabla existente y la secuencia (para reconstruir o corregir)
DROP TABLE IF EXISTS dim_productos CASCADE;
DROP SEQUENCE IF EXISTS dim_productos_id_producto_seq;

-- 2. Creación de la secuencia para la Clave Subrogada (PK)
CREATE SEQUENCE dim_productos_id_producto_seq;

-- 3. Creación de la tabla final dim_productos (Basado en la estructura previamente existente)
CREATE TABLE dim_productos (
    -- Clave Subrogada (PK)
    id_producto INTEGER PRIMARY KEY DEFAULT nextval('dim_productos_id_producto_seq'),
    
    -- Clave de Origen (product_id). Esta debe ser ÚNICA.
    id_producto_origen VARCHAR(100) NOT NULL,
    
    -- Categoría del producto
    cat_producto VARCHAR(100),
    
    -- Peso en gramos
    peso_producto NUMERIC(10,2),
    
    -- Dimensiones (Largo, Ancho, Alto) en cm
    long_producto NUMERIC(10,2),
    ancho_producto NUMERIC(10,2),
    altura_producto NUMERIC(10,2),
    
    -- Volumen calculado (L * A * H)
    volumen_producto NUMERIC(10,2),
    
    -- Columna pendiente de definición (se puede dejar en NULL por ahora)
    rel_volumen_coste_envio NUMERIC(10,2),
    
    -- Restricción de unicidad: SÓLO A NIVEL DE PRODUCTO ÚNICO
    UNIQUE (id_producto_origen)
);

-- 4. Inserción de los datos transformados
INSERT INTO dim_productos (
    id_producto_origen, 
    cat_producto, 
    peso_producto, 
    long_producto, 
    ancho_producto, 
    altura_producto, 
    volumen_producto
)
SELECT DISTINCT ON (data->>'product_id')
    -- id_producto_origen (product_id)
    (data->>'product_id')::VARCHAR(100) AS id_producto_origen,
    
    -- Categoría
    (data->>'product_category_name')::VARCHAR(100) AS cat_producto,
    
    -- Métricas de peso y dimensiones
    (data->>'product_weight_g')::NUMERIC(10,2) AS peso_producto,
    (data->>'product_length_cm')::NUMERIC(10,2) AS long_producto,
    (data->>'product_width_cm')::NUMERIC(10,2) AS ancho_producto,
    (data->>'product_height_cm')::NUMERIC(10,2) AS altura_producto,
    
    -- Cálculo del Volumen (Largo * Ancho * Alto)
    (
        COALESCE((data->>'product_length_cm')::NUMERIC, 0) *
        COALESCE((data->>'product_width_cm')::NUMERIC, 0) *
        COALESCE((data->>'product_height_cm')::NUMERIC, 0)
    )::NUMERIC(10,2) AS volumen_producto
FROM
    dim_productos_raw
ORDER BY data->>'product_id';
