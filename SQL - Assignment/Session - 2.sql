CREATE DATABASE sql_select_assignment;
USE sql_select_assignment;

-- Table 1: restaurants

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(100),
    location VARCHAR(100),
    rating DECIMAL(2,1)
);


-- Table 2: zomato_reviews

CREATE TABLE zomato_reviews (
    review_id INT PRIMARY KEY,
    name VARCHAR(100),
    rating DECIMAL(2,1),
    review VARCHAR(255)
);

-- Table 3: movies

CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    movie_name VARCHAR(100),
    release_year INT,
    genre VARCHAR(50)
);

-- Table 4: products

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2),
    category VARCHAR(50)
);


-- Insert sample data into all tables

-- 1. restaurants
INSERT INTO restaurants VALUES
(1, 'Dominos', 'Ahmedabad', 4.2),
(2, 'Pizza Hut', 'Surat', 4.0),
(3, 'McDonalds', 'Vadodara', 4.3),
(4, 'Subway', 'Ahmedabad', 4.1);

-- 2. zomato_reviews
INSERT INTO zomato_reviews VALUES
(1, 'Dhara', 4.5, 'Good food and service'),
(2, 'Priya', 4.0, 'Nice restaurant'),
(3, 'Riya', 3.5, 'Average experience'),
(4, 'Neha', 5.0, 'Excellent food');

-- 3. movies
INSERT INTO movies VALUES
(1, '3 Idiots', 2009, 'Comedy'),
(2, 'Dangal', 2016, 'Drama'),
(3, 'KGF', 2018, 'Action'),
(4, 'Pathaan', 2023, 'Action');

-- 4. products
INSERT INTO products VALUES
(1, 'Laptop', 55000, 'Electronics'),
(2, 'Mobile', 25000, 'Electronics'),
(3, 'Keyboard', 1200, 'Accessories'),
(4, 'Mouse', 600, 'Accessories');

SELECT * FROM restaurants;

SELECT name, rating
FROM zomato_reviews;

SELECT
    movie_name AS 'Title',
    release_year AS 'Year Released'
FROM movies;

-- This query retrieves all columns and records from the products table.
SELECT * FROM products;

SHOW TABLES;

SELECT * FROM restaurants;
SELECT * FROM zomato_reviews;
SELECT * FROM movies;
SELECT * FROM products;

-- STEP 1: CREATE DATABASE
CREATE DATABASE sql_filter_assignment;
USE sql_filter_assignment;

-- STEP 2: CREATE RESTAURANTS TABLE
CREATE TABLE restaurants (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    location VARCHAR(100),
    rating DECIMAL(2,1)
);

-- STEP 3: CREATE MOVIES TABLE
CREATE TABLE movies (
    id INT PRIMARY KEY,
    movie_name VARCHAR(100),
    release_year INT,
    genre VARCHAR(50)
);

-- STEP 4: CREATE PRODUCTS TABLE
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    category VARCHAR(50)
);

-- STEP 5: CREATE USERS TABLE
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100),
    followers INT
);

-- STEP 6: INSERT RESTAURANTS DATA
INSERT INTO restaurants VALUES
(1, 'Dominos', 'Ahmedabad', 4.5),
(2, 'Pizza Hut', 'Surat', 4.2),
(3, 'McDonalds', 'Vadodara', 4.8),
(4, 'Subway', 'Ahmedabad', 4.0),
(5, 'Honest', 'Gandhinagar', 4.6);

-- STEP 7: INSERT MOVIES DATA
INSERT INTO movies VALUES
(1, 'Pathaan', 2023, 'Action'),
(2, 'Jawan', 2023, 'Action'),
(3, 'Dangal', 2016, 'Drama'),
(4, 'War 2', 2025, 'Action'),
(5, 'Animal', 2023, 'Drama');

-- STEP 8: INSERT PRODUCTS DATA
INSERT INTO products VALUES
(1, 'Laptop', 55000, 'Electronics'),
(2, 'Mobile', 25000, 'Electronics'),
(3, 'Keyboard', 1200, 'Accessories'),
(4, 'Mouse', 400, 'Accessories'),
(5, 'Notebook', 100, 'Stationery');

-- STEP 9: INSERT USERS DATA
INSERT INTO users VALUES
(1, 'Dhara', 'Ahmedabad', 1500),
(2, 'Priya', 'Surat', 2000),
(3, 'Riya', 'Vadodara', 800),
(4, 'Neha', 'Gandhinagar', 2500),
(5, 'Krisha', 'Ahmedabad', 3000);

-- TASK 1: RESTAURANTS WITH RATING >= 4.5
SELECT *
FROM restaurants
WHERE rating >= 4.5;

-- TASK 2: MOVIES RELEASED AFTER 2020 WITH ACTION GENRE
SELECT *
FROM movies
WHERE release_year > 2020
AND genre = 'Action';

-- TASK 3: PRODUCTS NOT IN ELECTRONICS OR PRICE < 500
SELECT *
FROM products
WHERE category != 'Electronics'
OR price < 500;

-- TASK 4: USERS NOT FROM AHMEDABAD AND FOLLOWERS > 1000
SELECT *
FROM users
WHERE NOT city = 'Ahmedabad'
AND followers > 1000;

-- STEP 10: DISPLAY ALL TABLES
SHOW TABLES;