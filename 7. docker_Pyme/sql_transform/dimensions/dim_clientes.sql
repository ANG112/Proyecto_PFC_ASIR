-- sql_transform/dimensions/dim_clientes.sql
-- Modelo: La Dimensión (dim_clientes) modela a la Persona Única (clave_unica_cliente).

-- 1. Eliminar la tabla existente y la secuencia
DROP TABLE IF EXISTS dim_clientes CASCADE;
DROP SEQUENCE IF EXISTS dim_clientes_id_cliente_seq;

-- 2. Creación de la secuencia para la Clave Subrogada (PK)
CREATE SEQUENCE dim_clientes_id_cliente_seq;

-- 3. Creación de la tabla final dim_clientes (Modelo de Persona Única)
CREATE TABLE dim_clientes (
    -- Clave Subrogada (PK)
    id_cliente INTEGER PRIMARY KEY DEFAULT nextval('dim_clientes_id_cliente_seq'),
    
    -- Clave Natural / IDENTIFICADOR ÚNICO DE LA PERSONA (customer_unique_id).
    clave_unica_cliente VARCHAR(100) NOT NULL,
    
    -- Código Postal (Solo el CP de la primera transacción, solo para atributos generales)
    cp_cliente INTEGER,
    
    -- Restricción de unicidad: SOLO A NIVEL DE CLIENTE ÚNICO (la persona)
    UNIQUE (clave_unica_cliente)
);

-- 4. Inserción de los datos transformados
-- Usamos DISTINCT ON (clave_unica_cliente) para seleccionar UNA sola instancia de cada persona 
-- y así poblar la dimensión.
INSERT INTO dim_clientes (
    clave_unica_cliente, 
    cp_cliente
)
SELECT DISTINCT ON (data->>'customer_unique_id')
    (data->>'customer_unique_id')::VARCHAR(100) AS clave_unica_cliente,
    (data->>'customer_zip_code_prefix')::INTEGER AS cp_cliente
FROM
    dim_clientes_raw
ORDER BY data->>'customer_unique_id';
