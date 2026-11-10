-- STEP 1: CREATE DATABASE
CREATE DATABASE sql_groupby_assignment;
USE sql_groupby_assignment;

-- STEP 2: CREATE FOOD_ORDERS TABLE
CREATE TABLE food_orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(10,2)
);

-- STEP 3: CREATE TRANSACTIONS TABLE
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(10,2),
    payment_method VARCHAR(50)
);

-- STEP 4: CREATE MOVIES TABLE
CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    genre VARCHAR(50),
    box_office_collection DECIMAL(12,2)
);

-- STEP 5: CREATE PLAYLIST TABLE
CREATE TABLE playlist (
    playlist_id INT PRIMARY KEY,
    user_id INT,
    song_id INT,
    duration INT
);

-- STEP 6: INSERT FOOD_ORDERS DATA
INSERT INTO food_orders VALUES
(1, 101, 500),
(2, 101, 300),
(3, 102, 700),
(4, 102, 450),
(5, 103, 900),
(6, 101, 250),
(7, 104, 600);

-- STEP 7: INSERT TRANSACTIONS DATA
INSERT INTO transactions VALUES
(1, 101, 500, 'UPI'),
(2, 102, 700, 'Cash'),
(3, 103, 1200, 'Credit Card'),
(4, 101, 300, 'UPI'),
(5, 102, 900, 'Cash'),
(6, 104, 1500, 'Credit Card'),
(7, 103, 400, 'UPI');

-- STEP 8: INSERT MOVIES DATA
-- Collection values are in crore rupees
INSERT INTO movies VALUES
(1, 'Action', 25.50),
(2, 'Comedy', 8.00),
(3, 'Drama', 15.75),
(4, 'Action', 30.00),
(5, 'Comedy', 5.50),
(6, 'Romance', 12.00),
(7, 'Drama', 10.00);

-- STEP 9: INSERT PLAYLIST DATA
-- Duration is in seconds
INSERT INTO playlist VALUES
(1, 101, 501, 2400),
(2, 101, 502, 2600),
(3, 101, 503, 2800),
(4, 102, 504, 1800),
(5, 102, 505, 2000),
(6, 103, 506, 3000),
(7, 103, 507, 2500),
(8, 104, 508, 4000),
(9, 104, 509, 3500);

-- TASK 1: COUNT TOTAL ORDERS PLACED BY EACH USER
SELECT
    user_id,
    COUNT(order_id) AS total_orders
FROM food_orders
GROUP BY user_id;

-- TASK 2: TOTAL AMOUNT SPENT BY EACH PAYMENT METHOD
SELECT
    payment_method,
    SUM(amount) AS total_amount
FROM transactions
GROUP BY payment_method;

-- TASK 3: GENRES WITH TOTAL BOX OFFICE COLLECTION ABOVE 10 CRORE
SELECT
    genre,
    SUM(box_office_collection) AS total_collection
FROM movies
GROUP BY genre
HAVING SUM(box_office_collection) > 10;

-- TASK 4: USERS WITH TOTAL PLAYLIST DURATION MORE THAN 7200 SECONDS
SELECT
    user_id,
    SUM(duration) AS total_duration
FROM playlist
GROUP BY user_id
HAVING SUM(duration) > 7200;

-- STEP 10: DISPLAY ALL TABLES
SHOW TABLES;