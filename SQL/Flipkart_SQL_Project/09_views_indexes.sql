-- 09_views_indexes.sql
-- Topics: views, reporting layer, secure views, indexes, EXPLAIN, optimization

USE flipkart_db;

-- Part A: Views

DROP VIEW IF EXISTS vw_customer_summary, vw_delivered_orders, vw_product_performance,
    vw_customers_public, vw_order_details, vw_category_summary,
    vw_delivery_performance, vw_executive_dashboard, vw_reporting_public, vw_kpi;

CREATE VIEW vw_customer_summary AS
SELECT c.customer_id, TRIM(c.name) AS name, c.city,
       COUNT(o.order_id)          AS total_orders,
       COALESCE(SUM(o.amount), 0) AS total_spent
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city;

CREATE VIEW vw_delivered_orders AS
SELECT * FROM orders WHERE status = 'Delivered';

CREATE VIEW vw_product_performance AS
SELECT p.product_id, p.product_name, p.category, p.price,
       COUNT(o.order_id)          AS times_ordered,
       COALESCE(SUM(o.amount), 0) AS revenue
FROM products p LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price;

-- View that hides sensitive columns (no email or mobile)
CREATE VIEW vw_customers_public AS
SELECT customer_id, TRIM(name) AS name, city FROM customers;

-- View using JOIN
CREATE VIEW vw_order_details AS
SELECT o.order_id, TRIM(c.name) AS customer, p.product_name, o.amount, o.order_date
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN products  p ON p.product_id  = o.product_id;

-- View using GROUP BY
CREATE VIEW vw_category_summary AS
SELECT category, COUNT(*) AS products, ROUND(AVG(price), 2) AS avg_price
FROM products GROUP BY category;

-- Reporting layer: delivery performance
CREATE VIEW vw_delivery_performance AS
SELECT delivery_partner, COUNT(*) AS deliveries, ROUND(AVG(delivery_days), 2) AS avg_days
FROM deliveries GROUP BY delivery_partner;

-- Executive dashboard view: orders + customers + delivery info
CREATE VIEW vw_executive_dashboard AS
SELECT o.order_id, o.order_date, o.amount, o.status, o.payment_method,
       TRIM(c.name) AS customer_name, c.city,
       d.delivery_partner, d.delivery_days, d.delivery_status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN deliveries d ON d.order_id = o.order_id;

-- Secure public view for the reporting team
CREATE VIEW vw_reporting_public AS
SELECT o.order_id, o.order_date, o.amount, o.status, c.city
FROM orders o JOIN customers c ON c.customer_id = o.customer_id;
-- Optional access control:
-- CREATE USER 'report_user'@'%' IDENTIFIED BY 'ChangeMe123';
-- GRANT SELECT ON flipkart_db.vw_reporting_public TO 'report_user'@'%';

-- KPI view layer
CREATE VIEW vw_kpi AS
SELECT (SELECT COUNT(*) FROM orders)                                 AS total_orders,
       (SELECT COUNT(*) FROM orders WHERE status = 'Delivered')      AS delivered_orders,
       (SELECT ROUND(AVG(delivery_days), 2) FROM deliveries)         AS avg_delivery_days,
       (SELECT COUNT(*) FROM customers)                              AS total_customers;

-- Query from views
SELECT * FROM vw_customer_summary;
SELECT COUNT(*) AS rows_in_view FROM vw_customer_summary;
SELECT * FROM vw_customer_summary WHERE total_spent > 10000 ORDER BY total_spent DESC;
SELECT * FROM vw_kpi;

-- Modify a view
CREATE OR REPLACE VIEW vw_delivered_orders AS
SELECT order_id, customer_id, product_id, order_date, amount
FROM orders WHERE status = 'Delivered';

-- Drop a view
DROP VIEW IF EXISTS vw_category_summary;

-- Part B: Indexes and performance

DROP INDEX IF EXISTS idx_order_date     ON orders;
DROP INDEX IF EXISTS idx_customer_id    ON orders;
DROP INDEX IF EXISTS idx_cust_date      ON orders;
DROP INDEX IF EXISTS idx_orders_product ON orders;
DROP INDEX IF EXISTS idx_orders_status  ON orders;
DROP INDEX IF EXISTS idx_products_cat   ON products;
DROP INDEX IF EXISTS idx_deliv_order    ON deliveries;
DROP INDEX IF EXISTS idx_deliv_partner  ON deliveries;

-- Before indexing (look at type and key columns)
EXPLAIN SELECT * FROM orders WHERE order_date >= CURDATE() - INTERVAL 30 DAY;

CREATE INDEX idx_order_date  ON orders(order_date);
CREATE INDEX idx_customer_id ON orders(customer_id);
CREATE INDEX idx_cust_date   ON orders(customer_id, order_date);        -- composite index

-- After indexing
EXPLAIN SELECT * FROM orders WHERE order_date >= CURDATE() - INTERVAL 30 DAY;

-- Optimize date filtering: avoid functions on the indexed column
EXPLAIN SELECT * FROM orders WHERE YEAR(order_date) = 2026;                         -- cannot use index
EXPLAIN SELECT * FROM orders WHERE order_date >= '2026-01-01' AND order_date < '2027-01-01';  -- can use index

-- Identify a full table scan (leading % wildcard)
EXPLAIN SELECT * FROM products WHERE product_name LIKE '%Shirt%';

-- Optimize JOIN: index the foreign keys
CREATE INDEX idx_orders_product ON orders(product_id);
CREATE INDEX idx_deliv_order    ON deliveries(order_id);
EXPLAIN SELECT c.name, o.order_id FROM customers c JOIN orders o ON c.customer_id = o.customer_id;

-- ORDER BY performance
EXPLAIN SELECT * FROM orders ORDER BY order_date DESC LIMIT 10;

-- Index strategy for the three main tables
CREATE INDEX idx_orders_status   ON orders(status);
CREATE INDEX idx_products_cat    ON products(category, price);
CREATE INDEX idx_deliv_partner   ON deliveries(delivery_partner, delivery_status);

-- Show indexes, then remove a redundant one (idx_customer_id is covered by idx_cust_date)
SHOW INDEX FROM orders;
DROP INDEX idx_customer_id ON orders;
SHOW INDEX FROM orders;
