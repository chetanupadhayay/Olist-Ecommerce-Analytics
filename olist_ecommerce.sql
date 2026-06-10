-- =============================================================
-- PROJECT  : Olist Brazilian E-Commerce Analytics
-- DATABASE : MySQL
-- AUTHOR   : Chetan
-- PURPOSE  : End-to-end sales, customer, delivery & product
--            analysis on the Olist public dataset (Kaggle)
-- =============================================================


-- =============================================================
-- SECTION 0 : DATABASE SETUP
-- =============================================================

CREATE DATABASE IF NOT EXISTS olist_ecommerce;
USE olist_ecommerce;


-- =============================================================
-- SECTION 1 : TABLE DEFINITIONS
-- =============================================================

-- Stores customer details and their geographic location.
CREATE TABLE customers (
    customer_id            VARCHAR(50)  PRIMARY KEY,
    customer_unique_id     VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city          VARCHAR(100),
    customer_state         CHAR(2)
);

-- One row per order placed on the platform.
CREATE TABLE orders (
    order_id                        VARCHAR(50) PRIMARY KEY,
    customer_id                     VARCHAR(50),
    order_status                    VARCHAR(30),
    order_purchase_timestamp        DATETIME,
    order_approved_at               DATETIME,
    order_delivered_carrier_date    DATETIME,
    order_delivered_customer_date   DATETIME,
    order_estimated_delivery_date   DATETIME,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Product catalogue with physical dimensions and metadata.
CREATE TABLE products (
    product_id                  VARCHAR(50) PRIMARY KEY,
    product_category_name       VARCHAR(100),
    product_name_lenght         INT,      -- kept as-is to match CSV header
    product_description_lenght  INT,
    product_photos_qty          INT,
    product_weight_g            INT,
    product_length_cm           INT,
    product_height_cm           INT,
    product_width_cm            INT
);

-- Seller registry with location info.
CREATE TABLE sellers (
    seller_id              VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city            VARCHAR(100),
    seller_state           CHAR(2)
);

-- Line items within each order (product + seller + price).
CREATE TABLE order_items (
    order_id            VARCHAR(50),
    order_item_id       INT,
    product_id          VARCHAR(50),
    seller_id           VARCHAR(50),
    shipping_limit_date DATETIME,
    price               DECIMAL(10, 2),
    freight_value       DECIMAL(10, 2),
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id)  REFERENCES sellers(seller_id)
);

-- Payment details — one order can have multiple payment records
-- (e.g. credit card + voucher split).
CREATE TABLE payments (
    order_id             VARCHAR(50),
    payment_sequential   INT,
    payment_type         VARCHAR(30),
    payment_installments INT,
    payment_value        DECIMAL(10, 2),
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Customer reviews linked to orders.
CREATE TABLE reviews (
    review_id               VARCHAR(50) PRIMARY KEY,
    order_id                VARCHAR(50),
    review_score            INT,
    review_comment_title    TEXT,
    review_comment_message  TEXT,
    review_creation_date    DATETIME,
    review_answer_timestamp DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Geolocation lookup by ZIP code prefix.
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat             DECIMAL(10, 7),
    geolocation_lng             DECIMAL(10, 7),
    geolocation_city            VARCHAR(100),
    geolocation_state           CHAR(2)
);

-- Portuguese → English category name mapping.
CREATE TABLE category_translation (
    product_category_name         VARCHAR(100),
    product_category_name_english VARCHAR(100)
);


-- =============================================================
-- SECTION 2 : DATA IMPORT
-- Note: Enable local_infile before running these statements.
  SET GLOBAL local_infile = 1;
-- =============================================================

LOAD DATA LOCAL INFILE
    'C:/Users/chetan/Projects/Olist-Ecommerce-Analytics/data/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id, customer_unique_id, customer_zip_code_prefix,
 customer_city, customer_state);

LOAD DATA LOCAL INFILE
    'C:/Users/chetan/Projects/Olist-Ecommerce-Analytics/data/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_category_name, product_name_lenght,
 product_description_lenght, product_photos_qty,
 product_weight_g, product_length_cm, product_height_cm, product_width_cm);

