-- ==========================================================
-- MODELO FINAL DE HECHOS DE PEDIDOS Y LOGÍSTICA (DWH) - CORREGIDO
-- ==========================================================

-- 1. Eliminar la tabla existente
DROP TABLE IF EXISTS fact_pedidos CASCADE;

-- 2. Creación de la tabla final fact_pedidos
CREATE TABLE fact_pedidos (
    id_pedido_sk BIGSERIAL PRIMARY KEY,

    -- Claves Foráneas (Dimensiones)
    id_cliente INTEGER NOT NULL,
    id_vendedor INTEGER NOT NULL,
    id_producto INTEGER,
    id_geografia_cliente INTEGER NOT NULL,
    id_geografia_vendedor INTEGER NOT NULL,

    -- Claves de Fecha (Referencia a dim_fecha) - CAMBIADO A INTEGER
    id_fecha_compra INTEGER NOT NULL,
    id_fecha_aprobacion INTEGER,
    id_fecha_envio INTEGER,
    id_fecha_entrega INTEGER,
    id_fecha_entrega_estimada INTEGER,

    -- Métricas de Tiempo
    tmp_trans_entrega NUMERIC(10,2),
    tmp_aprov_envio NUMERIC(10,2),
    tmp_compra_aprov NUMERIC(10,2),
    tmp_compra_transp NUMERIC(10,2),
    tmp_estimada_entrega NUMERIC(10,2),

    -- Métricas de Valor
    valor_total_pedido NUMERIC(10,2) NOT NULL,
    valor_flete NUMERIC(10,2) NOT NULL,
    valor_pagado NUMERIC(10,2) NOT NULL,
    cantidad_articulos INTEGER NOT NULL,
    cantidad_cuotas INTEGER NOT NULL,

    -- Atributos
    estado_pedido VARCHAR(50) NOT NULL,
    tipo_pago VARCHAR(50) NOT NULL,

    -- Constraints (Integridad Referencial con Dim_Fecha)
    FOREIGN KEY (id_cliente) REFERENCES dim_clientes (id_cliente),
    FOREIGN KEY (id_vendedor) REFERENCES dim_vendedores (id_vendedor),
    FOREIGN KEY (id_producto) REFERENCES dim_productos (id_producto),
    FOREIGN KEY (id_geografia_cliente) REFERENCES dim_geografia (id_geografia),
    FOREIGN KEY (id_geografia_vendedor) REFERENCES dim_geografia (id_geografia),
    -- NUEVOS FKs
    FOREIGN KEY (id_fecha_compra) REFERENCES dim_fecha (id_fecha),
    FOREIGN KEY (id_fecha_aprobacion) REFERENCES dim_fecha (id_fecha),
    FOREIGN KEY (id_fecha_envio) REFERENCES dim_fecha (id_fecha),
    FOREIGN KEY (id_fecha_entrega) REFERENCES dim_fecha (id_fecha),
    FOREIGN KEY (id_fecha_entrega_estimada) REFERENCES dim_fecha (id_fecha)
);

