
CREATE DATABASE case_when_assignment;
USE case_when_assignment;


-- Q1: CASE WHEN - Classify Food Orders

CREATE TABLE FoodOrders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    total_amount DECIMAL(10,2)
);

INSERT INTO FoodOrders VALUES
(1, 'Dhara', 200),
(2, 'Priya', 500),
(3, 'Rahul', 1200),
(4, 'Amit', 800),
(5, 'Neha', 250);

SELECT
    order_id,
    customer_name,
    total_amount,
    CASE
        WHEN total_amount < 300 THEN 'Small'
        WHEN total_amount BETWEEN 300 AND 999 THEN 'Medium'
        WHEN total_amount >= 1000 THEN 'Large'
    END AS order_category
FROM FoodOrders;


-- Q2: CASE WHEN - Classify Movies by Rating

CREATE TABLE Movies (
    movie_id INT PRIMARY KEY,
    movie_name VARCHAR(100),
    rating DECIMAL(3,1)
);

INSERT INTO Movies VALUES
(1, 'Jawan', 8.5),
(2, 'Pathaan', 7.5),
(3, 'Animal', 9.0),
(4, 'Dream Girl', 4.5),
(5, 'Dunki', 6.8);

SELECT
    movie_id,
    movie_name,
    rating,
    CASE
        WHEN rating >= 8 THEN 'Blockbuster'
        WHEN rating >= 5 AND rating < 8 THEN 'Hit'
        ELSE 'Average'
    END AS popularity
FROM Movies;


-- Q3: CASE WHEN - Categorize Flipkart Products by Price

CREATE TABLE FlipkartProducts (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);

INSERT INTO FlipkartProducts VALUES
(1, 'Mouse', 300),
(2, 'Keyboard', 800),
(3, 'Headphones', 1500),
(4, 'Laptop', 55000),
(5, 'Mobile Cover', 200),
(6, 'Smart Watch', 2500);

SELECT
    product_id,
    product_name,
    price,
    CASE
        WHEN price < 500 THEN 'Budget'
        WHEN price BETWEEN 500 AND 2000 THEN 'Standard'
        WHEN price > 2000 THEN 'Premium'
    END AS price_category
FROM FlipkartProducts;


-- Q4: CASE WHEN - Categorize Spotify Tracks by Duration

CREATE TABLE SpotifyTracks (
    track_id INT PRIMARY KEY,
    track_name VARCHAR(100),
    duration_sec INT
);

INSERT INTO SpotifyTracks VALUES
(1, 'Kesariya', 240),
(2, 'Tum Hi Ho', 260),
(3, 'Short Song', 150),
(4, 'Long Song', 350),
(5, 'Apna Bana Le', 220),
(6, 'Extended Track', 400);

SELECT
    track_id,
    track_name,
    duration_sec,
    CASE
        WHEN duration_sec < 180 THEN 'Short'
        WHEN duration_sec BETWEEN 180 AND 300 THEN 'Medium'
        WHEN duration_sec > 300 THEN 'Long'
    END AS duration_label
FROM SpotifyTracks;

