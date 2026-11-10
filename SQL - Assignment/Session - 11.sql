
CREATE DATABASE subquery_assignment;
USE subquery_assignment;

-- Q1: Restaurants with ratings higher than average rating

CREATE TABLE Restaurants (
    restaurant_id INT PRIMARY KEY,
    name VARCHAR(100),
    rating DECIMAL(3,1)
);

INSERT INTO Restaurants VALUES
(1, 'Dominos', 4.5),
(2, 'Pizza Hut', 3.8),
(3, 'McDonalds', 4.2),
(4, 'Subway', 3.5),
(5, 'Burger King', 4.8);

SELECT
    name,
    rating
FROM Restaurants
WHERE rating > (
    SELECT AVG(rating)
    FROM Restaurants
);


-- Q2: Products with average category price using scalar subquery

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    category VARCHAR(50)
);

INSERT INTO Products VALUES
(1, 'iPhone 15', 70000, 'Electronics'),
(2, 'Samsung S24', 65000, 'Electronics'),
(3, 'Laptop', 55000, 'Electronics'),
(4, 'Nike Shoes', 3000, 'Fashion'),
(5, 'Adidas Shoes', 4000, 'Fashion');

SELECT
    name,
    price,
    category,
    (
        SELECT AVG(p2.price)
        FROM Products p2
        WHERE p2.category = p1.category
    ) AS average_category_price
FROM Products p1;


-- Q3: Users having more playlists than average playlists per user

CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50)
);

CREATE TABLE Playlists (
    playlist_id INT PRIMARY KEY,
    user_id INT,
    playlist_name VARCHAR(100)
);

INSERT INTO Users VALUES
(1, 'Dhara'),
(2, 'Priya'),
(3, 'Rahul'),
(4, 'Amit');

INSERT INTO Playlists VALUES
(1, 1, 'Bollywood Songs'),
(2, 1, 'English Songs'),
(3, 1, 'Party Songs'),
(4, 2, 'Romantic Songs'),
(5, 3, 'Workout Songs'),
(6, 3, 'Travel Songs');

SELECT
    u.username,
    p.playlist_count
FROM Users u
INNER JOIN (
    SELECT
        user_id,
        COUNT(*) AS playlist_count
    FROM Playlists
    GROUP BY user_id
) p
ON u.user_id = p.user_id
WHERE p.playlist_count > (
    SELECT AVG(playlist_count)
    FROM (
        SELECT COUNT(*) AS playlist_count
        FROM Playlists
        GROUP BY user_id
    ) AS avg_playlists
);


-- Q4: Find users who placed orders above average order amount

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    total_amount DECIMAL(10,2)
);

INSERT INTO Orders VALUES
(1, 101, 500),
(2, 102, 1200),
(3, 103, 800),
(4, 101, 1500),
(5, 104, 300);

SELECT DISTINCT user_id
FROM Orders
WHERE total_amount > (
    SELECT AVG(total_amount)
    FROM Orders
);
