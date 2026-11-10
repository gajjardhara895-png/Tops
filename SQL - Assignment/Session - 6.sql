-- STEP 1: CREATE DATABASE
CREATE DATABASE sql_aggregate_assignment;
USE sql_aggregate_assignment;

-- STEP 2: CREATE FOOD_ORDERS TABLE
CREATE TABLE food_orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(10,2)
);

-- STEP 3: CREATE SPOTIFY_PLAYLISTS TABLE
CREATE TABLE spotify_playlists (
    playlist_id INT PRIMARY KEY,
    user_id INT,
    song_id INT
);

-- STEP 4: CREATE BOOKMYSHOW_REVIEWS TABLE
CREATE TABLE bookmyshow_reviews (
    review_id INT PRIMARY KEY,
    movie_id INT,
    rating DECIMAL(2,1)
);

-- STEP 5: CREATE PAYTM_TRANSACTIONS TABLE
CREATE TABLE paytm_transactions (
    txn_id INT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(10,2)
);

-- STEP 6: CREATE MYNTRA_ORDERS TABLE
CREATE TABLE myntra_orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    total_price DECIMAL(10,2)
);

-- STEP 7: INSERT FOOD ORDERS DATA
INSERT INTO food_orders VALUES
(1, 101, 500),
(2, 101, 300),
(3, 102, 700),
(4, 102, 450),
(5, 103, 900),
(6, 101, 250);

-- STEP 8: INSERT SPOTIFY PLAYLIST DATA
INSERT INTO spotify_playlists VALUES
(1, 101, 501),
(2, 101, 502),
(3, 101, 503),
(4, 102, 504),
(5, 102, 505),
(6, 103, 506),
(7, 103, 507),
(8, 103, 508);

-- STEP 9: INSERT BOOKMYSHOW REVIEWS DATA
INSERT INTO bookmyshow_reviews VALUES
(1, 201, 4.5),
(2, 201, 4.0),
(3, 201, 5.0),
(4, 202, 3.5),
(5, 202, 4.0),
(6, 203, 4.8);

-- STEP 10: INSERT PAYTM TRANSACTIONS DATA
INSERT INTO paytm_transactions VALUES
(1, 101, 500),
(2, 101, 1200),
(3, 101, 300),
(4, 102, 2500),
(5, 102, 800),
(6, 103, 150),
(7, 103, 900);

-- STEP 11: INSERT MYNTRA ORDERS DATA
INSERT INTO myntra_orders VALUES
(1, 101, 1500),
(2, 101, 2500),
(3, 101, 1000),
(4, 102, 3000),
(5, 102, 2000),
(6, 103, 500),
(7, 103, 1200),
(8, 103, 1800);

-- TASK 1: CALCULATE TOTAL FOOD ORDER AMOUNT
SELECT SUM(amount) AS total_amount_spent
FROM food_orders;

-- TASK 2: COUNT SONGS ADDED BY EACH USER
SELECT user_id, COUNT(song_id) AS total_songs
FROM spotify_playlists
GROUP BY user_id;

-- TASK 3: CALCULATE AVERAGE MOVIE RATING
SELECT ROUND(AVG(rating), 1) AS average_rating
FROM bookmyshow_reviews;

-- TASK 4: FIND MINIMUM AND MAXIMUM TRANSACTION AMOUNT
SELECT
    user_id,
    MIN(amount) AS minimum_transaction,
    MAX(amount) AS maximum_transaction
FROM paytm_transactions
GROUP BY user_id;

-- TASK 5: USER-WISE ORDER SUMMARY
SELECT
    user_id,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(total_price), 2) AS average_order_value,
    MAX(total_price) AS highest_order_value
FROM myntra_orders
GROUP BY user_id;

-- STEP 12: DISPLAY ALL TABLES
SHOW TABLES;