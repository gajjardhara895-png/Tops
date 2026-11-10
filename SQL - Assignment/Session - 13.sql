
CREATE DATABASE window_function_assignment;
USE window_function_assignment;


-- Q1: OVER() - Display each order with total amount of all orders

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    order_amount DECIMAL(10,2),
    app_name VARCHAR(50)
);

INSERT INTO Orders VALUES
(1, 101, 500, 'Zomato'),
(2, 102, 1200, 'Swiggy'),
(3, 101, 800, 'Flipkart'),
(4, 103, 1500, 'Zomato'),
(5, 102, 700, 'Swiggy'),
(6, 104, 2000, 'Flipkart'),
(7, 103, 900, 'Zomato'),
(8, 101, 1100, 'Swiggy'),
(9, 104, 600, 'Flipkart'),
(10, 102, 1300, 'Zomato');

SELECT
    order_id,
    user_id,
    order_amount,
    app_name,
    SUM(order_amount) OVER() AS total_order_amount
FROM Orders;


-- Q2: OVER(PARTITION BY user_id) - Average order amount per user

SELECT
    user_id,
    order_id,
    order_amount,
    AVG(order_amount) OVER(
        PARTITION BY user_id
    ) AS user_average_amount
FROM Orders;


-- Q3: SUM() OVER(PARTITION BY user_id) - Total song duration per user

CREATE TABLE Playlist (
    song_id INT PRIMARY KEY,
    user_id INT,
    duration_sec INT
);

INSERT INTO Playlist VALUES
(1, 101, 210),
(2, 101, 180),
(3, 102, 240),
(4, 102, 200),
(5, 103, 190),
(6, 103, 220),
(7, 101, 250),
(8, 104, 300),
(9, 104, 180),
(10, 102, 210);

SELECT
    song_id,
    user_id,
    duration_sec,
    SUM(duration_sec) OVER(
        PARTITION BY user_id
    ) AS total_duration_per_user
FROM Playlist;


-- Q4: Window Functions - Movie average rating and difference

CREATE TABLE MovieRatings (
    rating_id INT PRIMARY KEY,
    user_id INT,
    movie_name VARCHAR(100),
    rating DECIMAL(2,1)
);

INSERT INTO MovieRatings VALUES
(1, 101, 'Jawan', 5),
(2, 102, 'Jawan', 4),
(3, 103, 'Jawan', 3),
(4, 101, 'Pathaan', 4),
(5, 102, 'Pathaan', 5),
(6, 103, 'Pathaan', 4),
(7, 104, 'Animal', 5),
(8, 101, 'Animal', 4),
(9, 102, 'Animal', 3),
(10, 104, 'Jawan', 5);

SELECT
    rating_id,
    user_id,
    movie_name,
    rating,
    AVG(rating) OVER(
        PARTITION BY movie_name
    ) AS average_movie_rating,
    rating - AVG(rating) OVER(
        PARTITION BY movie_name
    ) AS rating_difference
FROM MovieRatings;

