-- sql_transform/dimensions/dim_vendedores.sql
-- Modelo: La Dimensión (dim_vendedores) modela a la Persona/Entidad Vendedora Única.

-- 1. Eliminar la tabla existente y la secuencia (para reconstruir o corregir)
DROP TABLE IF EXISTS dim_vendedores CASCADE;
DROP SEQUENCE IF EXISTS dim_vendedores_id_vendedor_seq;

-- 2. Creación de la secuencia para la Clave Subrogada (PK)
CREATE SEQUENCE dim_vendedores_id_vendedor_seq;

-- 3. Creación de la tabla final dim_vendedores
CREATE TABLE dim_vendedores (
    -- Clave Subrogada (PK)
    id_vendedor INTEGER PRIMARY KEY DEFAULT nextval('dim_vendedores_id_vendedor_seq'),
    
    -- Clave Natural / IDENTIFICADOR ÚNICO DEL VENDEDOR (seller_id). Esta debe ser ÚNICA.
    clave_vendedor VARCHAR(100) NOT NULL,
    
    -- Código Postal del vendedor (El resto de geografía va en dim_geografia)
    cp_vendedor INTEGER,
    
    -- Restricción de unicidad: SÓLO A NIVEL DE VENDEDOR ÚNICO
    UNIQUE (clave_vendedor)
);

-- 4. Inserción de los datos transformados
-- Usamos DISTINCT ON para asegurar que solo se inserte UN registro por cada seller_id.
INSERT INTO dim_vendedores (
    clave_vendedor, 
    cp_vendedor
)
SELECT DISTINCT ON (data->>'seller_id')
    -- seller_id (VARCHAR)
    (data->>'seller_id')::VARCHAR(100) AS clave_vendedor,
    
    -- seller_zip_code_prefix (INTEGER)
    (data->>'seller_zip_code_prefix')::INTEGER AS cp_vendedor
FROM
    dim_vendedores_raw
ORDER BY data->>'seller_id';
