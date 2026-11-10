
CREATE DATABASE union_assignment;
USE union_assignment;

-- Q1: Create AppOrders and InStoreOrders tables

CREATE TABLE AppOrders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    amount DECIMAL(10,2),
    order_date DATE
);

CREATE TABLE InStoreOrders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    amount DECIMAL(10,2),
    order_date DATE
);

-- Insert sample records into AppOrders

INSERT INTO AppOrders VALUES
(1, 'Dhara', 450.00, '2026-11-01'),
(2, 'Priya', 600.00, '2026-11-02'),
(3, 'Rahul', 350.00, '2026-11-03');

-- Insert sample records into InStoreOrders

INSERT INTO InStoreOrders VALUES
(4, 'Amit', 500.00, '2026-11-01'),
(5, 'Neha', 700.00, '2026-11-02'),
(6, 'Priya', 300.00, '2026-11-03');


-- Q2: UNION - Display unique customer names

SELECT customer_name
FROM AppOrders

UNION

SELECT customer_name
FROM InStoreOrders;


-- Q3: UNION ALL - Display all orders

SELECT order_id, customer_name, amount, order_date
FROM AppOrders

UNION ALL

SELECT order_id, customer_name, amount, order_date
FROM InStoreOrders;


-- Q4: Add duplicate customer name in both tables

INSERT INTO AppOrders VALUES
(7, 'Dhara', 800.00, '2026-11-04');

INSERT INTO InStoreOrders VALUES
(8, 'Dhara', 550.00, '2026-11-04');


-- UNION - Removes duplicate customer names

SELECT customer_name
FROM AppOrders

UNION

SELECT customer_name
FROM InStoreOrders;


-- UNION ALL - Includes duplicate customer names

SELECT customer_name
FROM AppOrders

UNION ALL

SELECT customer_name
FROM InStoreOrders;


-- Compare result counts

SELECT 'UNION' AS query_type,
       COUNT(*) AS total_records
FROM (
    SELECT customer_name FROM AppOrders
    UNION
    SELECT customer_name FROM InStoreOrders
) AS union_result

UNION ALL

SELECT 'UNION ALL' AS query_type,
       COUNT(*) AS total_records
FROM (
    SELECT customer_name FROM AppOrders
    UNION ALL
    SELECT customer_name FROM InStoreOrders
) AS union_all_result;
