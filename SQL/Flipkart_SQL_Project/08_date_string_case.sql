-- 08_date_string_case.sql
-- Topics: date functions, string functions, CASE WHEN, segmentation

USE flipkart_db;

-- Part A: Date functions

SELECT order_id, YEAR(order_date)  AS order_year  FROM orders;
SELECT order_id, MONTH(order_date) AS order_month FROM orders;
SELECT CURDATE() AS today, NOW() AS current_datetime;
SELECT order_id, DATE_ADD(order_date, INTERVAL 10 DAY) AS plus_10_days FROM orders;

SELECT * FROM orders WHERE order_date >= CURDATE() - INTERVAL 15 DAY;      -- last 15 days
SELECT * FROM orders WHERE order_date >= CURDATE() - INTERVAL 30 DAY;      -- last 30 days

SELECT order_id, order_date, DATEDIFF(CURDATE(), order_date) AS days_since_order FROM orders;

-- Orders per month (group year and month together)
SELECT YEAR(order_date) AS yr, MONTH(order_date) AS mth, COUNT(*) AS total_orders
FROM orders GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY yr, mth;

SELECT MIN(order_date) AS oldest_order, MAX(order_date) AS latest_order FROM orders;
SELECT ROUND(AVG(delivery_days), 2) AS avg_delivery_days FROM deliveries;

SELECT * FROM orders WHERE MONTH(order_date) = 1;                          -- January orders

-- Orders placed this year (index-friendly range instead of YEAR())
SELECT * FROM orders
WHERE order_date >= MAKEDATE(YEAR(CURDATE()), 1)
  AND order_date <  MAKEDATE(YEAR(CURDATE()) + 1, 1);

-- Mini Project: Monthly Order Dashboard (orders, sales, growth trend)
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS ym,
           COUNT(*) AS total_orders, SUM(amount) AS sales
    FROM orders GROUP BY DATE_FORMAT(order_date, '%Y-%m'))
SELECT ym, total_orders, sales,
       LAG(sales) OVER (ORDER BY ym) AS prev_month_sales,
       ROUND((sales - LAG(sales) OVER (ORDER BY ym)) * 100
             / LAG(sales) OVER (ORDER BY ym), 2) AS growth_pct
FROM monthly ORDER BY ym;

-- Latest month sales
SELECT DATE_FORMAT(order_date, '%Y-%m') AS ym, SUM(amount) AS sales
FROM orders GROUP BY ym ORDER BY ym DESC LIMIT 1;

-- Mini Project: Delivery SLA Report
SELECT delivery_id, order_id, delivery_days,
       CASE WHEN delivery_days <= 2 THEN 'Fast'
            WHEN delivery_days <= 5 THEN 'Normal'
            ELSE 'Slow' END AS speed_class,
       CASE WHEN delivery_days > 5 THEN 'Delayed' ELSE 'On Time' END AS delay_class
FROM deliveries
WHERE delivery_days IS NOT NULL;

-- Mini Project: Customer Recency Analysis
SELECT c.customer_id, TRIM(c.name) AS name,
       MAX(o.order_date) AS last_order,
       DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order,
       CASE WHEN MAX(o.order_date) >= CURDATE() - INTERVAL 90 DAY THEN 'Active'
            ELSE 'Inactive' END AS status
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- Part B: String functions

SELECT CONCAT(name, ' - ', email) AS name_email FROM customers;
SELECT UPPER(product_name) AS product_name_upper FROM products;
SELECT product_name, LEFT(product_name, 4)  AS first_4 FROM products;
SELECT product_name, RIGHT(product_name, 3) AS last_3  FROM products;
SELECT payment_method, REPLACE(payment_method, 'COD', 'Cash') AS payment_clean FROM orders;
SELECT name, TRIM(name) AS trimmed_name, LENGTH(name) AS len_before, LENGTH(TRIM(name)) AS len_after FROM customers;
SELECT seller_name, LENGTH(seller_name) AS name_length FROM sellers;
SELECT email, SUBSTRING_INDEX(email, '@', -1) AS email_domain FROM customers;
SELECT product_name, UPPER(LEFT(product_name, 3)) AS short_code FROM products;
SELECT CONCAT(category, ' - Rs.', price) AS category_price FROM products;
SELECT DISTINCT LOWER(payment_method) AS payment_lower FROM orders;

-- Format name properly (Proper Case)
SELECT CONCAT(UPPER(LEFT(TRIM(name), 1)), LOWER(SUBSTRING(TRIM(name), 2))) AS proper_name
FROM customers;

-- Mini Project: Customer Data Cleaning
SELECT customer_id,
       name AS raw_name,
       CONCAT(UPPER(LEFT(TRIM(name), 1)), LOWER(SUBSTRING(TRIM(name), 2))) AS clean_name,
       LOWER(TRIM(email)) AS clean_email,
       SUBSTRING_INDEX(LOWER(TRIM(email)), '@', -1) AS email_domain
FROM customers;

-- Mini Project: Product Code Generator (first 3 letters + price)
SELECT product_name, price,
       CONCAT(UPPER(LEFT(product_name, 3)), CAST(price AS UNSIGNED)) AS product_code
FROM products;

