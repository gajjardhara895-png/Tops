
CREATE DATABASE view_assignment;
USE view_assignment;


-- Q1: Create TopRatedRestaurants View

CREATE TABLE Restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE RestaurantReviews (
    review_id INT PRIMARY KEY,
    restaurant_id INT,
    rating DECIMAL(2,1)
);

INSERT INTO Restaurants VALUES
(1, 'Dominos', 'Ahmedabad'),
(2, 'Pizza Hut', 'Mumbai'),
(3, 'McDonalds', 'Delhi'),
(4, 'Burger King', 'Ahmedabad'),
(5, 'Subway', 'Mumbai');

INSERT INTO RestaurantReviews VALUES
(1, 1, 4.5),
(2, 1, 4.2),
(3, 2, 3.8),
(4, 2, 4.0),
(5, 3, 4.8),
(6, 3, 4.5),
(7, 4, 3.5),
(8, 4, 3.8),
(9, 5, 4.6),
(10, 5, 4.9);

CREATE OR REPLACE VIEW TopRatedRestaurants AS
SELECT
    r.restaurant_name,
    AVG(rv.rating) AS average_rating,
    COUNT(rv.review_id) AS total_reviews
FROM Restaurants AS r
INNER JOIN RestaurantReviews AS rv
    ON r.restaurant_id = rv.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name
HAVING AVG(rv.rating) > 4.0;

SELECT * FROM TopRatedRestaurants;


-- Q2: Update View to Include City Column

CREATE OR REPLACE VIEW TopRatedRestaurants AS
SELECT
    r.restaurant_name,
    r.city,
    AVG(rv.rating) AS average_rating,
    COUNT(rv.review_id) AS total_reviews
FROM Restaurants r
INNER JOIN RestaurantReviews rv
ON r.restaurant_id = rv.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name, r.city
HAVING AVG(rv.rating) > 4.0;

SELECT * FROM TopRatedRestaurants;


-- Q3: Try to Update Average Rating Through the View

UPDATE TopRatedRestaurants
SET average_rating = 5.0
WHERE restaurant_name = 'Dominos';

-- This UPDATE is expected to fail because average_rating
-- is calculated using the AVG() aggregate function.
-- MySQL does not allow direct updates to aggregated
-- columns through this view.


-- Q4: Create DailyOrderSummary View

CREATE TABLE SwiggyOrders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    order_date DATE,
    total_amount DECIMAL(10,2)
);

INSERT INTO SwiggyOrders VALUES
(1, 'Dhara', CURDATE() - INTERVAL 1 DAY, 450),
(2, 'Priya', CURDATE() - INTERVAL 1 DAY, 300),
(3, 'Rahul', CURDATE() - INTERVAL 2 DAY, 500),
(4, 'Amit', CURDATE() - INTERVAL 3 DAY, 700),
(5, 'Neha', CURDATE() - INTERVAL 3 DAY, 250),
(6, 'Dhara', CURDATE() - INTERVAL 5 DAY, 600),
(7, 'Priya', CURDATE() - INTERVAL 10 DAY, 400),
(8, 'Rahul', CURDATE() - INTERVAL 15 DAY, 350),
(9, 'Amit', CURDATE() - INTERVAL 20 DAY, 800),
(10, 'Neha', CURDATE() - INTERVAL 35 DAY, 500);

CREATE VIEW DailyOrderSummary AS
SELECT
    order_date,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_revenue
FROM SwiggyOrders
WHERE order_date >= CURDATE() - INTERVAL 30 DAY
AND order_date <= CURDATE()
GROUP BY order_date;

SELECT * FROM DailyOrderSummary
ORDER BY order_date DESC;


-- Q5: Three Good Practices for Creating SQL Views

-- 1. Use meaningful column names.
-- Example: Use total_sales instead of SUM(price).

-- 2. Avoid unnecessary columns.
-- Example: Include only order_date, product_name,
-- and total_revenue in a Flipkart sales dashboard.

-- 3. Apply proper filters and aggregation.
-- Example: Filter Flipkart orders by 2026 and
-- GROUP BY month to calculate monthly sales.
