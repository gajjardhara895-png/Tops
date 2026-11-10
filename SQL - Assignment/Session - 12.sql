
CREATE DATABASE cte_assignment;
USE cte_assignment;


-- Q1: WITH Clause - Top 3 Most Followed Spotify Artists

CREATE TABLE SpotifyArtists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100),
    followers BIGINT
);

INSERT INTO SpotifyArtists VALUES
(1, 'Arijit Singh', 50000000),
(2, 'Taylor Swift', 120000000),
(3, 'Ed Sheeran', 100000000),
(4, 'Justin Bieber', 90000000),
(5, 'Shreya Ghoshal', 40000000);

WITH TopArtists AS (
    SELECT artist_id, name, followers
    FROM SpotifyArtists
    ORDER BY followers DESC
    LIMIT 3
)
SELECT *
FROM TopArtists;


-- Q2: CTE - Monthly Sales Totals for Flipkart Orders in 2023

CREATE TABLE FlipkartOrders (
    order_id INT PRIMARY KEY,
    user_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2)
);

INSERT INTO FlipkartOrders VALUES
(1, 101, '2023-01-15', 5000),
(2, 102, '2023-01-20', 7000),
(3, 103, '2023-02-10', 12000),
(4, 104, '2023-02-18', 8000),
(5, 105, '2023-03-05', 15000),
(6, 101, '2023-03-20', 10000),
(7, 102, '2023-04-12', 9000);

WITH MonthlyTotals AS (
    SELECT
        MONTH(order_date) AS month_number,
        MONTHNAME(order_date) AS month_name,
        SUM(total_amount) AS total_sales
    FROM FlipkartOrders
    WHERE YEAR(order_date) = 2023
    GROUP BY MONTH(order_date), MONTHNAME(order_date)
)
SELECT *
FROM MonthlyTotals
ORDER BY total_sales DESC
LIMIT 1;


-- Q3: Recursive CTE - Generate Next 7 Days Calendar

CREATE TABLE CalendarDays (
    day_date DATE
);

WITH RECURSIVE DateList AS (
    SELECT CURDATE() AS day_date

    UNION ALL

    SELECT DATE_ADD(day_date, INTERVAL 1 DAY)
    FROM DateList
    WHERE day_date < DATE_ADD(CURDATE(), INTERVAL 6 DAY)
)
SELECT day_date
FROM DateList;


-- Q4: CTE - Restaurants in Cities with Average Rating Above 4.0

CREATE TABLE ZomatoRestaurants (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50),
    rating DECIMAL(3,1)
);

INSERT INTO ZomatoRestaurants VALUES
(1, 'Dominos', 'Ahmedabad', 4.5),
(2, 'Pizza Hut', 'Ahmedabad', 4.2),
(3, 'McDonalds', 'Mumbai', 3.8),
(4, 'Burger King', 'Mumbai', 4.1),
(5, 'Subway', 'Delhi', 4.6),
(6, 'KFC', 'Delhi', 4.8);

WITH CityAverage AS (
    SELECT
        city,
        AVG(rating) AS average_rating
    FROM ZomatoRestaurants
    GROUP BY city
)
SELECT
    r.id,
    r.name,
    r.city,
    r.rating,
    c.average_rating
FROM ZomatoRestaurants r
JOIN CityAverage c
ON r.city = c.city
WHERE c.average_rating > 4.0;


-- Q5: CTE - IPL Teams Scoring More Than 2000 Runs in 2023

CREATE TABLE IPLMatches (
    match_id INT PRIMARY KEY,
    team VARCHAR(100),
    runs INT,
    match_year INT
);

INSERT INTO IPLMatches VALUES
(1, 'CSK', 450, 2023),
(2, 'CSK', 500, 2023),
(3, 'CSK', 600, 2023),
(4, 'MI', 700, 2023),
(5, 'MI', 650, 2023),
(6, 'MI', 800, 2023),
(7, 'RCB', 500, 2023),
(8, 'RCB', 600, 2023),
(9, 'GT', 400, 2023),
(10, 'GT', 500, 2023);

WITH TeamRuns AS (
    SELECT
        team,
        SUM(runs) AS total_runs
    FROM IPLMatches
    WHERE match_year = 2023
    GROUP BY team
)
SELECT
    team,
    total_runs
FROM TeamRuns
WHERE total_runs > 2000
ORDER BY total_runs DESC;

-- AI helped me create the CTE, calculate total runs
-- team-wise, filter the year 2023, and apply the
-- condition to display teams scoring more than 2000 runs.
