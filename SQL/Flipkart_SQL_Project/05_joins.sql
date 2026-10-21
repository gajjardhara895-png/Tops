-- 05_joins.sql
-- Topics: INNER, LEFT, RIGHT, FULL (simulated), SELF, CROSS joins,
--         orphan records, Data Quality Audit, Customer Coverage Report

USE flipkart_db;

-- Customers with their orders
SELECT c.customer_id, c.name, o.order_id, o.order_date, o.amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

-- Products with seller details
SELECT p.product_name, p.price, s.seller_name, s.rating
FROM products p
JOIN sellers s ON p.seller_id = s.seller_id;

-- Order delivery details
SELECT o.order_id, o.order_date, d.delivery_partner, d.delivery_days, d.delivery_status
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id;

-- Count orders per customer (LEFT JOIN keeps customers with 0 orders)
SELECT c.customer_id, c.name, COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- Customers with no orders
SELECT c.customer_id, c.name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Products without reviews
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
WHERE r.review_id IS NULL;

-- Orders without delivery
SELECT o.*
FROM orders o
LEFT JOIN deliveries d ON o.order_id = d.order_id
WHERE d.delivery_id IS NULL;

-- Delivery records without orders (orphans)
SELECT d.*
FROM deliveries d
LEFT JOIN orders o ON d.order_id = o.order_id
WHERE o.order_id IS NULL;

-- FULL OUTER JOIN simulated in MySQL: LEFT JOIN UNION RIGHT JOIN
SELECT c.customer_id, c.name, o.order_id, o.amount
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
UNION
SELECT c.customer_id, c.name, o.order_id, o.amount
FROM customers c RIGHT JOIN orders o ON c.customer_id = o.customer_id;

-- Replace RIGHT JOIN with LEFT JOIN (swap the table order)
SELECT c.name, o.order_id FROM customers c RIGHT JOIN orders o ON c.customer_id = o.customer_id;
SELECT c.name, o.order_id FROM orders o LEFT JOIN customers c ON c.customer_id = o.customer_id;

-- SELF JOIN: compare products in the same category
SELECT p1.product_name AS product_1, p2.product_name AS product_2,
       p1.category, p1.price AS price_1, p2.price AS price_2
FROM products p1
JOIN products p2 ON p1.category = p2.category AND p1.product_id < p2.product_id;

-- SELF JOIN: customer city comparison (pairs in the same city)
SELECT c1.name AS customer_1, c2.name AS customer_2, c1.city
FROM customers c1
JOIN customers c2 ON c1.city = c2.city AND c1.customer_id < c2.customer_id;

-- CROSS JOIN: product x seller combinations
SELECT p.product_name, s.seller_name
FROM products p CROSS JOIN sellers s;

-- CROSS JOIN output count (rows in A x rows in B)
SELECT (SELECT COUNT(*) FROM products) * (SELECT COUNT(*) FROM sellers) AS expected_rows,
       COUNT(*) AS actual_rows
FROM products CROSS JOIN sellers;

-- Count unmatched rows in a JOIN
SELECT COUNT(*) AS customers_without_orders
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Orphan orders (customer does not exist)
SELECT o.*
FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Mini Project: Data Quality Audit
SELECT 'Orders without delivery' AS issue, COUNT(*) AS cnt
FROM orders o LEFT JOIN deliveries d ON o.order_id = d.order_id WHERE d.delivery_id IS NULL
UNION ALL
SELECT 'Deliveries without order', COUNT(*)
FROM deliveries d LEFT JOIN orders o ON d.order_id = o.order_id WHERE o.order_id IS NULL
UNION ALL
SELECT 'Products without reviews', COUNT(*)
FROM products p LEFT JOIN reviews r ON p.product_id = r.product_id WHERE r.review_id IS NULL;

-- Mini Project: Customer Coverage Report
SELECT COUNT(*)                                     AS total_customers,
       SUM(order_cnt > 0)                           AS customers_with_orders,
       SUM(order_cnt = 0)                           AS customers_without_orders,
       ROUND(SUM(order_cnt > 0) * 100 / COUNT(*), 2) AS conversion_pct
FROM (
    SELECT c.customer_id, COUNT(o.order_id) AS order_cnt
    FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
) t;
