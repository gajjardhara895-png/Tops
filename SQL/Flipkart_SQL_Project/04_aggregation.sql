-- 04_aggregation.sql
-- Topics: COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING (Business Summary Report)

USE flipkart_db;

-- Product distribution by category
SELECT category, COUNT(*) AS total_products
FROM products
GROUP BY category;

-- Average price per category
SELECT category, ROUND(AVG(price), 2) AS avg_price
FROM products
GROUP BY category;

-- Orders per payment method
SELECT payment_method, COUNT(*) AS total_orders
FROM orders
GROUP BY payment_method;

-- Delivered orders per payment method (WHERE filters rows before grouping)
SELECT payment_method, COUNT(*) AS delivered_orders
FROM orders
WHERE status = 'Delivered'
GROUP BY payment_method;

-- Categories with more than 1 product (HAVING filters groups after grouping)
SELECT category, COUNT(*) AS total_products
FROM products
GROUP BY category
HAVING COUNT(*) > 1;

-- Payment methods with more than 2 orders
SELECT payment_method, COUNT(*) AS total_orders
FROM orders
GROUP BY payment_method
HAVING COUNT(*) > 2;

-- Most used payment method
SELECT payment_method, COUNT(*) AS used_times
FROM orders
GROUP BY payment_method
ORDER BY used_times DESC
LIMIT 1;

-- Categories with high average price
SELECT category, ROUND(AVG(price), 2) AS avg_price
FROM products
GROUP BY category
HAVING AVG(price) > 10000
ORDER BY avg_price DESC;

-- Revenue by status
SELECT status, COUNT(*) AS orders, SUM(amount) AS revenue
FROM orders
GROUP BY status;

-- Overall totals
SELECT COUNT(*) AS total_orders, SUM(amount) AS total_revenue,
       MIN(amount) AS min_order, MAX(amount) AS max_order,
       ROUND(AVG(amount), 2) AS avg_order
FROM orders;
