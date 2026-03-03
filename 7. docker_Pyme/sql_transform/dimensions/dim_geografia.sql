-- sql_transform/dimensions/dim_geografia.sql
-- Modelo: Dimensión Geográfica (centrada en el prefijo de código postal)
-- CORRECCIÓN: ORDER BY debe coincidir con DISTINCT ON.

-- 1. Eliminar la tabla existente y la secuencia (para reconstruir)
DROP TABLE IF EXISTS dim_geografia CASCADE;
DROP SEQUENCE IF EXISTS dim_geografia_id_geografia_seq;

-- 2. Creación de la secuencia para la Clave Subrogada (PK)
CREATE SEQUENCE dim_geografia_id_geografia_seq;

-- 3. Creación de la tabla final dim_geografia
CREATE TABLE dim_geografia (
    -- Clave Subrogada (PK)
    id_geografia INTEGER PRIMARY KEY DEFAULT nextval('dim_geografia_id_geografia_seq'),
    
    -- Código Postal (Prefix)
    cp_geografia INTEGER NOT NULL,
    
    -- Ciudad
    ciudad_geografia VARCHAR(100) NOT NULL,
    
    -- Estado/Provincia
    provincia_geografia VARCHAR(100) NOT NULL,
    
    -- Restricción de unicidad: Asegura que cada combinación sea una sola fila.
    UNIQUE (cp_geografia, ciudad_geografia, provincia_geografia)
);

-- 4. Inserción de los datos transformados
INSERT INTO dim_geografia (
    cp_geografia, 
    ciudad_geografia, 
    provincia_geografia
)
SELECT DISTINCT ON (
    (data->>'geolocation_zip_code_prefix'), 
    (data->>'geolocation_city'),
    (data->>'geolocation_state')
)
    -- Extracción con las claves corregidas y casting a los tipos correctos
    (data->>'geolocation_zip_code_prefix')::INTEGER AS cp_geografia,
    (data->>'geolocation_city')::VARCHAR(100) AS ciudad_geografia,
    (data->>'geolocation_state')::VARCHAR(100) AS provincia_geografia
FROM
    dim_geografia_raw
ORDER BY 
    -- ESTA ES LA CLÁUSULA CORREGIDA: Usamos las mismas expresiones que en DISTINCT ON
    (data->>'geolocation_zip_code_prefix'), 
    (data->>'geolocation_city'),
    (data->>'geolocation_state');
