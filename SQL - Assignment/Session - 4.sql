-- STEP 1: CREATE DATABASE
CREATE DATABASE sql_operators_assignment;
USE sql_operators_assignment;

-- STEP 2: CREATE RESTAURANTS TABLE
CREATE TABLE Restaurants (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    location VARCHAR(100),
    rating DECIMAL(2,1)
);

-- STEP 3: CREATE PRODUCTS TABLE
CREATE TABLE Products (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    category VARCHAR(50)
);

-- STEP 4: CREATE USERS TABLE
CREATE TABLE Users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100)
);

-- STEP 5: CREATE SONGS TABLE
CREATE TABLE Songs (
    id INT PRIMARY KEY,
    song_name VARCHAR(100),
    artist_name VARCHAR(100)
);

-- STEP 6: INSERT RESTAURANTS DATA
INSERT INTO Restaurants VALUES
(1, 'Royal Cafe', 'Ahmedabad', 4.5),
(2, 'Food House', 'Surat', 4.2),
(3, 'Green Cafe', 'Vadodara', 4.3),
(4, 'Urban Cafe', 'Ahmedabad', 4.7),
(5, 'Pizza Point', 'Surat', 4.0);

-- STEP 7: INSERT PRODUCTS DATA
INSERT INTO Products VALUES
(1, 'Laptop', 55000, 'Electronics'),
(2, 'Mobile', 25000, 'Electronics'),
(3, 'Keyboard', 1200, 'Accessories'),
(4, 'Mouse', 500, 'Accessories'),
(5, 'Headphones', 1500, 'Electronics'),
(6, 'Notebook', 100, 'Stationery'),
(7, 'Smart Watch', 999, 'Electronics');

-- STEP 8: INSERT USERS DATA
INSERT INTO Users VALUES
(1, 'Dhara', 'Ahmedabad'),
(2, 'Priya', 'Surat'),
(3, 'Riya', 'Vadodara'),
(4, 'Neha', 'Mumbai'),
(5, 'Krisha', 'Ahmedabad'),
(6, 'Amit', 'Delhi');

-- STEP 9: INSERT SONGS DATA
INSERT INTO Songs VALUES
(1, 'Tum Hi Ho', 'Arijit Singh'),
(2, 'Kesariya', 'Arijit Singh'),
(3, 'Shape of You', 'Ed Sheeran'),
(4, 'Love Me Again', 'John Newman'),
(5, 'Apna Bana Le', 'Armaan Malik'),
(6, 'Perfect', 'Ed Sheeran');

-- TASK 1: RESTAURANTS WHOSE NAMES END WITH 'Cafe'
SELECT *
FROM Restaurants
WHERE name LIKE '%Cafe';

-- TASK 2: PRODUCTS WITH PRICE BETWEEN 500 AND 1500
SELECT *
FROM Products
WHERE price BETWEEN 500 AND 1500;

-- TASK 3: USERS FROM AHMEDABAD, SURAT OR VADODARA
SELECT *
FROM Users
WHERE city IN ('Ahmedabad', 'Surat', 'Vadodara');

-- TASK 4: SONGS WHERE ARTIST NAME CONTAINS 'ar'
SELECT *
FROM Songs
WHERE artist_name LIKE '%ar%';

-- STEP 10: DISPLAY ALL TABLES
SHOW TABLES;