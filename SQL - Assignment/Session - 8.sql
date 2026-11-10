-- STEP 1: CREATE DATABASE
CREATE DATABASE sql_joins_assignment;
USE sql_joins_assignment;

-- STEP 2: CREATE USERS TABLE
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    username VARCHAR(100),
    city VARCHAR(100)
);

-- STEP 3: CREATE ORDERS TABLE
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    product VARCHAR(100),
    amount DECIMAL(10,2)
);

-- STEP 4: INSERT USERS DATA
INSERT INTO Users VALUES
(1, 'Dhara', 'Ahmedabad'),
(2, 'Priya', 'Surat'),
(3, 'Riya', 'Vadodara'),
(4, 'Neha', 'Gandhinagar');

-- STEP 5: INSERT ORDERS DATA
-- User 4 has no orders.
-- User 999 does not exist in Users table.
INSERT INTO Orders VALUES
(101, 1, 'Pizza', 500),
(102, 1, 'Burger', 250),
(103, 2, 'Sandwich', 300),
(104, 3, 'Biryani', 450),
(105, 2, 'Pasta', 350),
(106, 999, 'Cold Coffee', 150);

-- TASK 2: INNER JOIN
-- Display usernames and products for users who placed orders.
SELECT
    Users.username,
    Orders.product
FROM Users
INNER JOIN Orders
ON Users.user_id = Orders.user_id;

-- TASK 3: LEFT JOIN
-- Display all users and their ordered products.
-- Users without orders will show NULL.
SELECT
    Users.username,
    Orders.product
FROM Users
LEFT JOIN Orders
ON Users.user_id = Orders.user_id;

-- TASK 4: RIGHT JOIN
-- Display all orders and their corresponding usernames.
-- If user_id does not exist, username will show NULL.
SELECT
    Orders.order_id,
    Orders.user_id,
    Users.username,
    Orders.product,
    Orders.amount
FROM Users
RIGHT JOIN Orders
ON Users.user_id = Orders.user_id;

-- STEP 6: CREATE CUSTOMER SEGMENTS TABLE
CREATE TABLE CustomerSegments (
    segment_id INT PRIMARY KEY,
    segment_name VARCHAR(100)
);

-- STEP 7: INSERT CUSTOMER SEGMENTS
INSERT INTO CustomerSegments VALUES
(1, 'Premium'),
(2, 'Regular'),
(3, 'New Customer');

-- STEP 8: ADD SEGMENT_ID COLUMN TO USERS
ALTER TABLE Users
ADD segment_id INT;

-- STEP 9: ASSIGN SEGMENTS TO USERS
UPDATE Users
SET segment_id = 1
WHERE user_id = 1;

UPDATE Users
SET segment_id = 2
WHERE user_id = 2;

UPDATE Users
SET segment_id = 3
WHERE user_id = 3;

UPDATE Users
SET segment_id = 2
WHERE user_id = 4;

-- STEP 10: ADD FOREIGN KEY
ALTER TABLE Users
ADD CONSTRAINT fk_user_segment
FOREIGN KEY (segment_id)
REFERENCES CustomerSegments(segment_id);

-- TASK 5: JOIN USERS, CUSTOMER SEGMENTS AND ORDERS
-- Display username, segment name and total order amount.
SELECT
    Users.username,
    CustomerSegments.segment_name,
    COALESCE(SUM(Orders.amount), 0) AS total_order_amount
FROM Users
INNER JOIN CustomerSegments
ON Users.segment_id = CustomerSegments.segment_id
LEFT JOIN Orders
ON Users.user_id = Orders.user_id
GROUP BY
    Users.user_id,
    Users.username,
    CustomerSegments.segment_name;

-- STEP 11: DISPLAY ALL TABLES
SHOW TABLES;

-- STEP 12: CHECK ALL TABLE DATA
SELECT * FROM Users;
SELECT * FROM Orders;
SELECT * FROM CustomerSegments;