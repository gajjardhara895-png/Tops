
CREATE DATABASE join_assignment;
USE join_assignment;

-- Q1: FULL OUTER JOIN - Influencers and Brands

CREATE TABLE influencers (
    influencer_id INT PRIMARY KEY,
    influencer_name VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE brands (
    brand_id INT PRIMARY KEY,
    brand_name VARCHAR(50),
    city VARCHAR(50)
);

INSERT INTO influencers VALUES
(1, 'Rahul', 'Ahmedabad'),
(2, 'Priya', 'Mumbai'),
(3, 'Amit', 'Delhi');

INSERT INTO brands VALUES
(1, 'Nike', 'Ahmedabad'),
(2, 'Adidas', 'Bangalore'),
(3, 'Puma', 'Mumbai');

SELECT i.influencer_name, b.brand_name
FROM influencers i
LEFT JOIN brands b ON i.city = b.city

UNION

SELECT i.influencer_name, b.brand_name
FROM influencers i
RIGHT JOIN brands b ON i.city = b.city;


-- Q2: SELF JOIN - Playlists

CREATE TABLE playlists (
    id INT PRIMARY KEY,
    playlist_name VARCHAR(100),
    parent_playlist_id INT
);

INSERT INTO playlists VALUES
(1, 'My Music', NULL),
(2, 'Bollywood Songs', 1),
(3, 'English Songs', 1),
(4, 'Arijit Singh Hits', 2);

SELECT
    p.playlist_name AS playlist_name,
    parent.playlist_name AS parent_playlist_name
FROM playlists p
LEFT JOIN playlists parent
ON p.parent_playlist_id = parent.id;


-- Q3: CROSS JOIN - Users and Offers

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE offers (
    offer_id INT PRIMARY KEY,
    offer_title VARCHAR(100)
);

INSERT INTO users VALUES
(1, 'Dhara', 'Ahmedabad'),
(2, 'Priya', 'Mumbai'),
(3, 'Rahul', 'Delhi');

INSERT INTO offers VALUES
(1, '50% Discount'),
(2, 'Free Delivery'),
(3, 'Buy 1 Get 1');

-- Flipkart-style campaigns can use these combinations
-- to identify suitable offers for different customers.

SELECT
    u.user_name,
    o.offer_title
FROM users u
CROSS JOIN offers o;


-- Q4: SELF JOIN - Employees and Managers

CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    manager_id INT
);

INSERT INTO employees VALUES
(1, 'Amit', NULL),
(2, 'Rahul', 1),
(3, 'Priya', 1),
(4, 'Neha', 2);

-- Display employees with their managers

SELECT
    e.name AS employee_name,
    m.name AS manager_name
FROM employees e
LEFT JOIN employees m
ON e.manager_id = m.id;

-- Display top-level managers only

SELECT name AS employee_name
FROM employees
WHERE manager_id IS NULL;


-- Q5: SELF JOIN - Users Living in the Same City

CREATE TABLE city_users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(50),
    city VARCHAR(50)
);

INSERT INTO city_users VALUES
(1, 'Dhara', 'Ahmedabad'),
(2, 'Priya', 'Mumbai'),
(3, 'Rahul', 'Ahmedabad'),
(4, 'Amit', 'Delhi'),
(5, 'Neha', 'Ahmedabad');

SELECT
    u1.user_name AS user1,
    u2.user_name AS user2,
    u1.city
FROM city_users u1
INNER JOIN city_users u2
ON u1.city = u2.city
AND u1.user_id < u2.user_id;

-- AI helped improve the query by using table aliases
-- and user_id < user_id comparison to avoid self-matches
-- and duplicate user pairs.
