DROP DATABASE IF EXISTS flipkart_db;
CREATE DATABASE flipkart_db;
USE flipkart_db;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100),
    email       VARCHAR(100),
    mobile_no   VARCHAR(15),
    city        VARCHAR(50),
    address     VARCHAR(200)
);

CREATE TABLE sellers (
    seller_id   INT PRIMARY KEY AUTO_INCREMENT,
    seller_name VARCHAR(100),
    city        VARCHAR(50),
    rating      DECIMAL(2,1)
);

CREATE TABLE products (
    product_id   INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    category     VARCHAR(50),
    price        DECIMAL(10,2),
    stock        INT,
    seller_id    INT,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE orders (
    order_id       INT PRIMARY KEY AUTO_INCREMENT,
    customer_id    INT,
    product_id     INT,
    order_date     DATE,
    amount         DECIMAL(10,2),
    payment_method VARCHAR(20),          -- UPI, COD, Card ...
    status         VARCHAR(20),          -- Delivered, Cancelled, Pending ...
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id)  REFERENCES products(product_id)
);

CREATE TABLE deliveries (
    delivery_id      INT PRIMARY KEY AUTO_INCREMENT,
    order_id         INT,
    delivery_partner VARCHAR(50),        -- Ekart, Delhivery ...
    delivery_days    INT,
    delivery_status  VARCHAR(20)         -- Delivered, In Transit ...
);

CREATE TABLE reviews (
    review_id   INT PRIMARY KEY AUTO_INCREMENT,
    product_id  INT,
    customer_id INT,
    rating      INT,
    review_date DATE
);

--  1. SELECT BASICS + Project: Employee Reporting Queries
-- (employees table: emp_id, name, city, salary, department)

CREATE TABLE employees (
    emp_id     INT PRIMARY KEY,
    name       VARCHAR(100),
    city       VARCHAR(50),
    salary     DECIMAL(10,2),
    department VARCHAR(50)
);

-- Select only employee names
SELECT name FROM employees;

-- Select employee name and city
SELECT name, city FROM employees;

-- Rename salary column as monthly_income
SELECT name, salary AS monthly_income FROM employees;

-- Fetch department details only
SELECT DISTINCT department FROM employees;

-- Query with comments
-- Single-line comment
/* Multi-line comment:
   fetch name and salary of all employees */
SELECT name,    -- employee name
       salary   -- monthly salary
FROM employees;

-- Dashboard-friendly SELECT (clean aliases)
SELECT emp_id AS `Employee ID`,
       name   AS `Employee Name`,
       city   AS `City`,
       salary AS `Monthly Income`
FROM employees;

-- Project tasks
SELECT * FROM employees;                                  -- full data
SELECT name, salary FROM employees;                       -- name & salary
SELECT name AS Employee_Name, salary AS Monthly_Salary
FROM employees;                                           -- Excel export

/*
   2. LIKE / BETWEEN / IN + Project: Flipkart Search & Filter Engine
    */

-- Customers whose name starts with 'R'
SELECT * FROM customers WHERE name LIKE 'R%';

-- Products priced between 5000 and 20000 (BETWEEN is inclusive)
SELECT * FROM products WHERE price BETWEEN 5000 AND 20000;

-- Orders paid using UPI or COD
SELECT * FROM orders WHERE payment_method IN ('UPI', 'COD');

-- Deliveries handled by Ekart
SELECT * FROM deliveries WHERE delivery_partner = 'Ekart';

-- Products with word 'Shirt'
SELECT * FROM products WHERE product_name LIKE '%Shirt%';

-- Customers using gmail
SELECT * FROM customers WHERE email LIKE '%@gmail.com';

-- LIKE examples: % = any number of chars, _ = exactly one char
SELECT * FROM customers WHERE name LIKE 'R___';   -- 4-letter names starting with R

-- Date with BETWEEN
SELECT * FROM orders WHERE order_date BETWEEN '2025-01-01' AND '2025-01-31';

-- Project: identify fast deliveries
SELECT * FROM deliveries WHERE delivery_days <= 2;

-- Project: combine multiple filters
SELECT p.product_name, p.category, p.price
FROM products p
WHERE p.product_name LIKE '%Shirt%'
  AND p.price BETWEEN 500 AND 2000
  AND p.stock > 0;

SELECT o.*
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE c.name LIKE 'R%'
  AND o.payment_method IN ('UPI', 'COD')
  AND o.amount BETWEEN 1000 AND 20000;

/*
   3. DISTINCT / ORDER BY / LIMIT + Project: Top Products Dashboard
    */

-- Unique payment methods
SELECT DISTINCT payment_method FROM orders;

-- Unique product categories
SELECT DISTINCT category FROM products;

-- Top 5 expensive products
SELECT * FROM products ORDER BY price DESC LIMIT 5;

-- Latest 3 orders
SELECT * FROM orders ORDER BY order_date DESC LIMIT 3;

-- Sort sellers by rating
SELECT * FROM sellers ORDER BY rating DESC;

-- Cheapest 5 products
SELECT * FROM products ORDER BY price ASC LIMIT 5;

-- Dashboard: best-rated sellers
SELECT seller_name, rating FROM sellers ORDER BY rating DESC LIMIT 5;

/*
   4. GROUP BY / HAVING + Project: Business Summary Report
    */

-- Count products per category
SELECT category, COUNT(*) AS total_products
FROM products
GROUP BY category;

-- Avg price per category
SELECT category, ROUND(AVG(price), 2) AS avg_price
FROM products
GROUP BY category;

-- Orders per payment method
SELECT payment_method, COUNT(*) AS total_orders
FROM orders
GROUP BY payment_method;

-- Delivered orders per payment method
SELECT payment_method, COUNT(*) AS delivered_orders
FROM orders
WHERE status = 'Delivered'
GROUP BY payment_method;

-- Categories with more than 1 product
SELECT category, COUNT(*) AS total_products
FROM products
GROUP BY category
HAVING COUNT(*) > 1;

-- Payment methods with more than 2 orders
SELECT payment_method, COUNT(*) AS total_orders
FROM orders
GROUP BY payment_method
HAVING COUNT(*) > 2;

-- Project: most used payment method
SELECT payment_method, COUNT(*) AS used_times
FROM orders
GROUP BY payment_method
ORDER BY used_times DESC
LIMIT 1;

-- Project: categories with high average price
SELECT category, ROUND(AVG(price), 2) AS avg_price
FROM products
GROUP BY category
HAVING AVG(price) > 10000
ORDER BY avg_price DESC;

/*
   5. JOINS + Project: Flipkart Order Analytics
    */

-- List customers with their orders
SELECT c.customer_id, c.name, o.order_id, o.order_date, o.amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

-- Products with seller details
SELECT p.product_name, p.price, s.seller_name, s.rating
FROM products p
JOIN sellers s ON p.seller_id = s.seller_id;

-- Customers with no orders
SELECT c.customer_id, c.name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Order delivery details
SELECT o.order_id, o.order_date, d.delivery_partner, d.delivery_days, d.delivery_status
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id;

-- Products without reviews
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
WHERE r.review_id IS NULL;

