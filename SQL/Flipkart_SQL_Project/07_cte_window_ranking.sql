-- 07_cte_window_ranking.sql
-- Topics: CTE, multiple CTEs, recursive CTE, window functions,
--         ROW_NUMBER, RANK, DENSE_RANK, Top-N per group, LAG

USE flipkart_db;

-- Part A: CTEs

WITH delivered AS (SELECT * FROM orders WHERE status = 'Delivered')
SELECT * FROM delivered;

WITH delivered AS (SELECT * FROM orders WHERE status = 'Delivered')
SELECT COUNT(*) AS delivered_orders FROM delivered;

WITH pm AS (SELECT payment_method, COUNT(*) AS cnt FROM orders GROUP BY payment_method)
SELECT * FROM pm ORDER BY cnt DESC;

WITH oc AS (SELECT customer_id, COUNT(*) AS order_count FROM orders GROUP BY customer_id)
SELECT c.name, COALESCE(oc.order_count, 0) AS order_count
FROM customers c LEFT JOIN oc ON c.customer_id = oc.customer_id;

WITH avg_p AS (SELECT AVG(price) AS avg_price FROM products)
SELECT p.* FROM products p, avg_p WHERE p.price > avg_p.avg_price;

WITH d AS (SELECT delivery_days FROM deliveries WHERE delivery_status = 'Delivered')
SELECT ROUND(AVG(delivery_days), 2) AS avg_delivery_days FROM d;

-- Multiple CTEs in one query
WITH delivered AS (SELECT * FROM orders WHERE status = 'Delivered'),
     cancelled AS (SELECT * FROM orders WHERE status = 'Cancelled')
SELECT (SELECT COUNT(*) FROM delivered) AS delivered_cnt,
       (SELECT COUNT(*) FROM cancelled) AS cancelled_cnt;

-- Replace a subquery using a CTE
WITH cat_avg AS (SELECT category, AVG(price) AS avg_price FROM products GROUP BY category)
SELECT p.product_name, p.price, ROUND(c.avg_price, 2) AS category_avg
FROM products p JOIN cat_avg c ON p.category = c.category
WHERE p.price > c.avg_price;

-- Join inside a CTE
WITH cust_orders AS (
    SELECT c.customer_id, c.name, o.order_id, o.amount
    FROM customers c JOIN orders o ON c.customer_id = o.customer_id)
SELECT name, SUM(amount) AS total_spent FROM cust_orders GROUP BY customer_id, name
ORDER BY total_spent DESC;

-- KPI report using CTE
WITH total_cust AS (SELECT COUNT(*) AS cnt FROM customers),
     total_ord  AS (SELECT COUNT(*) AS cnt FROM orders),
     deliv_ord  AS (SELECT COUNT(*) AS cnt FROM orders WHERE status = 'Delivered')
SELECT total_cust.cnt AS total_customers,
       total_ord.cnt  AS total_orders,
       deliv_ord.cnt  AS delivered_orders
FROM total_cust, total_ord, deliv_ord;

-- Recursive CTE: numbers 1 to 10
WITH RECURSIVE nums AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM nums WHERE n < 10)
SELECT * FROM nums;

-- Mini Project: Flipkart KPI Layer
WITH c AS (SELECT COUNT(*) AS total_customers FROM customers),
     o AS (SELECT COUNT(*) AS total_orders FROM orders),
     d AS (SELECT COUNT(*) AS delivered_orders FROM orders WHERE status = 'Delivered'),
     a AS (SELECT ROUND(AVG(delivery_days), 2) AS avg_delivery_days FROM deliveries)
SELECT * FROM c, o, d, a;

-- Mini Project: Customer Activity Segmentation
WITH oc AS (SELECT customer_id, COUNT(*) AS order_count FROM orders GROUP BY customer_id)
SELECT c.customer_id, TRIM(c.name) AS name,
       COALESCE(oc.order_count, 0) AS order_count,
       CASE WHEN oc.order_count IS NULL THEN 'Without Orders' ELSE 'With Orders' END AS segment
FROM customers c LEFT JOIN oc ON c.customer_id = oc.customer_id;

-- Mini Project: Product Price Benchmark
WITH bench AS (SELECT category, ROUND(AVG(price), 2) AS category_avg FROM products GROUP BY category)
SELECT p.product_name, p.category, p.price, b.category_avg,
       p.price > b.category_avg AS above_benchmark
FROM products p JOIN bench b ON p.category = b.category;

