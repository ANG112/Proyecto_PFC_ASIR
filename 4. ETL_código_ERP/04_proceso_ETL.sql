-- ==========================================================
-- SCRIPT 04: TRANSFORMACIÓN Y CARGA FINAL (ELT)
-- ==========================================================

-- 1. GEOLOCATION (Limpieza por frecuencia/Moda)
-- Esto asegura que cada CP sea único y elijamos la mejor coordenada.
INSERT INTO geo_location (
    geolocation_zip_code_prefix, 
    geolocation_lat, 
    geolocation_lng, 
    geolocation_city, 
    geolocation_state
)
SELECT DISTINCT ON (geolocation_zip_code_prefix)
    CAST(geolocation_zip_code_prefix AS INT),
    CAST(geolocation_lat AS DOUBLE PRECISION),
    CAST(geolocation_lng AS DOUBLE PRECISION),
    geolocation_city,
    geolocation_state
FROM stg_geo_location
ORDER BY geolocation_zip_code_prefix, geolocation_lat ASC
ON CONFLICT (geolocation_zip_code_prefix) DO NOTHING;


-- 2. PRODUCTS
INSERT INTO products (product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
SELECT
    product_id,
    COALESCE(product_category_name, 'sin_categoria'),
    CAST(COALESCE(NULLIF(product_name_lenght, ''), '0') AS INT),
    CAST(COALESCE(NULLIF(product_description_lenght, ''), '0') AS INT),
    CAST(COALESCE(NULLIF(product_photos_qty, ''), '0') AS INT),
    CAST(COALESCE(NULLIF(product_weight_g, ''), '0') AS INT),
    CAST(COALESCE(NULLIF(product_length_cm, ''), '0') AS INT),
    CAST(COALESCE(NULLIF(product_height_cm, ''), '0') AS INT),
    CAST(COALESCE(NULLIF(product_width_cm, ''), '0') AS INT)
FROM stg_products;

-- 3. SELLERS
INSERT INTO sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state)
SELECT DISTINCT
    seller_id,
    CAST(seller_zip_code_prefix AS INT),
    seller_city,
    seller_state
FROM stg_sellers;

-- 4. CUSTOMERS
-- Importante: Solo entran clientes cuyo CP esté en nuestra tabla geo_location
INSERT INTO customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
SELECT DISTINCT
    customer_id,
    customer_unique_id,
    CAST(customer_zip_code_prefix AS INT),
    customer_city,
    customer_state
FROM stg_customers
WHERE CAST(customer_zip_code_prefix AS INT) IN (SELECT geolocation_zip_code_prefix FROM geo_location);

-- 5. ORDERS
INSERT INTO orders (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date)
SELECT
    order_id,
    customer_id,
    CAST(order_status AS order_status_enum),
    CAST(order_purchase_timestamp AS TIMESTAMP),
    NULLIF(order_approved_at, '')::TIMESTAMP,
    NULLIF(order_delivered_carrier_date, '')::TIMESTAMP,
    NULLIF(order_delivered_customer_date, '')::TIMESTAMP,
    CAST(order_estimated_delivery_date AS TIMESTAMP)
FROM stg_orders
WHERE customer_id IN (SELECT customer_id FROM customers);

-- 6. ORDER_ITEMS
INSERT INTO order_items (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
SELECT 
    s.order_id, 
    CAST(s.order_item_id AS INT), 
    s.product_id, 
    s.seller_id, 
    CAST(s.shipping_limit_date AS TIMESTAMP), 
    CAST(s.price AS NUMERIC), 
    CAST(s.freight_value AS NUMERIC)
FROM stg_order_items s
INNER JOIN orders o ON s.order_id = o.order_id
WHERE s.product_id IN (SELECT product_id FROM products);

-- 7. ORDER_PAYMENTS
INSERT INTO order_payments (order_id, payment_sequential, payment_type, payment_installments, payment_value)
SELECT 
    s.order_id, 
    CAST(s.payment_sequential AS INT), 
    s.payment_type, 
    CAST(s.payment_installments AS INT), 
    CAST(s.payment_value AS NUMERIC)
FROM stg_order_payments s
INNER JOIN orders o ON s.order_id = o.order_id;

-- 8. ORDER_REVIEW_RATINGS
INSERT INTO order_review_ratings (review_id, order_id, review_score,  review_creation_date, review_answer_timestamp)
SELECT DISTINCT ON (review_id) 
    review_id, 
    order_id, 
    CAST(review_score AS INT), 
    CAST(review_creation_date AS TIMESTAMP), 
    NULLIF(review_answer_timestamp, '')::TIMESTAMP
FROM stg_order_review_ratings
WHERE order_id IN (SELECT order_id FROM orders)
ORDER BY review_id;