-- Mini Project: Marketing Segmentation (group by email domain)
SELECT SUBSTRING_INDEX(email, '@', -1) AS email_domain, COUNT(*) AS users
FROM customers GROUP BY email_domain ORDER BY users DESC;

SELECT SUBSTRING_INDEX(email, '@', -1) AS top_domain, COUNT(*) AS users
FROM customers GROUP BY top_domain ORDER BY users DESC LIMIT 1;

-- Part C: CASE WHEN

-- Classify products by price
SELECT product_name, price,
       CASE WHEN price < 1000  THEN 'Low'
            WHEN price < 10000 THEN 'Medium'
            ELSE 'High' END AS price_class
FROM products;

-- Segment customers by order count (Customer Segmentation Engine)
SELECT TRIM(c.name) AS name, COUNT(o.order_id) AS orders,
       CASE WHEN COUNT(o.order_id) = 0 THEN 'Inactive'
            WHEN COUNT(o.order_id) <= 2 THEN 'Occasional'
            ELSE 'Frequent' END AS segment
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- Segment summary report
WITH seg AS (
    SELECT c.customer_id,
           CASE WHEN COUNT(o.order_id) = 0 THEN 'Inactive'
                WHEN COUNT(o.order_id) <= 2 THEN 'Occasional'
                ELSE 'Frequent' END AS segment
    FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id)
SELECT segment, COUNT(*) AS customers FROM seg GROUP BY segment;

-- Fast / slow deliveries
SELECT delivery_id, delivery_days,
       CASE WHEN delivery_days <= 3 THEN 'Fast' ELSE 'Slow' END AS speed
FROM deliveries WHERE delivery_days IS NOT NULL;

-- Delivered vs non-delivered (CASE inside aggregate)
SELECT SUM(CASE WHEN status = 'Delivered'  THEN 1 ELSE 0 END) AS delivered,
       SUM(CASE WHEN status <> 'Delivered' THEN 1 ELSE 0 END) AS not_delivered
FROM orders;

-- Categorize sellers by rating
SELECT seller_name, rating,
       CASE WHEN rating >= 4.5 THEN 'Excellent'
            WHEN rating >= 3.5 THEN 'Good'
            ELSE 'Needs Improvement' END AS seller_category
FROM sellers;

-- Inventory status / risk monitoring
SELECT product_name, stock,
       CASE WHEN stock = 0  THEN 'Out of Stock'
            WHEN stock < 10 THEN 'Low Stock'
            ELSE 'In Stock' END AS inventory_status
FROM products;

SELECT p.product_name, p.stock, COUNT(o.order_id) AS times_ordered
FROM products p JOIN orders o ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.stock
HAVING COUNT(o.order_id) >= 2 AND p.stock < 30;               -- high demand, low stock

-- CASE in ORDER BY (Delivered first, Pending next, then the rest)
SELECT * FROM orders
ORDER BY CASE status WHEN 'Delivered' THEN 1 WHEN 'Pending' THEN 2 ELSE 3 END, order_date DESC;

-- CASE with window function
SELECT product_name, category, price,
       CASE WHEN price > AVG(price) OVER (PARTITION BY category)
            THEN 'Above Avg' ELSE 'Below Avg' END AS vs_category
FROM products;

-- Segment orders by payment type; revenue bands
SELECT order_id, payment_method,
       CASE WHEN payment_method = 'COD' THEN 'Offline' ELSE 'Online' END AS payment_type,
       CASE WHEN amount < 1000  THEN 'Band A (<1k)'
            WHEN amount < 10000 THEN 'Band B (1k-10k)'
            ELSE 'Band C (10k+)' END AS revenue_band
FROM orders;

-- Nested CASE
SELECT product_name, price, stock,
       CASE WHEN stock = 0 THEN 'Unavailable'
            ELSE CASE WHEN price > 10000 THEN 'Premium Available'
                      ELSE 'Regular Available' END
       END AS availability_label
FROM products;

-- Classify customers by email domain
SELECT TRIM(name) AS name, email,
       CASE WHEN email LIKE '%@gmail.com'   THEN 'Gmail'
            WHEN email LIKE '%@yahoo.com'   THEN 'Yahoo'
            WHEN email LIKE '%@outlook.com' OR email LIKE '%@hotmail.com' THEN 'Microsoft'
            ELSE 'Other' END AS domain_type
FROM customers;

-- Mini Project: Product Price Intelligence (tier + vs category average)
SELECT product_name, category, price,
       CASE WHEN price < 1000 THEN 'Low' WHEN price < 10000 THEN 'Medium' ELSE 'High' END AS price_tier,
       CASE WHEN price > AVG(price) OVER (PARTITION BY category) THEN 'Above Category Avg'
            ELSE 'At/Below Category Avg' END AS vs_category
FROM products;

-- Mini Project: Delivery Performance Scorecard
SELECT delivery_partner,
       ROUND(AVG(delivery_days), 2) AS avg_days,
       CASE WHEN AVG(delivery_days) <= 3 THEN 'Excellent'
            WHEN AVG(delivery_days) <= 5 THEN 'Good'
            ELSE 'Poor' END AS performance,
       RANK() OVER (ORDER BY AVG(delivery_days)) AS rank_no
FROM deliveries WHERE delivery_days IS NOT NULL
GROUP BY delivery_partner;
