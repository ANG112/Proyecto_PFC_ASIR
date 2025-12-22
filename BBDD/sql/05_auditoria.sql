-- ==========================================================
--	AUDITORÍA: RESUMEN FINAL PROCESO ETL 
-- ==========================================================

SELECT 
    tabla, 
    total_stg, 
    total_def, 
    descartados,
    ROUND((descartados * 100.0 / NULLIF(total_stg, 0)), 2) || '%' as porcentaje_descarte
FROM (
    SELECT 'GEOLOCATION' as tabla, 
           (SELECT count(*) FROM stg_geo_location) as total_stg, 
           (SELECT count(*) FROM geo_location) as total_def,
           (SELECT count(*) FROM stg_geo_location) - (SELECT count(*) FROM geo_location) as descartados
    UNION ALL
    SELECT 'PRODUCTS', 
           (SELECT count(*) FROM stg_products), 
           (SELECT count(*) FROM products),
           (SELECT count(*) FROM stg_products) - (SELECT count(*) FROM products)
    UNION ALL
    SELECT 'SELLERS', 
           (SELECT count(*) FROM stg_sellers), 
           (SELECT count(*) FROM sellers),
           (SELECT count(*) FROM stg_sellers) - (SELECT count(*) FROM sellers)
    UNION ALL
    SELECT 'CUSTOMERS', 
           (SELECT count(*) FROM stg_customers), 
           (SELECT count(*) FROM customers),
           (SELECT count(*) FROM stg_customers) - (SELECT count(*) FROM customers)
    UNION ALL
    SELECT 'ORDERS', 
           (SELECT count(*) FROM stg_orders), 
           (SELECT count(*) FROM orders),
           (SELECT count(*) FROM stg_orders) - (SELECT count(*) FROM orders)
    UNION ALL
    SELECT 'ORDER_ITEMS', 
           (SELECT count(*) FROM stg_order_items), 
           (SELECT count(*) FROM order_items),
           (SELECT count(*) FROM stg_order_items) - (SELECT count(*) FROM order_items)
    UNION ALL
    SELECT 'ORDER_PAYMENTS', 
           (SELECT count(*) FROM stg_order_payments), 
           (SELECT count(*) FROM order_payments),
           (SELECT count(*) FROM stg_order_payments) - (SELECT count(*) FROM order_payments)
    UNION ALL
    SELECT 'ORDER_REVIEWS', 
           (SELECT count(*) FROM stg_order_review_ratings), 
           (SELECT count(*) FROM order_review_ratings),
           (SELECT count(*) FROM stg_order_review_ratings) - (SELECT count(*) FROM order_review_ratings)
) as auditoria;
