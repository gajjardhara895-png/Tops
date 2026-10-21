-- 03_basic_queries.sql
-- Topics: SELECT, aliases, comments, LIKE, BETWEEN, IN, DISTINCT,
--         ORDER BY, LIMIT, search and filter engine, ranking dashboard

USE flipkart_db;

-- Module 1: SELECT basics (Employee Reporting)

SELECT * FROM employees;                                   -- full employee data
SELECT name FROM employees;                                -- only names
SELECT name, city FROM employees;                          -- name and city
SELECT name, salary AS monthly_income FROM employees;      -- column alias
SELECT DISTINCT department FROM employees;                 -- department details

/* Multi-line comment:
   dashboard-friendly query with readable aliases for Excel export */
SELECT emp_id     AS `Employee ID`,
       name       AS `Employee Name`,
       city       AS `City`,
       salary     AS `Monthly Income`
FROM employees;

-- Module 2: LIKE, BETWEEN, IN (Search and Filter Engine)

SELECT * FROM customers WHERE name LIKE 'R%';                       -- starts with R
SELECT * FROM customers WHERE name LIKE 'R___';                     -- R + exactly 3 chars
SELECT * FROM products  WHERE price BETWEEN 5000 AND 20000;         -- inclusive range
SELECT * FROM orders    WHERE payment_method IN ('UPI', 'COD');     -- UPI or COD
SELECT * FROM deliveries WHERE delivery_partner = 'Ekart';          -- exact match
SELECT * FROM products  WHERE product_name LIKE '%Shirt%';          -- contains word
SELECT * FROM customers WHERE email LIKE '%@gmail.com';             -- gmail users
SELECT * FROM orders WHERE order_date BETWEEN CURDATE() - INTERVAL 30 DAY AND CURDATE();

-- Fast deliveries (2 days or less)
SELECT * FROM deliveries WHERE delivery_days <= 2;

-- Combine multiple filters in one query
SELECT p.product_name, p.category, p.price
FROM products p
WHERE p.product_name LIKE '%Shirt%'
  AND p.price BETWEEN 500 AND 2000
  AND p.stock > 0;

SELECT o.order_id, c.name, o.amount, o.payment_method
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE c.name LIKE 'R%'
  AND o.payment_method IN ('UPI', 'COD')
  AND o.amount BETWEEN 800 AND 20000;

-- Module 3: DISTINCT, ORDER BY, LIMIT (Top Products Dashboard)

SELECT DISTINCT payment_method FROM orders;                         -- unique payment methods
SELECT DISTINCT category FROM products;                             -- unique categories
SELECT * FROM products ORDER BY price DESC LIMIT 5;                 -- top 5 expensive
SELECT * FROM products ORDER BY price ASC  LIMIT 5;                 -- cheapest 5
SELECT * FROM orders   ORDER BY order_date DESC LIMIT 3;            -- latest 3 orders
SELECT seller_name, rating FROM sellers ORDER BY rating DESC;       -- sellers by rating
SELECT seller_name, rating FROM sellers ORDER BY rating DESC LIMIT 3;  -- best-rated sellers
