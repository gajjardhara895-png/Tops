CREATE DATABASE IF NOT EXISTS index_assignment;
USE index_assignment;

-- Q1: Create Orders Table with 10,000 Records

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    product_name VARCHAR(100),
    order_date DATE,
    total_amount DECIMAL(10,2)
);

INSERT INTO orders (user_id, product_name, order_date, total_amount)
SELECT
    FLOOR(1 + RAND() * 1000),
    CONCAT('Product ', n),
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY),
    ROUND(100 + RAND() * 5000, 2)
FROM (
    SELECT
        a.n + b.n * 10 + c.n * 100 + d.n * 1000 + 1 AS n
    FROM
        (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN
        (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    CROSS JOIN
        (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
    CROSS JOIN
        (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d
) AS numbers;

SELECT COUNT(*) AS total_records FROM orders;

-- Q1: Find Orders Before Index

SELECT *
FROM orders
WHERE user_id = 101;

-- Q2: Create Index on user_id

CREATE INDEX idx_user_id ON orders(user_id);

-- Q2: Find Orders After Index

SELECT *
FROM orders
WHERE user_id = 101;

-- Q3: Explain Query Before and After Index
-- Note: Run the first EXPLAIN before creating the index
-- to compare both execution plans.

EXPLAIN
SELECT *
FROM orders
WHERE user_id = 101;

-- Q4: Create Products Table

DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

INSERT INTO products (product_name, category, price)
VALUES
('Laptop', 'Electronics', 55000),
('Mobile', 'Electronics', 25000),
('Shirt', 'Fashion', 1200),
('Jeans', 'Fashion', 1800),
('Table', 'Furniture', 5000),
('Chair', 'Furniture', 2500);

CREATE INDEX idx_category ON products(category);

SELECT *
FROM products
WHERE category = 'Electronics';

EXPLAIN
SELECT *
FROM products
WHERE category = 'Electronics';

-- Q5: Optimize Query by Selecting Required Columns

SELECT
    order_id,
    user_id,
    order_date,
    total_amount
FROM orders
WHERE user_id = 101;

EXPLAIN
SELECT
    order_id,
    user_id,
    order_date,
    total_amount
FROM orders
WHERE user_id = 101;