-- 3. Inserción de los datos transformados
INSERT INTO fact_pedidos (
    id_cliente, id_vendedor, id_producto, id_geografia_cliente, id_geografia_vendedor,
    id_fecha_compra, id_fecha_aprobacion, id_fecha_envio, id_fecha_entrega, id_fecha_entrega_estimada,
    tmp_trans_entrega, tmp_aprov_envio, tmp_compra_aprov, tmp_compra_transp, tmp_estimada_entrega,
    valor_total_pedido, valor_flete, valor_pagado, cantidad_articulos, cantidad_cuotas,
    estado_pedido, tipo_pago
)
SELECT
    dc.id_cliente,
    dv.id_vendedor,
    MIN(dp.id_producto) AS id_producto,
    gc.id_geografia AS id_geografia_cliente,
    gv.id_geografia AS id_geografia_vendedor,

    -- Transformación de Fechas a formato INTEGER (YYYYMMDD)
    to_char((NULLIF(tl.data->>'order_purchase_timestamp', ''))::TIMESTAMP, 'YYYYMMDD')::INTEGER,
    to_char((NULLIF(tl.data->>'order_approved_at', ''))::TIMESTAMP, 'YYYYMMDD')::INTEGER,
    to_char((NULLIF(tl.data->>'order_delivered_carrier_date', ''))::TIMESTAMP, 'YYYYMMDD')::INTEGER,
    to_char((NULLIF(tl.data->>'order_delivered_customer_date', ''))::TIMESTAMP, 'YYYYMMDD')::INTEGER,
    to_char((NULLIF(tl.data->>'order_estimated_delivery_date', ''))::TIMESTAMP, 'YYYYMMDD')::INTEGER,

    -- CÁLCULOS DE TIEMPO (Se mantienen igual)
    EXTRACT(DAY FROM (NULLIF(tl.data->>'order_delivered_customer_date', '')::TIMESTAMP - NULLIF(tl.data->>'order_delivered_carrier_date', '')::TIMESTAMP)) AS tmp_trans_entrega,
    EXTRACT(DAY FROM (NULLIF(tl.data->>'order_delivered_carrier_date', '')::TIMESTAMP - NULLIF(tl.data->>'order_approved_at', '')::TIMESTAMP)) AS tmp_aprov_envio,
    EXTRACT(DAY FROM (NULLIF(tl.data->>'order_approved_at', '')::TIMESTAMP - NULLIF(tl.data->>'order_purchase_timestamp', '')::TIMESTAMP)) AS tmp_compra_aprov,
    EXTRACT(DAY FROM (NULLIF(tl.data->>'order_delivered_carrier_date', '')::TIMESTAMP - NULLIF(tl.data->>'order_purchase_timestamp', '')::TIMESTAMP)) AS tmp_compra_transp,
    EXTRACT(DAY FROM (NULLIF(tl.data->>'order_estimated_delivery_date', '')::TIMESTAMP - NULLIF(tl.data->>'order_delivered_customer_date', '')::TIMESTAMP)) AS tmp_estimada_entrega,

    -- Métricas de Valor
    SUM((td.data->>'price')::NUMERIC + (td.data->>'freight_value')::NUMERIC),
    SUM((td.data->>'freight_value')::NUMERIC),
    SUM((tp.data->>'payment_value')::NUMERIC),
    COUNT(td.data->>'order_item_id'),
    MAX((tp.data->>'payment_installments')::INTEGER),

    -- Atributos descriptivos
    (tl.data->>'order_status')::VARCHAR(50),
    (tp.data->>'payment_type')::VARCHAR(50)

FROM
    tbl_logistica_raw tl
INNER JOIN tbl_desglose_pedido_raw td ON (tl.data->>'order_id') = (td.data->>'order_id')
INNER JOIN tbl_pagos_raw tp ON (tl.data->>'order_id') = (tp.data->>'order_id')
INNER JOIN dim_clientes_raw dcr ON (tl.data->>'customer_id') = (dcr.data->>'customer_id')
INNER JOIN dim_clientes dc ON (dcr.data->>'customer_unique_id') = dc.clave_unica_cliente
INNER JOIN dim_vendedores dv ON (td.data->>'seller_id') = dv.clave_vendedor
INNER JOIN dim_productos dp ON (td.data->>'product_id') = dp.id_producto_origen
INNER JOIN dim_geografia gc ON (dcr.data->>'customer_zip_code_prefix')::INTEGER = gc.cp_geografia
INNER JOIN dim_geografia gv ON (dv.cp_vendedor) = gv.cp_geografia

GROUP BY
    tl.data->>'order_id', tl.data->>'customer_id', tl.data->>'order_status',
    tl.data->>'order_purchase_timestamp', tl.data->>'order_approved_at', tl.data->>'order_delivered_carrier_date',
    tl.data->>'order_delivered_customer_date', tl.data->>'order_estimated_delivery_date',
    tp.data->>'payment_type', dcr.data->>'customer_unique_id',
    dc.id_cliente, dv.id_vendedor, gc.id_geografia, gv.id_geografia;
