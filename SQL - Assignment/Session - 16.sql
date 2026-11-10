
CREATE DATABASE string_function_assignment;
USE string_function_assignment;


-- Q1: CONCAT() - Combine first_name and last_name

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);

INSERT INTO users VALUES
(1, 'Dhara', 'Gajjar'),
(2, 'Rahul', 'Sharma'),
(3, 'Priya', 'Patel'),
(4, 'Amit', 'Shah');

SELECT
    CONCAT(first_name, ' ', last_name) AS full_name
FROM users;


-- Q2: UPPER() - Convert song titles into uppercase

CREATE TABLE playlists (
    song_id INT PRIMARY KEY,
    song_title VARCHAR(100)
);

INSERT INTO playlists VALUES
(1, 'Kesariya'),
(2, 'Tum Hi Ho'),
(3, 'Apna Bana Le'),
(4, 'Channa Mereya');

SELECT
    UPPER(song_title) AS uppercase_song_title
FROM playlists;


-- Q3: TRIM() - Remove leading and trailing spaces

CREATE TABLE food_items (
    item_id INT PRIMARY KEY,
    item_code VARCHAR(50)
);

INSERT INTO food_items VALUES
(1, '  FOOD101  '),
(2, '  FOOD102'),
(3, 'FOOD103  '),
(4, '  FOOD104  ');

SELECT
    TRIM(item_code) AS trimmed_item_code
FROM food_items;


-- Q4: RIGHT() - Extract last 7 characters from IMDb ID

CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    imdb_id VARCHAR(20)
);

INSERT INTO movies VALUES
(1, 'tt1234567'),
(2, 'tt7654321'),
(3, 'tt9876543'),
(4, 'tt1122334');

SELECT
    imdb_id,
    RIGHT(imdb_id, 7) AS movie_number
FROM movies;


-- Q5: REPLACE() - Replace dashes with underscores

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    sku_code VARCHAR(50)
);

INSERT INTO products VALUES
(1, 'MOB-123-XY'),
(2, 'LAP-456-AB'),
(3, 'TAB-789-CD'),
(4, 'ACC-321-EF');

SELECT
    sku_code,
    REPLACE(sku_code, '-', '_') AS updated_sku_code
FROM products;