LOAD DATA LOCAL INFILE
    'C:/Users/chetan/Projects/Olist-Ecommerce-Analytics/data/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(seller_id, seller_zip_code_prefix, seller_city, seller_state);

LOAD DATA LOCAL INFILE
    'C:/Users/chetan/Projects/Olist-Ecommerce-Analytics/data/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_status, order_purchase_timestamp,
 order_approved_at, order_delivered_carrier_date,
 order_delivered_customer_date, order_estimated_delivery_date);

LOAD DATA LOCAL INFILE
    'C:/Users/chetan/Projects/Olist-Ecommerce-Analytics/data/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, order_item_id, product_id, seller_id,
 shipping_limit_date, price, freight_value);

LOAD DATA LOCAL INFILE
    'C:/Users/chetan/Projects/Olist-Ecommerce-Analytics/data/olist_order_payments_dataset.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, payment_sequential, payment_type,
 payment_installments, payment_value);

LOAD DATA LOCAL INFILE
    'C:/Users/chetan/Projects/Olist-Ecommerce-Analytics/data/olist_order_reviews_dataset.csv'
INTO TABLE reviews
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(review_id, order_id, review_score, review_comment_title,
 review_comment_message, review_creation_date, review_answer_timestamp);

LOAD DATA LOCAL INFILE
    'C:/Users/chetan/Projects/Olist-Ecommerce-Analytics/data/olist_geolocation_dataset.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(geolocation_zip_code_prefix, geolocation_lat, geolocation_lng,
 geolocation_city, geolocation_state);

LOAD DATA LOCAL INFILE
    'C:/Users/chetan/Projects/Olist-Ecommerce-Analytics/data/product_category_name_translation.csv'
INTO TABLE category_translation
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_category_name, product_category_name_english);


-- =============================================================
-- SECTION 3 : DATA PROFILING & QUALITY CHECKS
-- =============================================================

-- ── 3.1  Row counts ──────────────────────────────────────────
SELECT COUNT(*) AS customers_count  FROM customers;
SELECT COUNT(*) AS orders_count     FROM orders;
SELECT COUNT(*) AS order_items_count FROM order_items;
SELECT COUNT(*) AS payments_count   FROM payments;
SELECT COUNT(*) AS products_count   FROM products;
SELECT COUNT(*) AS sellers_count    FROM sellers;
SELECT COUNT(*) AS geolocation_count FROM geolocation;

-- ── 3.2  Distinct (unique) record counts ─────────────────────
SELECT COUNT(DISTINCT customer_id) AS unique_customers FROM customers;
SELECT COUNT(DISTINCT order_id)    AS unique_orders    FROM orders;
SELECT COUNT(DISTINCT product_id)  AS unique_products  FROM products;
SELECT COUNT(DISTINCT seller_id)   AS unique_sellers   FROM sellers;

-- ── 3.3  Dataset date range ──────────────────────────────────
SELECT
    MIN(order_purchase_timestamp) AS first_order_date,
    MAX(order_purchase_timestamp) AS last_order_date
FROM orders;

-- ── 3.4  NULL value audit ────────────────────────────────────

-- customers
SELECT
    SUM(customer_unique_id       IS NULL) AS unique_id_nulls,
    SUM(customer_zip_code_prefix IS NULL) AS zip_nulls,
    SUM(customer_city            IS NULL) AS city_nulls,
    SUM(customer_state           IS NULL) AS state_nulls
FROM customers;

-- orders  (focus on business-critical timestamp columns)
SELECT
    SUM(customer_id                   IS NULL) AS customer_id_nulls,
    SUM(order_status                  IS NULL) AS status_nulls,
    SUM(order_purchase_timestamp      IS NULL) AS purchase_ts_nulls,
    SUM(order_approved_at             IS NULL) AS approved_nulls,
    SUM(order_delivered_customer_date IS NULL) AS delivered_nulls
FROM orders;

-- order_items
SELECT
    SUM(product_id    IS NULL) AS product_nulls,
    SUM(seller_id     IS NULL) AS seller_nulls,
    SUM(price         IS NULL) AS price_nulls,
    SUM(freight_value IS NULL) AS freight_nulls
FROM order_items;

-- payments
SELECT
    SUM(payment_type  IS NULL) AS payment_type_nulls,
    SUM(payment_value IS NULL) AS payment_value_nulls