-- Count orders per customer
SELECT c.customer_id, c.name, COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- Project: delivery performance report
SELECT d.delivery_partner,
       COUNT(*)                     AS total_deliveries,
       ROUND(AVG(d.delivery_days),2) AS avg_days
FROM deliveries d
GROUP BY d.delivery_partner
ORDER BY avg_days;

/*
   6. FULL / SELF / CROSS JOIN + Data Quality Mini Projects
    */

-- FULL OUTER JOIN simulated in MySQL (LEFT JOIN UNION RIGHT JOIN)
-- Show all customers & orders
SELECT c.customer_id, c.name, o.order_id, o.amount
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
UNION
SELECT c.customer_id, c.name, o.order_id, o.amount
FROM customers c RIGHT JOIN orders o ON c.customer_id = o.customer_id;

-- Customers without orders
SELECT c.* FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Orders without delivery
SELECT o.* FROM orders o
LEFT JOIN deliveries d ON o.order_id = d.order_id
WHERE d.delivery_id IS NULL;

-- Products without reviews
SELECT p.* FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
WHERE r.review_id IS NULL;

-- SELF JOIN: compare products in same category
SELECT p1.product_name AS product_1, p2.product_name AS product_2,
       p1.category, p1.price AS price_1, p2.price AS price_2
FROM products p1
JOIN products p2
  ON p1.category = p2.category
 AND p1.product_id < p2.product_id;

-- SELF JOIN: customer city comparison (customers in the same city)
SELECT c1.name AS customer_1, c2.name AS customer_2, c1.city
FROM customers c1
JOIN customers c2
  ON c1.city = c2.city
 AND c1.customer_id < c2.customer_id;

-- CROSS JOIN: product x seller combinations
SELECT p.product_name, s.seller_name
FROM products p CROSS JOIN sellers s;

-- CROSS JOIN output count (= rows in A * rows in B)
SELECT (SELECT COUNT(*) FROM products) * (SELECT COUNT(*) FROM sellers) AS expected_rows,
       COUNT(*) AS actual_rows
FROM products CROSS JOIN sellers;

-- Count unmatched rows in a JOIN (customers with no orders)
SELECT COUNT(*) AS unmatched_customers
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Delivery records without orders (orphans)
SELECT d.* FROM deliveries d
LEFT JOIN orders o ON d.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Replace RIGHT JOIN with LEFT JOIN (just swap table order)
-- RIGHT JOIN version:
SELECT c.name, o.order_id FROM customers c RIGHT JOIN orders o ON c.customer_id = o.customer_id;
-- Equivalent LEFT JOIN version:
SELECT c.name, o.order_id FROM orders o LEFT JOIN customers c ON c.customer_id = o.customer_id;

-- Identify orphan records (orders whose customer does not exist)
SELECT o.* FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Mini Project 1: Data Quality Audit
SELECT 'Orders without delivery' AS issue, COUNT(*) AS cnt
FROM orders o LEFT JOIN deliveries d ON o.order_id = d.order_id WHERE d.delivery_id IS NULL
UNION ALL
SELECT 'Deliveries without order', COUNT(*)
FROM deliveries d LEFT JOIN orders o ON d.order_id = o.order_id WHERE o.order_id IS NULL
UNION ALL
SELECT 'Products without reviews', COUNT(*)
FROM products p LEFT JOIN reviews r ON p.product_id = r.product_id WHERE r.review_id IS NULL;

-- Mini Project 2: Customer Coverage Report
SELECT COUNT(*) AS total_customers,
       SUM(order_cnt > 0)  AS customers_with_orders,
       SUM(order_cnt = 0)  AS customers_without_orders,
       ROUND(SUM(order_cnt > 0) * 100 / COUNT(*), 2) AS conversion_pct
FROM (
    SELECT c.customer_id, COUNT(o.order_id) AS order_cnt
    FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
) t;

/*
   7. UNION / UNION ALL
    */

-- Combine customer & seller names
SELECT name FROM customers
UNION
SELECT seller_name FROM sellers;

-- Combine delivered & cancelled orders
SELECT order_id, status FROM orders WHERE status = 'Delivered'
UNION ALL
SELECT order_id, status FROM orders WHERE status = 'Cancelled';

-- Activity log using orders + deliveries
SELECT order_id, order_date AS activity_date, 'Order Placed' AS activity FROM orders
UNION ALL
SELECT d.order_id, o.order_date, CONCAT('Delivery - ', d.delivery_status)
FROM deliveries d JOIN orders o ON o.order_id = d.order_id;

-- Customer count & order count in one result
SELECT 'Customers' AS metric, COUNT(*) AS total FROM customers
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders;

-- Sort UNION result alphabetically (ORDER BY goes at the very end)
SELECT name AS name FROM customers
UNION
SELECT seller_name FROM sellers
ORDER BY name;

-- Combine products & sellers names
SELECT product_name AS name, 'Product' AS type FROM products
UNION ALL
SELECT seller_name, 'Seller' FROM sellers;

-- Combined city list (customers + sellers)
SELECT city FROM customers
UNION
SELECT city FROM sellers;

-- Duplicates: UNION vs UNION ALL
SELECT city FROM customers UNION ALL SELECT city FROM sellers;  -- keeps duplicates
SELECT city FROM customers UNION     SELECT city FROM sellers;  -- removes duplicates

-- Mini Project: Flipkart User Directory
SELECT customer_id AS id, name, email, city, 'Customer' AS role FROM customers
UNION ALL
SELECT seller_id, seller_name, NULL, city, 'Seller' FROM sellers
ORDER BY role, name;

/*
   8. SUBQUERIES
    */

-- Products above average price
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Latest order details
SELECT * FROM orders WHERE order_date = (SELECT MAX(order_date) FROM orders);

-- Customers with orders
SELECT * FROM customers WHERE customer_id IN (SELECT customer_id FROM orders);

-- Products with reviews
SELECT * FROM products WHERE product_id IN (SELECT product_id FROM reviews);

-- Products priced above their category average (correlated)
SELECT * FROM products p
WHERE price > (SELECT AVG(price) FROM products WHERE category = p.category);

-- Orders after average order date
SELECT * FROM orders
WHERE order_date > (SELECT FROM_DAYS(AVG(TO_DAYS(order_date))) FROM orders);

-- Customers without orders
SELECT * FROM customers WHERE customer_id NOT IN (
    SELECT customer_id FROM orders WHERE customer_id IS NOT NULL);

-- Products with max price per category
SELECT * FROM products p
WHERE price = (SELECT MAX(price) FROM products WHERE category = p.category);

-- Count orders using subquery
SELECT COUNT(*) FROM (SELECT order_id FROM orders) t;

-- EXISTS vs IN
SELECT * FROM customers c WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
SELECT * FROM customers WHERE customer_id IN (SELECT customer_id FROM orders);

-- Derived table
SELECT category, avg_price
FROM (SELECT category, AVG(price) AS avg_price FROM products GROUP BY category) t
WHERE avg_price > 5000;

-- Subquery in SELECT
SELECT c.name,
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id) AS order_count
FROM customers c;

-- ---------- Extra subquery questions ----------

