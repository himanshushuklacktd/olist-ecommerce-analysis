CREATE DATABASE olist_db;

USE olist_db;

CREATE TABLE orders (
  order_id VARCHAR(50),
  customer_id VARCHAR(50),
  order_status VARCHAR(20),
  order_purchase_timestamp DATETIME,
  order_approved_at DATETIME,
  order_delivered_carrier_date DATETIME,
  order_delivered_customer_date DATETIME,
  order_estimated_delivery_date DATETIME
);

CREATE TABLE order_items (
  order_id VARCHAR(50),
  order_item_id INT,
  product_id VARCHAR(50),
  seller_id VARCHAR(50),
  shipping_limit_date DATETIME,
  price DECIMAL(10,2),
  freight_value DECIMAL(10,2)
);

CREATE TABLE customers (
  customer_id VARCHAR(50),
  customer_unique_id VARCHAR(50),
  customer_zip_code_prefix VARCHAR(10),
  customer_city VARCHAR(100),
  customer_state VARCHAR(5)
);

CREATE TABLE products (
  product_id VARCHAR(50),
  product_category_name VARCHAR(100),
  product_name_lenght INT,
  product_description_lenght INT,
  product_photos_qty INT,
  product_weight_g INT,
  product_length_cm INT,
  product_height_cm INT,
  product_width_cm INT
);

CREATE TABLE sellers (
  seller_id VARCHAR(50),
  seller_zip_code_prefix VARCHAR(10),
  seller_city VARCHAR(100),
  seller_state VARCHAR(5)
);

CREATE TABLE payments (
  order_id VARCHAR(50),
  payment_sequential INT,
  payment_type VARCHAR(30),
  payment_installments INT,
  payment_value DECIMAL(10,2)
);

CREATE TABLE category_translation (
  product_category_name VARCHAR(100),
  product_category_name_english VARCHAR(100)
);


SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv'
INTO TABLE category_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@order_id,
 @customer_id,
 @order_status,
 @order_purchase_timestamp,
 @order_approved_at,
 @order_delivered_carrier_date,
 @order_delivered_customer_date,
 @order_estimated_delivery_date)
SET
order_id = @order_id,
customer_id = @customer_id,
order_status = @order_status,
order_purchase_timestamp = NULLIF(@order_purchase_timestamp, ''),
order_approved_at = NULLIF(@order_approved_at, ''),
order_delivered_carrier_date = NULLIF(@order_delivered_carrier_date, ''),
order_delivered_customer_date = NULLIF(@order_delivered_customer_date, ''),
order_estimated_delivery_date = NULLIF(@order_estimated_delivery_date, '');


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments_dataset.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@product_id,
 @product_category_name,
 @product_name_lenght,
 @product_description_lenght,
 @product_photos_qty,
 @product_weight_g,
 @product_length_cm,
 @product_height_cm,
 @product_width_cm)
SET
product_id = @product_id,
product_category_name = NULLIF(@product_category_name, ''),
product_name_lenght = NULLIF(@product_name_lenght, ''),
product_description_lenght = NULLIF(@product_description_lenght, ''),
product_photos_qty = NULLIF(@product_photos_qty, ''),
product_weight_g = NULLIF(@product_weight_g, ''),
product_length_cm = NULLIF(@product_length_cm, ''),
product_height_cm = NULLIF(@product_height_cm, ''),
product_width_cm = NULLIF(@product_width_cm, '');



USE olist_db;

SELECT COUNT(*) FROM orders;          -- should be ~99k
SELECT COUNT(*) FROM order_items;     -- should be ~112k
SELECT COUNT(*) FROM customers;       -- should be ~99k
SELECT COUNT(*) FROM products;        -- should be ~33k
SELECT COUNT(*) FROM payments;        -- should be ~103k
SELECT COUNT(*) FROM sellers;         -- should be ~3k
SELECT COUNT(*) FROM category_translation; -- should be ~71


-- Create a Clean Working Table

CREATE TABLE orders_cleaned AS
SELECT
  o.order_id,
  o.customer_id,
  o.order_status,
  o.order_purchase_timestamp,
  o.order_delivered_customer_date,
  o.order_estimated_delivery_date,

  -- 1. Extract order month (for monthly analysis)
  DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,

  -- 2. Delivery time in days
  DATEDIFF(
    o.order_delivered_customer_date,
    o.order_purchase_timestamp
  ) AS delivery_time_days,

  -- 3. Late delivery flag (1 = late, 0 = on time)
  CASE
    WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
    THEN 1
    ELSE 0
  END AS late_delivery_flag

FROM orders o
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp IS NOT NULL;
  
  
-- Verify Clean Table

-- Check row count
SELECT COUNT(*) FROM orders_cleaned;
-- Should be ~96k (only delivered orders)

-- Preview first 5 rows
SELECT * FROM orders_cleaned LIMIT 5;

-- Check late delivery %
SELECT
  ROUND(SUM(late_delivery_flag) * 100.0 / COUNT(*), 2) AS late_delivery_pct
FROM orders_cleaned;
-- Expect somewhere around 8–12%

