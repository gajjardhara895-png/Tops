-- STEP 1: CREATE DATABASE
CREATE DATABASE sql_sorting_assignment;
USE sql_sorting_assignment;

-- STEP 2: CREATE ORDERS TABLE
CREATE TABLE orders (
    id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    payment_method VARCHAR(50),
    total_amount DECIMAL(10,2)
);

-- STEP 3: CREATE USERS TABLE
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100)
);

-- STEP 4: CREATE BOOKINGS TABLE
CREATE TABLE bookings (
    id INT PRIMARY KEY,
    movie_name VARCHAR(100),
    customer_name VARCHAR(100),
    booking_date DATE
);

-- STEP 5: CREATE PRODUCTS TABLE
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    sold_count INT
);

-- STEP 6: INSERT ORDERS DATA
INSERT INTO orders VALUES
(1, 'Dhara', 'UPI', 500),
(2, 'Priya', 'Cash', 700),
(3, 'Riya', 'Credit Card', 1200),
(4, 'Neha', 'UPI', 300),
(5, 'Amit', 'Debit Card', 900),
(6, 'Krisha', 'Cash', 450);

-- STEP 7: INSERT USERS DATA
INSERT INTO users VALUES
(1, 'Dhara', 'Ahmedabad'),
(2, 'Priya', 'Surat'),
(3, 'Riya', 'Vadodara'),
(4, 'Neha', 'Ahmedabad'),
(5, 'Amit', 'Mumbai'),
(6, 'Krisha', 'Surat'),
(7, 'Rahul', 'Delhi');

-- STEP 8: INSERT BOOKINGS DATA
INSERT INTO bookings VALUES
(1, 'Jawan', 'Dhara', '2026-11-01'),
(2, 'Pathaan', 'Priya', '2026-11-03'),
(3, 'Dangal', 'Riya', '2026-10-25'),
(4, 'Animal', 'Neha', '2026-11-05'),
(5, 'KGF', 'Amit', '2026-11-06'),
(6, '3 Idiots', 'Krisha', '2026-10-28'),
(7, 'War 2', 'Rahul', '2026-11-07');

-- STEP 9: INSERT PRODUCTS DATA
INSERT INTO products VALUES
(1, 'Laptop', 'Electronics', 500),
(2, 'Mobile', 'Electronics', 900),
(3, 'Keyboard', 'Accessories', 300),
(4, 'Mouse', 'Accessories', 700),
(5, 'Headphones', 'Electronics', 850),
(6, 'Smart Watch', 'Electronics', 650),
(7, 'Shoes', 'Fashion', 400),
(8, 'T-Shirt', 'Fashion', 600),
(9, 'Backpack', 'Accessories', 250),
(10, 'Monitor', 'Electronics', 750),
(11, 'Tablet', 'Electronics', 950),
(12, 'Printer', 'Electronics', 350);

-- TASK 1: FIND UNIQUE PAYMENT METHODS
SELECT DISTINCT payment_method
FROM orders;

-- TASK 2: DISPLAY UNIQUE CITIES IN A-Z ORDER
SELECT DISTINCT city
FROM users
ORDER BY city ASC;

-- TASK 3: DISPLAY TOP 5 MOST RECENT MOVIE BOOKINGS
SELECT *
FROM bookings
ORDER BY booking_date DESC
LIMIT 5;

-- TASK 4: DISPLAY TOP 10 BEST-SELLING PRODUCTS
SELECT name, sold_count
FROM products
ORDER BY sold_count DESC
LIMIT 10;

-- STEP 10: DISPLAY ALL TABLES
SHOW TABLES;