-- 1. Customers whose total spending > average spending of all customers
SELECT customer_id, SUM(amount) AS total_spent
FROM orders GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT AVG(t.total) FROM (SELECT SUM(amount) AS total FROM orders GROUP BY customer_id) t);

-- 2. Customers with more orders than average orders per customer
SELECT customer_id, COUNT(*) AS cnt
FROM orders GROUP BY customer_id
HAVING COUNT(*) > (
    SELECT AVG(t.cnt) FROM (SELECT COUNT(*) AS cnt FROM orders GROUP BY customer_id) t);

-- 3. Products priced above average
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- 4. Sellers with more products than average products per seller
SELECT seller_id, COUNT(*) AS product_cnt
FROM products GROUP BY seller_id
HAVING COUNT(*) > (
    SELECT AVG(t.cnt) FROM (SELECT COUNT(*) AS cnt FROM products GROUP BY seller_id) t);

-- 5. Customers who never placed an order
SELECT * FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);

-- 6. Orders with amount > average order amount
SELECT * FROM orders WHERE amount > (SELECT AVG(amount) FROM orders);

-- 7. Customers whose total purchase = max total purchase
SELECT customer_id, SUM(amount) AS total
FROM orders GROUP BY customer_id
HAVING SUM(amount) = (
    SELECT MAX(t.total) FROM (SELECT SUM(amount) AS total FROM orders GROUP BY customer_id) t);

-- 8. Products not associated with any seller
SELECT * FROM products
WHERE seller_id IS NULL OR seller_id NOT IN (SELECT seller_id FROM sellers);

-- 9. Customers in cities where more than one customer exists
SELECT * FROM customers
WHERE city IN (SELECT city FROM customers GROUP BY city HAVING COUNT(*) > 1);

-- 10. Sellers with at least one product priced below average
SELECT * FROM sellers s
WHERE EXISTS (SELECT 1 FROM products p
              WHERE p.seller_id = s.seller_id
                AND p.price < (SELECT AVG(price) FROM products));

-- 11. Customers whose total spending > ANY customer from Ahmedabad
--     (ANY = higher than the lowest Ahmedabad customer; use ALL for "higher than every one")
SELECT customer_id, SUM(amount) AS total
FROM orders GROUP BY customer_id
HAVING SUM(amount) > ANY (
    SELECT SUM(o.amount) FROM orders o JOIN customers c ON c.customer_id = o.customer_id
    WHERE c.city = 'Ahmedabad' GROUP BY o.customer_id);

-- 12. Products priced higher than ALL products of seller_id = 1
SELECT * FROM products
WHERE price > ALL (SELECT price FROM products WHERE seller_id = 1);

-- 13. Customers who ordered every product
SELECT customer_id FROM orders
GROUP BY customer_id
HAVING COUNT(DISTINCT product_id) = (SELECT COUNT(*) FROM products);

-- 14. Sellers who sell ONLY products priced above average
SELECT * FROM sellers s
WHERE EXISTS (SELECT 1 FROM products p WHERE p.seller_id = s.seller_id)
  AND NOT EXISTS (SELECT 1 FROM products p
                  WHERE p.seller_id = s.seller_id
                    AND p.price <= (SELECT AVG(price) FROM products));

-- 15. Customers whose latest order amount > their own average order amount
SELECT o.customer_id, o.amount AS latest_amount
FROM orders o
WHERE o.order_date = (SELECT MAX(order_date) FROM orders WHERE customer_id = o.customer_id)
  AND o.amount > (SELECT AVG(amount) FROM orders WHERE customer_id = o.customer_id);

-- 16. Sellers whose product count = max product count
SELECT seller_id, COUNT(*) AS product_cnt
FROM products GROUP BY seller_id
HAVING COUNT(*) = (
    SELECT MAX(t.cnt) FROM (SELECT COUNT(*) AS cnt FROM products GROUP BY seller_id) t);

-- 17. Products ordered more times than average order frequency of all products
SELECT product_id, COUNT(*) AS times_ordered
FROM orders GROUP BY product_id
HAVING COUNT(*) > (
    SELECT AVG(t.cnt) FROM (SELECT COUNT(*) AS cnt FROM orders GROUP BY product_id) t);

-- 18. Customers contributing more than 70% of total revenue
SELECT customer_id, SUM(amount) AS total
FROM orders GROUP BY customer_id
HAVING SUM(amount) > 0.7 * (SELECT SUM(amount) FROM orders);

-- 19. Sellers with products listed but none ordered
SELECT * FROM sellers s
WHERE EXISTS (SELECT 1 FROM products p WHERE p.seller_id = s.seller_id)
  AND NOT EXISTS (SELECT 1 FROM products p JOIN orders o ON o.product_id = p.product_id
                  WHERE p.seller_id = s.seller_id);

-- 20. Top 3 customers by spending WITHOUT using LIMIT (correlated count)
SELECT t1.customer_id, t1.total
FROM (SELECT customer_id, SUM(amount) AS total FROM orders GROUP BY customer_id) t1
WHERE (SELECT COUNT(*)
       FROM (SELECT customer_id, SUM(amount) AS total FROM orders GROUP BY customer_id) t2
       WHERE t2.total > t1.total) < 3
ORDER BY t1.total DESC;

-- Mini Project 1: Premium Product Identification
SELECT p.product_id, p.product_name, p.category, p.price,
       CASE WHEN p.price > (SELECT AVG(price) FROM products WHERE category = p.category)
            THEN 'Premium' ELSE 'Normal' END AS segment
FROM products p;

-- Mini Project 2: Active Customer Analysis
SELECT c.customer_id, c.name, MAX(o.order_date) AS last_order_date,
       COUNT(o.order_id) AS orders,
       CASE WHEN COUNT(o.order_id) = 0 THEN 'No Orders' ELSE 'Has Orders' END AS status
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY last_order_date DESC;

/*
   9. CTE (Common Table Expressions)
    */

-- CTE for delivered orders
WITH delivered AS (SELECT * FROM orders WHERE status = 'Delivered')
SELECT * FROM delivered;

-- Count delivered orders
WITH delivered AS (SELECT * FROM orders WHERE status = 'Delivered')
SELECT COUNT(*) AS delivered_orders FROM delivered;

-- Orders per payment method
WITH pm AS (SELECT payment_method, COUNT(*) AS cnt FROM orders GROUP BY payment_method)
SELECT * FROM pm ORDER BY cnt DESC;

-- Customer order count
WITH oc AS (SELECT customer_id, COUNT(*) AS order_count FROM orders GROUP BY customer_id)
SELECT c.name, COALESCE(oc.order_count, 0) AS order_count
FROM customers c LEFT JOIN oc ON c.customer_id = oc.customer_id;

-- Products above average price
WITH avg_p AS (SELECT AVG(price) AS avg_price FROM products)
SELECT p.* FROM products p, avg_p WHERE p.price > avg_p.avg_price;

-- Avg delivery days
WITH d AS (SELECT delivery_days FROM deliveries WHERE delivery_status = 'Delivered')
SELECT ROUND(AVG(delivery_days), 2) AS avg_delivery_days FROM d;

-- Multiple CTEs in one query
WITH delivered AS (SELECT * FROM orders WHERE status = 'Delivered'),
     cancelled AS (SELECT * FROM orders WHERE status = 'Cancelled')