-- Mini Project: Delivery Performance Report
WITH del AS (SELECT * FROM deliveries WHERE delivery_status = 'Delivered')
SELECT delivery_partner,
       COUNT(*) AS delivered_orders,
       ROUND(AVG(delivery_days), 2) AS avg_days,
       CASE WHEN AVG(delivery_days) <= 3 THEN 'Fast' ELSE 'Slow' END AS classification
FROM del GROUP BY delivery_partner;

-- Part B: Window functions

SELECT product_name, price, ROUND(AVG(price) OVER (), 2) AS avg_price FROM products;

SELECT product_name, category, price,
       ROUND(AVG(price) OVER (PARTITION BY category), 2) AS category_avg,
       COUNT(*) OVER (PARTITION BY category)              AS products_in_category
FROM products;

-- Total orders per customer shown on every row
SELECT order_id, customer_id,
       COUNT(*) OVER (PARTITION BY customer_id) AS customer_total_orders
FROM orders;

-- Price vs category average
SELECT product_name, category, price,
       ROUND(price - AVG(price) OVER (PARTITION BY category), 2) AS diff_from_avg
FROM products;

-- Average delivery days per partner (row level)
SELECT delivery_id, delivery_partner, delivery_days,
       ROUND(AVG(delivery_days) OVER (PARTITION BY delivery_partner), 2) AS partner_avg
FROM deliveries;

-- Category stock value
SELECT product_name, category, price, stock,
       SUM(price * stock) OVER (PARTITION BY category) AS category_stock_value
FROM products;

-- Window function with JOIN
SELECT c.name, o.order_id, o.amount,
       SUM(o.amount) OVER (PARTITION BY c.customer_id) AS customer_total
FROM orders o JOIN customers c ON c.customer_id = o.customer_id;

-- Filter on window output (wrap it, WHERE cannot see window functions)
SELECT * FROM (
    SELECT product_name, category, price,
           AVG(price) OVER (PARTITION BY category) AS cat_avg
    FROM products) t
WHERE price > cat_avg;

-- GROUP BY (collapses rows) vs window function (keeps rows)
SELECT category, ROUND(AVG(price), 2) FROM products GROUP BY category;
SELECT product_name, category, ROUND(AVG(price) OVER (PARTITION BY category), 2) FROM products;

-- Inventory analytics
SELECT product_name, category, stock, price,
       SUM(stock) OVER (PARTITION BY category) AS category_stock,
       ROUND(stock * 100 / SUM(stock) OVER (PARTITION BY category), 2) AS stock_share_pct,
       price * stock AS stock_value
FROM products;

-- Mini Project: Customer Order Strength (repeat customers)
SELECT customer_id, order_id,
       COUNT(*) OVER (PARTITION BY customer_id) AS order_count,
       CASE WHEN COUNT(*) OVER (PARTITION BY customer_id) > 1 THEN 'Repeat' ELSE 'One-time' END AS customer_type
FROM orders;

-- Part C: Ranking functions

SELECT product_name, price,
       ROW_NUMBER() OVER (ORDER BY price DESC) AS row_num,
       RANK()       OVER (ORDER BY price DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY price DESC) AS dense_rnk
FROM products;

-- Rank products per category
SELECT product_name, category, price,
       RANK() OVER (PARTITION BY category ORDER BY price DESC) AS rnk
FROM products;

-- Top 3 products per category (Category Leaderboard)
WITH ranked AS (
    SELECT product_name, category, price,
           DENSE_RANK() OVER (PARTITION BY category ORDER BY price DESC) AS rnk
    FROM products)
SELECT * FROM ranked WHERE rnk <= 3;

-- Rank customers by order count (Customer Power Users)
SELECT c.name, COUNT(*) AS order_count,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
FROM orders o JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- Rank deliveries by speed
SELECT delivery_id, delivery_partner, delivery_days,
       RANK() OVER (ORDER BY delivery_days ASC) AS speed_rank
FROM deliveries
WHERE delivery_days IS NOT NULL;

-- Fastest delivery partners
SELECT delivery_partner, ROUND(AVG(delivery_days), 2) AS avg_days,
       RANK() OVER (ORDER BY AVG(delivery_days)) AS partner_rank
FROM deliveries GROUP BY delivery_partner;

-- Spending leaderboard (ranking with JOIN)
SELECT DENSE_RANK() OVER (ORDER BY SUM(o.amount) DESC) AS position,
       c.name, SUM(o.amount) AS total_spent
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;
