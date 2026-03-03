-- TABLAS STAGING para insertar los datos en bruto 
-- Solo se crean los campos con un tipo de texto laxo como TEXT

DROP TABLE IF EXISTS stg_sellers, stg_products, stg_geo_location, stg_customers, stg_orders, stg_order_items, stg_order_payments, stg_order_review_ratings CASCADE;

-- Tabla SELLERS
CREATE TABLE  stg_sellers (
	seller_id TEXT,
	seller_zip_code_prefix TEXT,
	seller_city TEXT,
	seller_state TEXT

);


-- Tabla PRODUCTS
CREATE TABLE stg_products (
	product_id TEXT,
	product_category_name TEXT,
	product_name_lenght TEXT,
	product_description_lenght TEXT,
	product_photos_qty TEXT,
	product_weight_g TEXT,
	product_length_cm TEXT,
	product_height_cm TEXT,
	product_width_cm TEXT

);



-- Tabla GEO_LOCATION
CREATE TABLE stg_geo_location (
	geolocation_zip_code_prefix TEXT,
	geolocation_lat TEXT,
	geolocation_lng TEXT,
	geolocation_city TEXT,
	geolocation_state TEXT
);



-- Tabla CUSTOMERS
CREATE TABLE stg_customers (
	customer_id TEXT,
	customer_unique_id TEXT,
	customer_zip_code_prefix TEXT,
	customer_city TEXT,
	customer_state  TEXT
);


-- Tabla ORDERS
CREATE TABLE stg_orders (
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TEXT,
    order_approved_at TEXT,
    order_delivered_carrier_date TEXT,
    order_delivered_customer_date TEXT,
    order_estimated_delivery_date TEXT
);


-- Tabla ORDER_ITEMS
CREATE TABLE stg_order_items (
    order_id TEXT,
    order_item_id TEXT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TEXT,
    price TEXT,
    freight_value TEXT
);


-- Tabla ORDER_PAYMENTS
CREATE TABLE stg_order_payments (
    order_id TEXT,
    payment_sequential TEXT,
    payment_type TEXT,
    payment_installments TEXT,
    payment_value TEXT
);



-- Tabla ORDER_REVIEW_RATINGS
CREATE TABLE stg_order_review_ratings (
    review_id TEXT,
    order_id TEXT,
    review_score TEXT,
    review_creation_date TEXT,
    review_answer_timestamp TEXT
);