SELECT (SELECT COUNT(*) FROM delivered) AS delivered_cnt,
       (SELECT COUNT(*) FROM cancelled) AS cancelled_cnt;

-- Replace a subquery using CTE (premium products)
WITH cat_avg AS (SELECT category, AVG(price) AS avg_price FROM products GROUP BY category)
SELECT p.product_name, p.price, c.avg_price
FROM products p JOIN cat_avg c ON p.category = c.category
WHERE p.price > c.avg_price;

-- Sort CTE result
WITH sorted_p AS (SELECT product_name, price FROM products)
SELECT * FROM sorted_p ORDER BY price DESC;

-- Join inside CTE
WITH cust_orders AS (
    SELECT c.customer_id, c.name, o.order_id, o.amount
    FROM customers c JOIN orders o ON c.customer_id = o.customer_id)
SELECT name, SUM(amount) AS total_spent FROM cust_orders GROUP BY customer_id, name;

-- KPI report using CTE
WITH total_cust AS (SELECT COUNT(*) AS cnt FROM customers),
     total_ord  AS (SELECT COUNT(*) AS cnt FROM orders),
     deliv_ord  AS (SELECT COUNT(*) AS cnt FROM orders WHERE status = 'Delivered')
SELECT total_cust.cnt AS total_customers,
       total_ord.cnt  AS total_orders,
       deliv_ord.cnt  AS delivered_orders
FROM total_cust, total_ord, deliv_ord;

-- Recursive CTE to generate numbers 1..10
WITH RECURSIVE nums AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM nums WHERE n < 10)
SELECT * FROM nums;

-- Mini Project 1: Flipkart KPI Layer
WITH c AS (SELECT COUNT(*) AS total_customers FROM customers),
     o AS (SELECT COUNT(*) AS total_orders FROM orders),
     d AS (SELECT COUNT(*) AS delivered_orders FROM orders WHERE status = 'Delivered'),
     a AS (SELECT ROUND(AVG(delivery_days), 2) AS avg_delivery_days FROM deliveries)
SELECT * FROM c, o, d, a;

-- Mini Project 2: Customer Activity Segmentation
WITH oc AS (SELECT customer_id, COUNT(*) AS order_count FROM orders GROUP BY customer_id)
SELECT c.customer_id, c.name,
       COALESCE(oc.order_count, 0) AS order_count,
       CASE WHEN oc.order_count IS NULL THEN 'Without Orders' ELSE 'With Orders' END AS segment
FROM customers c LEFT JOIN oc ON c.customer_id = oc.customer_id;

-- Mini Project 3: Product Price Benchmark
WITH bench AS (SELECT category, ROUND(AVG(price), 2) AS category_avg FROM products GROUP BY category)
SELECT p.product_name, p.category, p.price, b.category_avg,
       p.price > b.category_avg AS above_benchmark
FROM products p JOIN bench b ON p.category = b.category;

-- Mini Project 4: Delivery Performance Report
WITH del AS (SELECT * FROM deliveries WHERE delivery_status = 'Delivered')
SELECT delivery_partner,
       COUNT(*) AS delivered_orders,
       ROUND(AVG(delivery_days), 2) AS avg_days,
       CASE WHEN AVG(delivery_days) <= 3 THEN 'Fast' ELSE 'Slow' END AS classification
FROM del GROUP BY delivery_partner;

/*
   10. WINDOW FUNCTIONS
    */

-- Avg product price shown with each product
SELECT product_name, price, AVG(price) OVER () AS avg_price FROM products;

-- Avg price per category
SELECT product_name, category, price,
       AVG(price) OVER (PARTITION BY category) AS category_avg
FROM products;

-- Count products per category
SELECT product_name, category,
       COUNT(*) OVER (PARTITION BY category) AS products_in_category
FROM products;

-- Total orders per customer (row-level)
SELECT order_id, customer_id,
       COUNT(*) OVER (PARTITION BY customer_id) AS customer_total_orders
FROM orders;

-- Price vs category average
SELECT product_name, category, price,
       ROUND(price - AVG(price) OVER (PARTITION BY category), 2) AS diff_from_avg
FROM products;

-- Avg delivery days per partner
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

