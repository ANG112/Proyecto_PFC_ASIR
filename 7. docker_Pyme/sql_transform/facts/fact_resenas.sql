-- sql_transform/facts/fact_resenas.sql

-- 1. Eliminar la tabla existente
DROP TABLE IF EXISTS fact_resenas CASCADE;

-- 2. Creación de la tabla final fact_resenas
CREATE TABLE fact_resenas (
    id_review_sk BIGSERIAL PRIMARY KEY,

    -- Claves Foráneas (Dimensiones)
    id_cliente INTEGER NOT NULL,
    id_vendedor INTEGER NOT NULL,
    id_producto INTEGER,

    -- Claves Foráneas de Fecha (CAMBIADO A INTEGER)
    id_fecha_creacion INTEGER NOT NULL,
    id_fecha_respuesta INTEGER,

    -- Claves de Origen
    review_id_origen VARCHAR(100) NOT NULL,
    order_id_origen VARCHAR(100) NOT NULL,

    -- Métricas / Hechos
    puntuacion_resena INTEGER NOT NULL,
    dias_respuesta NUMERIC(10,2), 
    longitud_mensaje INTEGER,      

    -- Restricciones
    FOREIGN KEY (id_cliente) REFERENCES dim_clientes (id_cliente),
    FOREIGN KEY (id_vendedor) REFERENCES dim_vendedores (id_vendedor),
    FOREIGN KEY (id_producto) REFERENCES dim_productos (id_producto),
    -- NUEVOS FKs vinculados a la Dimensión Fecha (Integer)
    FOREIGN KEY (id_fecha_creacion) REFERENCES dim_fecha (id_fecha),
    FOREIGN KEY (id_fecha_respuesta) REFERENCES dim_fecha (id_fecha)
);

-- 3. Inserción de los datos transformados
INSERT INTO fact_resenas (
    id_cliente, id_vendedor, id_producto,
    id_fecha_creacion, id_fecha_respuesta,
    review_id_origen, order_id_origen,
    puntuacion_resena, dias_respuesta, longitud_mensaje
)
SELECT
    dc.id_cliente,
    dv.id_vendedor,
    dp.id_producto,

    -- Transformación de Fechas a INTEGER (YYYYMMDD)
    TO_CHAR((NULLIF(tr.data->>'review_creation_date', ''))::TIMESTAMP, 'YYYYMMDD')::INTEGER AS id_fecha_creacion,
    TO_CHAR((NULLIF(tr.data->>'review_answer_timestamp', ''))::TIMESTAMP, 'YYYYMMDD')::INTEGER AS id_fecha_respuesta,

    -- Claves de Origen
    (tr.data->>'review_id')::VARCHAR(100),
    (tr.data->>'order_id')::VARCHAR(100),

    -- Métricas
    (tr.data->>'review_score')::INTEGER,

    -- Cálculo de Días de Respuesta
    EXTRACT(EPOCH FROM ((tr.data->>'review_answer_timestamp')::TIMESTAMP - (tr.data->>'review_creation_date')::TIMESTAMP)) / 86400,

    -- Longitud del mensaje
    LENGTH(COALESCE(tr.data->>'review_comment_message', tr.data->>'review_comment_title'))

FROM
    tbl_resenas_raw tr
INNER JOIN tbl_logistica_raw tl ON (tr.data->>'order_id') = (tl.data->>'order_id')
INNER JOIN tbl_desglose_pedido_raw td ON (tr.data->>'order_id') = (td.data->>'order_id')
INNER JOIN dim_clientes_raw dcr ON (tl.data->>'customer_id') = (dcr.data->>'customer_id')
INNER JOIN dim_clientes dc ON (dcr.data->>'customer_unique_id') = dc.clave_unica_cliente
INNER JOIN dim_vendedores dv ON (td.data->>'seller_id') = dv.clave_vendedor
INNER JOIN dim_productos dp ON (td.data->>'product_id') = dp.id_producto_origen;