FROM payments;

-- products  (category is used for grouping — nulls matter)
SELECT SUM(product_category_name IS NULL) AS category_nulls
FROM products;

-- sellers
SELECT
    SUM(seller_city  IS NULL) AS city_nulls,
    SUM(seller_state IS NULL) AS state_nulls
FROM sellers;

-- ── 3.5  Duplicate checks ────────────────────────────────────
-- Any result here means a data quality issue in the source file.

SELECT customer_id, COUNT(*) AS occurrences
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*) AS occurrences
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*) AS occurrences
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT seller_id, COUNT(*) AS occurrences
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

-- ── 3.6  Order status distribution ──────────────────────────
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- =============================================================
-- SECTION 4 : BUSINESS KPIs (SNAPSHOT)
-- =============================================================

-- Total platform revenue
SELECT ROUND(SUM(payment_value), 2) AS total_revenue
FROM payments;

-- Core volume metrics
SELECT COUNT(DISTINCT customer_id) AS total_customers FROM customers;
SELECT COUNT(DISTINCT order_id)    AS total_orders    FROM orders;
SELECT COUNT(DISTINCT product_id)  AS total_products  FROM products;
SELECT COUNT(DISTINCT seller_id)   AS total_sellers   FROM sellers;

-- Average order value  (total revenue / distinct orders)
SELECT
    ROUND(SUM(payment_value) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM payments;

-- Average number of items per order
SELECT
    ROUND(COUNT(*) / COUNT(DISTINCT order_id), 2) AS avg_items_per_order
FROM order_items;

-- Average freight cost per item
SELECT ROUND(AVG(freight_value), 2) AS avg_freight_cost
FROM order_items;

-- Average product price
SELECT ROUND(AVG(price), 2) AS avg_product_price
FROM order_items;


-- =============================================================
-- SECTION 5 : TIME-SERIES REVENUE & ORDER TRENDS
-- =============================================================

-- Monthly revenue trend
SELECT
    YEAR(o.order_purchase_timestamp)  AS yr,
    MONTH(o.order_purchase_timestamp) AS mo,
    ROUND(SUM(p.payment_value), 2)    AS revenue
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY yr, mo
ORDER BY yr, mo;

-- Monthly order volume trend
SELECT
    YEAR(order_purchase_timestamp)  AS yr,
    MONTH(order_purchase_timestamp) AS mo,
    COUNT(*)                        AS total_orders
FROM orders
GROUP BY yr, mo
ORDER BY yr, mo;


-- =============================================================
-- SECTION 6 : GEOGRAPHIC ANALYSIS
-- =============================================================

-- Revenue by state (top 10)
SELECT
    c.customer_state,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM customers c
JOIN orders   o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id    = p.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC
LIMIT 10;

-- Revenue by city (top 10)
SELECT
    c.customer_city,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM customers c
JOIN orders   o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id    = p.order_id
GROUP BY c.customer_city
ORDER BY revenue DESC
LIMIT 10;

-- Order volume by state (all states)
SELECT
    c.customer_state,
    COUNT(*) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;

-- Order volume by city (top 20)
SELECT
    c.customer_city,
    COUNT(*) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_city
ORDER BY total_orders DESC
LIMIT 20;


-- =============================================================
-- SECTION 7 : PRODUCT & CATEGORY ANALYSIS
-- =============================================================

-- Top 10 categories by quantity sold
SELECT
    p.product_category_name,
    COUNT(*) AS qty_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY qty_sold DESC
LIMIT 10;

-- Top 10 categories by revenue
SELECT
    p.product_category_name,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;

-- Top 10 categories by average price  (premium segment indicator)
SELECT
    p.product_category_name,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY avg_price DESC
LIMIT 10;


-- =============================================================
-- SECTION 8 : SELLER ANALYSIS
-- =============================================================

-- Top 10 sellers by order volume
SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM order_items
GROUP BY seller_id
ORDER BY total_orders DESC
LIMIT 10;

-- Top 10 sellers by revenue
SELECT
    seller_id,
    ROUND(SUM(price), 2) AS revenue
FROM order_items
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10;

-- Top 10 sellers by average item price  (premium sellers)
SELECT
    seller_id,
    ROUND(AVG(price), 2) AS avg_item_price
FROM order_items
GROUP BY seller_id
ORDER BY avg_item_price DESC
LIMIT 10;


-- =============================================================
-- SECTION 9 : DELIVERY PERFORMANCE ANALYSIS
-- =============================================================

-- Average end-to-end delivery time (purchase → customer receipt)
SELECT
    ROUND(
        AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)),
        2
    ) AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered';