-- Filter rows using window output (wrap in subquery/CTE; WHERE can't use window fns)
SELECT * FROM (
    SELECT product_name, category, price,
           AVG(price) OVER (PARTITION BY category) AS cat_avg
    FROM products) t
WHERE price > cat_avg;

-- Window vs GROUP BY
SELECT category, AVG(price) FROM products GROUP BY category;            -- collapses rows
SELECT product_name, category, AVG(price) OVER (PARTITION BY category)
FROM products;                                                          -- keeps all rows

-- Inventory analytics
SELECT product_name, category, stock, price,
       SUM(stock) OVER (PARTITION BY category)              AS category_stock,
       ROUND(stock * 100 / SUM(stock) OVER (PARTITION BY category), 2) AS stock_share_pct,
       price * stock                                         AS stock_value
FROM products;

-- Mini Project 1: Product Price Intelligence
SELECT product_name, category, price,
       ROUND(AVG(price) OVER (PARTITION BY category), 2)         AS category_avg,
       ROUND(price - AVG(price) OVER (PARTITION BY category), 2) AS diff_from_avg
FROM products;

-- Mini Project 2: Customer Order Strength
SELECT customer_id, order_id,
       COUNT(*) OVER (PARTITION BY customer_id) AS order_count,
       CASE WHEN COUNT(*) OVER (PARTITION BY customer_id) > 1
            THEN 'Repeat' ELSE 'One-time' END AS customer_type
FROM orders;

/*
   11. RANKING FUNCTIONS
    */

-- Rank products by price
SELECT product_name, price, RANK() OVER (ORDER BY price DESC) AS price_rank FROM products;

-- Dense rank
SELECT product_name, price, DENSE_RANK() OVER (ORDER BY price DESC) AS price_dense_rank FROM products;

-- Row number
SELECT product_id, product_name, ROW_NUMBER() OVER (ORDER BY product_id) AS rn FROM products;

-- Rank products per category
SELECT product_name, category, price,
       RANK() OVER (PARTITION BY category ORDER BY price DESC) AS rnk
FROM products;

-- Top 3 products per category
SELECT * FROM (
    SELECT product_name, category, price,
           DENSE_RANK() OVER (PARTITION BY category ORDER BY price DESC) AS rnk
    FROM products) t
WHERE rnk <= 3;

-- Rank customers by order count
SELECT customer_id, COUNT(*) AS order_count,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
FROM orders GROUP BY customer_id;

-- Rank deliveries by speed
SELECT delivery_id, delivery_partner, delivery_days,
       RANK() OVER (ORDER BY delivery_days ASC) AS speed_rank
FROM deliveries;

-- Ranking with JOIN
SELECT c.name, SUM(o.amount) AS total_spent,
       RANK() OVER (ORDER BY SUM(o.amount) DESC) AS rnk
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- RANK vs DENSE_RANK vs ROW_NUMBER output compare
SELECT product_name, price,
       ROW_NUMBER() OVER (ORDER BY price DESC) AS row_num,
       RANK()       OVER (ORDER BY price DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY price DESC) AS dense_rnk
FROM products;

-- Leaderboard
SELECT DENSE_RANK() OVER (ORDER BY SUM(o.amount) DESC) AS position,
       c.name, SUM(o.amount) AS total_spent
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- Mini Project 1: Category Leaderboard (top 3 expensive per category)
WITH ranked AS (
    SELECT product_name, category, price,
           DENSE_RANK() OVER (PARTITION BY category ORDER BY price DESC) AS rnk
    FROM products)
SELECT * FROM ranked WHERE rnk <= 3;

-- Mini Project 2: Customer Power Users
WITH oc AS (SELECT customer_id, COUNT(*) AS order_count FROM orders GROUP BY customer_id)
SELECT c.name, oc.order_count, RANK() OVER (ORDER BY oc.order_count DESC) AS rnk
FROM oc JOIN customers c ON c.customer_id = oc.customer_id;

-- Mini Project 3: Delivery Performance Ranking
SELECT delivery_partner, ROUND(AVG(delivery_days), 2) AS avg_days,
       RANK() OVER (ORDER BY AVG(delivery_days)) AS partner_rank
FROM deliveries GROUP BY delivery_partner;

SELECT order_id, delivery_partner, delivery_days,
       RANK() OVER (ORDER BY delivery_days) AS order_rank
FROM deliveries;

/*
   12. DATE FUNCTIONS
    */

SELECT order_id, YEAR(order_date)  AS order_year  FROM orders;      -- extract year
SELECT order_id, MONTH(order_date) AS order_month FROM orders;      -- extract month
SELECT CURDATE() AS today, NOW() AS current_datetime;               -- today's date
SELECT order_id, DATE_ADD(order_date, INTERVAL 10 DAY) AS plus_10_days FROM orders;

-- Orders from last 15 days
SELECT * FROM orders WHERE order_date >= CURDATE() - INTERVAL 15 DAY;

-- Last 30 days
SELECT * FROM orders WHERE order_date >= CURDATE() - INTERVAL 30 DAY;

-- Days since each order
SELECT order_id, order_date, DATEDIFF(CURDATE(), order_date) AS days_since_order FROM orders;

-- Orders per month
SELECT YEAR(order_date) AS yr, MONTH(order_date) AS mth, COUNT(*) AS total_orders
FROM orders GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY yr, mth;

-- Oldest and most recent order
SELECT * FROM orders ORDER BY order_date ASC  LIMIT 1;
SELECT * FROM orders ORDER BY order_date DESC LIMIT 1;
SELECT MIN(order_date) AS oldest, MAX(order_date) AS latest FROM orders;

-- Avg delivery days
SELECT ROUND(AVG(delivery_days), 2) AS avg_delivery_days FROM deliveries;

-- Orders in January
SELECT * FROM orders WHERE MONTH(order_date) = 1;

-- Orders placed this year (index-friendly version)
SELECT * FROM orders
WHERE order_date >= MAKEDATE(YEAR(CURDATE()), 1)
  AND order_date <  MAKEDATE(YEAR(CURDATE()) + 1, 1);

-- Mini Project 1: Monthly Order Dashboard
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

-- Mini Project 2: Delivery SLA Report
SELECT delivery_id, order_id, delivery_days,
       CASE WHEN delivery_days <= 2 THEN 'Fast'
            WHEN delivery_days <= 5 THEN 'Normal'
            ELSE 'Slow' END AS speed_class,
       CASE WHEN delivery_days > 5 THEN 'Delayed' ELSE 'On Time' END AS delay_class
FROM deliveries;

SELECT ROUND(AVG(delivery_days), 2) AS avg_delivery_days FROM deliveries;

-- Mini Project 3: Customer Recency Analysis
SELECT c.customer_id, c.name,
       MAX(o.order_date) AS last_order,
       DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order,
       CASE WHEN MAX(o.order_date) >= CURDATE() - INTERVAL 90 DAY
            THEN 'Active' ELSE 'Inactive' END AS status
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

/*
   13. STRING FUNCTIONS
    */

SELECT CONCAT(name, ' - ', email) AS name_email FROM customers;
SELECT UPPER(product_name) AS product_name_upper FROM products;
SELECT product_name, LEFT(product_name, 4) AS first_4 FROM products;
SELECT product_name, RIGHT(product_name, 3) AS last_3 FROM products;
SELECT payment_method, REPLACE(payment_method, 'COD', 'Cash') AS payment_clean FROM orders;
SELECT TRIM(name) AS trimmed_name FROM customers;
SELECT seller_name, LENGTH(seller_name) AS name_length FROM sellers;
SELECT email, SUBSTRING_INDEX(email, '@', -1) AS email_domain FROM customers;
SELECT product_name, UPPER(LEFT(product_name, 3)) AS short_code FROM products;
SELECT CONCAT(category, ' - Rs.', price) AS category_price FROM products;
SELECT LOWER(payment_method) AS payment_lower FROM orders;

-- Format name properly (Proper Case: first letter capital, rest small)
SELECT CONCAT(UPPER(LEFT(TRIM(name), 1)), LOWER(SUBSTRING(TRIM(name), 2))) AS proper_name
FROM customers;

-- Mini Project 1: Customer Data Cleaning
SELECT customer_id,
       CONCAT(UPPER(LEFT(TRIM(name), 1)), LOWER(SUBSTRING(TRIM(name), 2))) AS clean_name,
       LOWER(TRIM(email))                              AS clean_email,
       SUBSTRING_INDEX(LOWER(TRIM(email)), '@', -1)    AS email_domain,
       REGEXP_REPLACE(TRIM(name), '[[:space:]]+', ' ') AS name_single_spaces
FROM customers;

-- Mini Project 2: Product Code Generator (first 3 letters + price)
SELECT product_name, price,
       CONCAT(UPPER(LEFT(product_name, 3)), CAST(price AS UNSIGNED)) AS product_code
FROM products;

-- Mini Project 3: Marketing Segmentation
SELECT SUBSTRING_INDEX(email, '@', -1) AS email_domain, COUNT(*) AS users
FROM customers GROUP BY email_domain ORDER BY users DESC;

SELECT SUBSTRING_INDEX(email, '@', -1) AS top_domain, COUNT(*) AS users
FROM customers GROUP BY top_domain ORDER BY users DESC LIMIT 1;

/*
   14. CASE WHEN
    */

-- Classify products by price
SELECT product_name, price,
       CASE WHEN price < 1000  THEN 'Low'
            WHEN price < 10000 THEN 'Medium'
            ELSE 'High' END AS price_class
FROM products;

-- Segment customers by order count
SELECT c.name, COUNT(o.order_id) AS orders,
       CASE WHEN COUNT(o.order_id) = 0 THEN 'Inactive'
            WHEN COUNT(o.order_id) <= 2 THEN 'Occasional'
            ELSE 'Frequent' END AS segment
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- Fast / slow deliveries
SELECT delivery_id, delivery_days,
       CASE WHEN delivery_days <= 3 THEN 'Fast' ELSE 'Slow' END AS speed
FROM deliveries;

-- Delivered vs non-delivered count
SELECT SUM(CASE WHEN status = 'Delivered' THEN 1 ELSE 0 END) AS delivered,
       SUM(CASE WHEN status <> 'Delivered' THEN 1 ELSE 0 END) AS not_delivered
FROM orders;

-- Categorize sellers by rating
SELECT seller_name, rating,
       CASE WHEN rating >= 4.5 THEN 'Excellent'
            WHEN rating >= 3.5 THEN 'Good'
            ELSE 'Needs Improvement' END AS seller_category
FROM sellers;

-- Inventory status
SELECT product_name, stock,
       CASE WHEN stock = 0   THEN 'Out of Stock'
            WHEN stock < 10  THEN 'Low Stock'
            ELSE 'In Stock' END AS inventory_status
FROM products;

-- CASE in ORDER BY (Delivered first, then Pending, then the rest)
SELECT * FROM orders
ORDER BY CASE status WHEN 'Delivered' THEN 1 WHEN 'Pending' THEN 2 ELSE 3 END;

-- CASE with window function
SELECT product_name, category, price,
       CASE WHEN price > AVG(price) OVER (PARTITION BY category)
            THEN 'Above Avg' ELSE 'Below Avg' END AS vs_category
FROM products;

-- Segment orders by payment type
SELECT order_id, payment_method,
       CASE WHEN payment_method = 'COD' THEN 'Offline' ELSE 'Online' END AS payment_type
FROM orders;

-- Revenue bands
SELECT order_id, amount,
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
SELECT name, email,
       CASE WHEN email LIKE '%@gmail.com' THEN 'Gmail'
            WHEN email LIKE '%@yahoo.com' THEN 'Yahoo'
            WHEN email LIKE '%@outlook.com' OR email LIKE '%@hotmail.com' THEN 'Microsoft'
            ELSE 'Other' END AS domain_type
FROM customers;

-- Mini Project 1: Customer Segmentation Engine (summary report)
WITH seg AS (
    SELECT c.customer_id,
           CASE WHEN COUNT(o.order_id) = 0 THEN 'Inactive'
                WHEN COUNT(o.order_id) <= 2 THEN 'Occasional'
                ELSE 'Frequent' END AS segment
    FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id)
SELECT segment, COUNT(*) AS customers FROM seg GROUP BY segment;

-- Mini Project 2: Product Price Intelligence (Low/Medium/High + vs category avg)
SELECT product_name, category, price,
       CASE WHEN price < 1000 THEN 'Low' WHEN price < 10000 THEN 'Medium' ELSE 'High' END AS price_tier,
       CASE WHEN price > AVG(price) OVER (PARTITION BY category) THEN 'Above Category Avg'
            ELSE 'At/Below Category Avg' END AS vs_category
FROM products;

-- Mini Project 3: Delivery Performance Scorecard
SELECT delivery_partner,
       ROUND(AVG(delivery_days), 2) AS avg_days,
       CASE WHEN AVG(delivery_days) <= 2 THEN 'Excellent'
            WHEN AVG(delivery_days) <= 4 THEN 'Good'
            ELSE 'Poor' END AS performance,
       RANK() OVER (ORDER BY AVG(delivery_days)) AS rank_no
FROM deliveries GROUP BY delivery_partner;

-- Mini Project 4: Inventory Risk Monitoring
SELECT product_name, stock, 'Out of Stock' AS risk FROM products WHERE stock = 0;

SELECT p.product_name, p.stock, COUNT(o.order_id) AS times_ordered
FROM products p JOIN orders o ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.stock
HAVING COUNT(o.order_id) >= 3 AND p.stock < 10;      -- high demand + low stock

/*
   15. VIEWS
    */

-- Customer summary view
CREATE VIEW vw_customer_summary AS
SELECT c.customer_id, c.name, c.city,
       COUNT(o.order_id) AS total_orders,
       COALESCE(SUM(o.amount), 0) AS total_spent
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city;

-- Delivered orders view
CREATE VIEW vw_delivered_orders AS
SELECT * FROM orders WHERE status = 'Delivered';

-- Product performance view
CREATE VIEW vw_product_performance AS
SELECT p.product_id, p.product_name, p.category, p.price,
       COUNT(o.order_id) AS times_ordered,
       COALESCE(SUM(o.amount), 0) AS revenue
FROM products p LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price;

-- Query from a view / count rows / use in another query
SELECT * FROM vw_customer_summary;
SELECT COUNT(*) FROM vw_customer_summary;
SELECT * FROM vw_customer_summary WHERE total_spent > 10000 ORDER BY total_spent DESC;

-- Modify view
CREATE OR REPLACE VIEW vw_delivered_orders AS
SELECT order_id, customer_id, product_id, order_date, amount
FROM orders WHERE status = 'Delivered';

-- View hiding sensitive columns (no email / mobile)
CREATE VIEW vw_customers_public AS
SELECT customer_id, name, city FROM customers;

-- View using JOIN
CREATE VIEW vw_order_details AS
SELECT o.order_id, c.name AS customer, p.product_name, o.amount, o.order_date
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN products  p ON p.product_id  = o.product_id;

-- View using GROUP BY
CREATE VIEW vw_category_summary AS
SELECT category, COUNT(*) AS products, ROUND(AVG(price), 2) AS avg_price
FROM products GROUP BY category;

-- Drop a view
DROP VIEW IF EXISTS vw_category_summary;

-- Mini Project 1: Reporting layer - customer summary, product performance (above)
CREATE VIEW vw_delivery_performance AS
SELECT delivery_partner, COUNT(*) AS deliveries, ROUND(AVG(delivery_days), 2) AS avg_days
FROM deliveries GROUP BY delivery_partner;

-- Mini Project 2: Executive Dashboard View
CREATE VIEW vw_executive_dashboard AS
SELECT o.order_id, o.order_date, o.amount, o.status, o.payment_method,
       c.name AS customer_name, c.city,
       d.delivery_partner, d.delivery_days, d.delivery_status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN deliveries d ON d.order_id = o.order_id;

-- Mini Project 3: Secure public view for reporting team
CREATE VIEW vw_reporting_public AS
SELECT o.order_id, o.order_date, o.amount, o.status, c.city
FROM orders o JOIN customers c ON c.customer_id = o.customer_id;
-- Optional: CREATE USER 'report_user'@'%' IDENTIFIED BY '***';
--           GRANT SELECT ON flipkart_db.vw_reporting_public TO 'report_user'@'%';

-- Mini Project 4: KPI View Layer
CREATE VIEW vw_kpi AS
SELECT (SELECT COUNT(*) FROM orders)                                  AS total_orders,
       (SELECT COUNT(*) FROM orders WHERE status = 'Delivered')       AS delivered_orders,
       (SELECT ROUND(AVG(delivery_days), 2) FROM deliveries)          AS avg_delivery_days,
       (SELECT COUNT(*) FROM customers)                               AS total_customers;

/*
   16. INDEXES & PERFORMANCE
    */

CREATE INDEX idx_order_date  ON orders(order_date);
CREATE INDEX idx_customer_id ON orders(customer_id);
CREATE INDEX idx_cust_date   ON orders(customer_id, order_date);     -- composite
DROP INDEX idx_cust_date ON orders;

EXPLAIN SELECT * FROM orders WHERE order_date = '2025-01-15';        -- check type / key / rows

-- Compare before & after: run EXPLAIN, create index, run EXPLAIN again
EXPLAIN SELECT * FROM orders WHERE customer_id = 5;
CREATE INDEX idx_orders_customer ON orders(customer_id);
EXPLAIN SELECT * FROM orders WHERE customer_id = 5;                  -- type should change ALL -> ref

-- Optimize date filtering: avoid functions on the column
-- Slow (cannot use index):
SELECT * FROM orders WHERE YEAR(order_date) = 2025;
-- Fast (range scan on index):
SELECT * FROM orders WHERE order_date >= '2025-01-01' AND order_date < '2026-01-01';

-- Identify full table scan: EXPLAIN shows type = ALL
EXPLAIN SELECT * FROM products WHERE product_name LIKE '%Shirt%';    -- leading % => full scan

-- Optimize JOIN: index the foreign keys
CREATE INDEX idx_orders_product ON orders(product_id);
CREATE INDEX idx_deliveries_order ON deliveries(order_id);
EXPLAIN SELECT c.name, o.order_id
FROM customers c JOIN orders o ON c.customer_id = o.customer_id;

-- Test ORDER BY performance
EXPLAIN SELECT * FROM orders ORDER BY order_date DESC LIMIT 10;      -- uses idx_order_date

-- Show indexes / remove unnecessary index
SHOW INDEX FROM orders;
DROP INDEX idx_orders_customer ON orders;      -- duplicate of idx_customer_id

-- Mini Project 4: Index strategy
CREATE INDEX idx_orders_cust_date ON orders(customer_id, order_date);
CREATE INDEX idx_orders_status    ON orders(status);
CREATE INDEX idx_products_cat     ON products(category, price);
CREATE INDEX idx_products_seller  ON products(seller_id);
CREATE INDEX idx_deliv_partner    ON deliveries(delivery_partner, delivery_status);

/*
   17. STORED PROCEDURES
    */
DELIMITER //

-- Procedure for delivered orders
CREATE PROCEDURE sp_delivered_orders()
BEGIN
    SELECT * FROM orders WHERE status = 'Delivered';
END //

-- Procedure with IN parameter
CREATE PROCEDURE sp_orders_by_customer(IN p_customer_id INT)
BEGIN
    SELECT * FROM orders WHERE customer_id = p_customer_id;
END //

-- Procedure with OUT parameter
CREATE PROCEDURE sp_total_orders(IN p_customer_id INT, OUT p_total INT)
BEGIN
    SELECT COUNT(*) INTO p_total FROM orders WHERE customer_id = p_customer_id;
END //

-- Procedure using IF
CREATE PROCEDURE sp_customer_type(IN p_customer_id INT)
BEGIN
    DECLARE v_cnt INT;
    SELECT COUNT(*) INTO v_cnt FROM orders WHERE customer_id = p_customer_id;
    IF v_cnt = 0 THEN
        SELECT 'Inactive' AS customer_type;
    ELSEIF v_cnt <= 2 THEN
        SELECT 'Occasional' AS customer_type;
    ELSE
        SELECT 'Frequent' AS customer_type;
    END IF;
END //

-- Mini Project 1: Procedure to insert an order
CREATE PROCEDURE sp_insert_order(
    IN p_customer_id INT, IN p_product_id INT, IN p_amount DECIMAL(10,2), IN p_payment VARCHAR(20))
BEGIN
    INSERT INTO orders (customer_id, product_id, order_date, amount, payment_method, status)
    VALUES (p_customer_id, p_product_id, CURDATE(), p_amount, p_payment, 'Pending');
END //

DELIMITER ;

-- Call / drop
CALL sp_delivered_orders();
CALL sp_orders_by_customer(1);
CALL sp_total_orders(1, @total);
SELECT @total;
DROP PROCEDURE IF EXISTS sp_customer_type;

/*
   18. TRIGGERS - supporting tables
    */
CREATE TABLE audit_log (
    log_id      INT AUTO_INCREMENT PRIMARY KEY,
    table_name  VARCHAR(50),
    action_type VARCHAR(20),
    record_id   INT,
    log_time    DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE review_log (review_id INT, product_id INT, log_time DATETIME);
CREATE TABLE customer_activity (customer_id INT, activity_type VARCHAR(50), activity_time DATETIME);
CREATE TABLE inventory_log (product_id INT, stock_added INT, log_time DATETIME);
CREATE TABLE delivery_partner_change (order_id INT, old_partner VARCHAR(50), new_partner VARCHAR(50), change_time DATETIME);
CREATE TABLE customer_address_log (customer_id INT, old_address VARCHAR(200), new_address VARCHAR(200), change_time DATETIME);
CREATE TABLE price_change_log (product_id INT, old_price DECIMAL(10,2), new_price DECIMAL(10,2), change_time DATETIME);
CREATE TABLE deleted_reviews_log (review_id INT, product_id INT, customer_id INT, deleted_time DATETIME);
CREATE TABLE product_archive (product_id INT, product_name VARCHAR(100), deleted_time DATETIME);
CREATE TABLE seller_removal_log (seller_id INT, seller_name VARCHAR(100), removal_time DATETIME);

DELIMITER //

/* ---------------- BEFORE INSERT ---------------- */

-- 1. Block customer insert if email has no '@'
CREATE TRIGGER trg_customer_email_check
BEFORE INSERT ON customers FOR EACH ROW
BEGIN
    IF NEW.email NOT LIKE '%@%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid email: must contain @';
    END IF;
END //

-- 2. Default review_date to today
CREATE TRIGGER trg_review_default_date
BEFORE INSERT ON reviews FOR EACH ROW
BEGIN
    IF NEW.review_date IS NULL THEN
        SET NEW.review_date = CURRENT_DATE;
    END IF;
END //

-- 3. Cap delivery_days at 30
CREATE TRIGGER trg_delivery_days_cap
BEFORE INSERT ON deliveries FOR EACH ROW
BEGIN
    IF NEW.delivery_days > 30 THEN
        SET NEW.delivery_days = 30;
    END IF;
END //

/* ---------------- AFTER INSERT ---------------- */

-- 4. Log new reviews
CREATE TRIGGER trg_review_log
AFTER INSERT ON reviews FOR EACH ROW
BEGIN
    INSERT INTO review_log (review_id, product_id, log_time)
    VALUES (NEW.review_id, NEW.product_id, NOW());
END //

-- 5. Welcome record for new customers
CREATE TRIGGER trg_customer_welcome
AFTER INSERT ON customers FOR EACH ROW
BEGIN
    INSERT INTO customer_activity (customer_id, activity_type, activity_time)
    VALUES (NEW.customer_id, 'New Signup', NOW());
END //

-- 6. Log initial stock for new products
CREATE TRIGGER trg_product_initial_stock
AFTER INSERT ON products FOR EACH ROW
BEGIN
    INSERT INTO inventory_log (product_id, stock_added, log_time)
    VALUES (NEW.product_id, NEW.stock, NOW());
END //

/* ---------------- BEFORE UPDATE ---------------- */

-- 7. Cannot mark Delivered if delivery_days is NULL
CREATE TRIGGER trg_delivery_status_check
BEFORE UPDATE ON deliveries FOR EACH ROW
BEGIN
    IF NEW.delivery_status = 'Delivered' AND NEW.delivery_days IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'delivery_days required before marking Delivered';
    END IF;
END //

-- 8. Block duplicate mobile_no on update
CREATE TRIGGER trg_customer_mobile_unique
BEFORE UPDATE ON customers FOR EACH ROW
BEGIN
    IF NEW.mobile_no <> OLD.mobile_no AND EXISTS (
        SELECT 1 FROM customers
        WHERE mobile_no = NEW.mobile_no AND customer_id <> OLD.customer_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mobile number already exists';
    END IF;
END //

-- 9. Block stock reduction of more than 50 in one update
CREATE TRIGGER trg_stock_reduction_limit
BEFORE UPDATE ON products FOR EACH ROW
BEGIN
    IF OLD.stock - NEW.stock > 50 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot reduce stock by more than 50 at once';
    END IF;
END //

/* ---------------- AFTER UPDATE ---------------- */

-- 10. Log delivery partner change
CREATE TRIGGER trg_delivery_partner_change
AFTER UPDATE ON deliveries FOR EACH ROW
BEGIN
    IF NOT (OLD.delivery_partner <=> NEW.delivery_partner) THEN
        INSERT INTO delivery_partner_change (order_id, old_partner, new_partner, change_time)
        VALUES (OLD.order_id, OLD.delivery_partner, NEW.delivery_partner, NOW());
    END IF;
END //

-- 11. Log address change
CREATE TRIGGER trg_customer_address_log
AFTER UPDATE ON customers FOR EACH ROW
BEGIN
    IF NOT (OLD.address <=> NEW.address) THEN
        INSERT INTO customer_address_log (customer_id, old_address, new_address, change_time)
        VALUES (OLD.customer_id, OLD.address, NEW.address, NOW());
    END IF;
END //

-- 12. Log price change only if it changed
CREATE TRIGGER trg_price_change_log
AFTER UPDATE ON products FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO price_change_log (product_id, old_price, new_price, change_time)
        VALUES (OLD.product_id, OLD.price, NEW.price, NOW());
    END IF;
END //

/* ---------------- BEFORE DELETE ---------------- */

-- 13. Cannot delete customer who has orders
CREATE TRIGGER trg_customer_delete_check
BEFORE DELETE ON customers FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM orders WHERE customer_id = OLD.customer_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer has orders; cannot delete';
    END IF;
END //

-- 14. Cannot delete product with stock > 0
CREATE TRIGGER trg_product_delete_check
BEFORE DELETE ON products FOR EACH ROW
BEGIN
    IF OLD.stock > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product still has stock; cannot delete';
    END IF;
END //

-- 15. Cannot delete In Transit delivery
CREATE TRIGGER trg_delivery_delete_check
BEFORE DELETE ON deliveries FOR EACH ROW
BEGIN
    IF OLD.delivery_status = 'In Transit' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Delivery is In Transit; cannot delete';
    END IF;
END //

/* ---------------- AFTER DELETE ---------------- */

-- 16. Log deleted reviews
CREATE TRIGGER trg_review_deleted_log
AFTER DELETE ON reviews FOR EACH ROW
BEGIN
    INSERT INTO deleted_reviews_log (review_id, product_id, customer_id, deleted_time)
    VALUES (OLD.review_id, OLD.product_id, OLD.customer_id, NOW());
END //

-- 17. Archive deleted products
CREATE TRIGGER trg_product_archive
AFTER DELETE ON products FOR EACH ROW
BEGIN
    INSERT INTO product_archive (product_id, product_name, deleted_time)
    VALUES (OLD.product_id, OLD.product_name, NOW());
END //

-- 18. Log seller removal
CREATE TRIGGER trg_seller_removal_log
AFTER DELETE ON sellers FOR EACH ROW
BEGIN
    INSERT INTO seller_removal_log (seller_id, seller_name, removal_time)
    VALUES (OLD.seller_id, OLD.seller_name, NOW());
END //

/* ---------------- MINI PROJECTS ---------------- */

-- Mini Project 1: Trigger to log order activity
CREATE TRIGGER trg_order_activity_log
AFTER INSERT ON orders FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, action_type, record_id)
    VALUES ('orders', 'INSERT', NEW.order_id);
END //

-- Mini Project 3: Audit & Compliance (every insert/update/delete on products)
CREATE TRIGGER trg_products_audit_ins AFTER INSERT ON products FOR EACH ROW
BEGIN INSERT INTO audit_log (table_name, action_type, record_id) VALUES ('products','INSERT',NEW.product_id); END //

CREATE TRIGGER trg_products_audit_upd AFTER UPDATE ON products FOR EACH ROW
BEGIN INSERT INTO audit_log (table_name, action_type, record_id) VALUES ('products','UPDATE',NEW.product_id); END //

CREATE TRIGGER trg_products_audit_del AFTER DELETE ON products FOR EACH ROW
BEGIN INSERT INTO audit_log (table_name, action_type, record_id) VALUES ('products','DELETE',OLD.product_id); END //

-- Mini Project 4: Customer Reward Automation
-- Procedure to calculate total orders
CREATE PROCEDURE sp_customer_total_orders(IN p_customer_id INT, OUT p_total INT)
BEGIN
    SELECT COUNT(*) INTO p_total FROM orders WHERE customer_id = p_customer_id;
END //

DELIMITER ;

-- Trigger to classify customer as 'Frequent' needs a column first
ALTER TABLE customers ADD COLUMN customer_type VARCHAR(20) DEFAULT 'Regular';

DELIMITER //
CREATE TRIGGER trg_mark_frequent_customer
AFTER INSERT ON orders FOR EACH ROW
BEGIN
    DECLARE v_cnt INT;
    SELECT COUNT(*) INTO v_cnt FROM orders WHERE customer_id = NEW.customer_id;
    IF v_cnt >= 5 THEN
        UPDATE customers SET customer_type = 'Frequent' WHERE customer_id = NEW.customer_id;
    END IF;
END //
DELIMITER ;

-- Test a trigger
INSERT INTO customers (name, email, mobile_no, city, address)
VALUES ('Test User', 'test@gmail.com', '9999999999', 'Ahmedabad', 'Test Address');
SELECT * FROM customer_activity;                       -- welcome row should exist

-- Disable/remove a trigger (MySQL has no DISABLE; drop it)
DROP TRIGGER IF EXISTS trg_customer_welcome;

-- Mini Project 2: Inventory Protection System 
-- Prevent negative stock + log stock changes
DELIMITER //
CREATE TRIGGER trg_no_negative_stock
BEFORE UPDATE ON products FOR EACH ROW
BEGIN
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock cannot be negative';
    END IF;
END //

CREATE TRIGGER trg_stock_change_log
AFTER UPDATE ON products FOR EACH ROW
BEGIN
    IF OLD.stock <> NEW.stock THEN
        INSERT INTO inventory_log (product_id, stock_added, log_time)
        VALUES (NEW.product_id, NEW.stock - OLD.stock, NOW());
    END IF;
END //
DELIMITER ;