-- Average delay vs estimated date
-- Negative = early delivery (good); Positive = late delivery (bad)
SELECT
    ROUND(
        AVG(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)),
        2
    ) AS avg_delay_days
FROM orders
WHERE order_status = 'delivered';

-- Count of late deliveries
SELECT COUNT(*) AS late_orders
FROM orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;

-- On-time delivery rate (%)
SELECT
    ROUND(
        100 * SUM(
            CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date
                 THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS on_time_pct
FROM orders
WHERE order_status = 'delivered';


-- =============================================================
-- SECTION 10 : PAYMENT ANALYSIS
-- =============================================================

-- Most used payment methods
SELECT
    payment_type,
    COUNT(*) AS total_transactions
FROM payments
GROUP BY payment_type
ORDER BY total_transactions DESC;

-- Revenue contribution by payment method
SELECT
    payment_type,
    ROUND(SUM(payment_value), 2) AS revenue
FROM payments
GROUP BY payment_type
ORDER BY revenue DESC;

-- Installment plan distribution  (how customers split payments)
SELECT
    payment_installments,
    COUNT(*) AS total_transactions
FROM payments
GROUP BY payment_installments
ORDER BY payment_installments;


-- =============================================================
-- SECTION 11 : CUSTOMER BEHAVIOUR ANALYSIS
-- =============================================================

-- Number of repeat customers  (placed more than one order)
SELECT COUNT(*) AS repeat_customers
FROM (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) AS repeat_buyers;

-- Repeat purchase rate (%)
SELECT
    ROUND(
        100 * COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_id END)
            / COUNT(DISTINCT customer_id),
        2
    ) AS repeat_rate_pct
FROM (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
) AS order_counts;

-- Most active customers by order volume
SELECT
    customer_id,
    COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC
LIMIT 10;


-- =============================================================
-- SECTION 12 : BASKET ANALYSIS
-- =============================================================

-- Average basket (order) value
SELECT
    ROUND(SUM(payment_value) / COUNT(DISTINCT order_id), 2) AS avg_basket_value
FROM payments;

-- Average items per basket
SELECT
    ROUND(COUNT(*) / COUNT(DISTINCT order_id), 2) AS avg_items_per_basket
FROM order_items;

-- Largest baskets by item count
SELECT
    order_id,
    COUNT(*) AS item_count
FROM order_items
GROUP BY order_id
ORDER BY item_count DESC
LIMIT 20;


-- =============================================================
-- SECTION 13 : RFM TABLE  (Recency · Frequency · Monetary)
-- =============================================================

DROP TABLE IF EXISTS rfm;

-- Build the RFM base table — one row per customer.
CREATE TABLE rfm AS
SELECT
    o.customer_id,
    MAX(o.order_purchase_timestamp)  AS last_purchase_date,   -- Recency proxy
    COUNT(DISTINCT o.order_id)       AS frequency,             -- F
    ROUND(SUM(p.payment_value), 2)   AS monetary               -- M
FROM orders   o
JOIN payments p ON o.order_id = p.order_id
GROUP BY o.customer_id;

SELECT * FROM rfm LIMIT 20;


-- =============================================================
-- SECTION 14 : CUSTOMER SEGMENTATION  (based on RFM monetary)
-- =============================================================

-- Spend-based segments
SELECT
    customer_id,
    frequency,
    monetary,
    CASE
        WHEN monetary >= 1000 THEN 'High Value'
        WHEN monetary >=  500 THEN 'Medium Value'
        ELSE                       'Low Value'
    END AS customer_segment
FROM rfm
ORDER BY monetary DESC;

-- Top 100 customers by lifetime spend
SELECT customer_id, monetary AS lifetime_spend
FROM rfm
ORDER BY lifetime_spend DESC
LIMIT 100;

-- Top 100 customers by order frequency
SELECT customer_id, frequency
FROM rfm
ORDER BY frequency DESC
LIMIT 100;


-- =============================================================
-- SECTION 15 : CUSTOMER LIFETIME VALUE  (CLV)
-- =============================================================

-- Individual CLV
SELECT
    o.customer_id,
    ROUND(SUM(p.payment_value), 2) AS clv
FROM orders   o
JOIN payments p ON o.order_id = p.order_id
GROUP BY o.customer_id
ORDER BY clv DESC
LIMIT 100;

-- Platform-wide average CLV
SELECT ROUND(AVG(customer_value), 2) AS avg_clv
FROM (
    SELECT
        o.customer_id,
        SUM(p.payment_value) AS customer_value
    FROM orders   o
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY o.customer_id
) AS clv_per_customer;


-- =============================================================
-- SECTION 16 : ADVANCED ANALYTICS — WINDOW FUNCTIONS
-- =============================================================

-- Rank all orders by payment value  (highest spend first)
SELECT
    order_id,
    payment_value,
    RANK() OVER (ORDER BY payment_value DESC) AS revenue_rank
FROM payments;

-- Dense-rank sellers by total revenue
SELECT
    seller_id,
    ROUND(SUM(price), 2)                               AS revenue,
    DENSE_RANK() OVER (ORDER BY SUM(price) DESC)       AS seller_rank
FROM order_items
GROUP BY seller_id;

-- Segment customers into 4 quartiles by monetary spend
-- Quartile 1 = top spenders, Quartile 4 = lowest spenders
SELECT
    customer_id,
    frequency,
    monetary,
    NTILE(4) OVER (ORDER BY monetary DESC) AS spend_quartile
FROM rfm;


-- =============================================================
-- SECTION 17 : VIEWS  (reusable query definitions)
-- =============================================================

-- Monthly revenue  (used in dashboards & trend charts)
CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
    YEAR(o.order_purchase_timestamp)  AS yr,
    MONTH(o.order_purchase_timestamp) AS mo,
    ROUND(SUM(p.payment_value), 2)    AS revenue
FROM orders   o
JOIN payments p ON o.order_id = p.order_id
GROUP BY yr, mo;

-- Category revenue leaderboard
CREATE OR REPLACE VIEW vw_top_categories AS
SELECT
    p.product_category_name,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name;

-- Revenue by state  (used for geo maps)
CREATE OR REPLACE VIEW vw_state_revenue AS
SELECT
    c.customer_state,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM customers c
JOIN orders   o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id    = p.order_id
GROUP BY c.customer_state;


-- =============================================================
-- SECTION 18 : STORED PROCEDURE
-- =============================================================

DELIMITER //

-- Returns state-wise revenue sorted by highest earner.
CREATE PROCEDURE get_state_revenue()
BEGIN
    SELECT
        c.customer_state,
        ROUND(SUM(p.payment_value), 2) AS revenue
    FROM customers c
    JOIN orders   o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id    = p.order_id
    GROUP BY c.customer_state
    ORDER BY revenue DESC;
END //

DELIMITER ;

CALL get_state_revenue();


-- =============================================================
-- SECTION 19 : COHORT RETENTION ANALYSIS
-- =============================================================

-- Step 1 : Identify each customer's acquisition month
CREATE OR REPLACE VIEW vw_customer_cohort AS
SELECT
    customer_id,
    MIN(DATE_FORMAT(order_purchase_timestamp, '%Y-%m-01')) AS cohort_month
FROM orders
GROUP BY customer_id;

-- Step 2 : Record every month a customer was active
CREATE OR REPLACE VIEW vw_customer_activity AS
SELECT
    customer_id,
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m-01') AS activity_month
FROM orders;

-- Step 3 : Build retention grid  (cohort × activity month)
SELECT
    cc.cohort_month,
    ca.activity_month,
    COUNT(DISTINCT ca.customer_id) AS active_customers
FROM vw_customer_cohort   cc
JOIN vw_customer_activity ca ON cc.customer_id = ca.customer_id
GROUP BY cc.cohort_month, ca.activity_month
ORDER BY cc.cohort_month, ca.activity_month;

