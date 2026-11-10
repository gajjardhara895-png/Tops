-- CASE STUDY: Zomato Bangalore Restaurants - MySQL
-- Goal: Analyze restaurant performance, pricing, ratings and cuisines.
--
-- IMPORTANT:
-- Dataset column names vary between Kaggle versions.
-- This script assumes a table named zomato_bangalore with columns:
-- name, location, rate, votes, cuisines, approx_cost_for_two, rest_type.
-- If your CSV uses different column names, replace them in the queries.
-- If rate contains text such as '4.1/5' or 'NEW', clean it before AVG().
-- The queries below assume rate is a numeric column.

-- Task 1: Top 5 highest-rated restaurants in Koramangala
SELECT
    name,
    AVG(rate) AS average_rating,
    SUM(votes) AS total_votes
FROM zomato_bangalore
WHERE location = 'Koramangala'
GROUP BY name
ORDER BY average_rating DESC, total_votes DESC
LIMIT 5;

-- Task 2: Unique cuisines in Indiranagar and restaurant count per cuisine.
-- If cuisines contains comma-separated values, this counts each full
-- cuisines field as stored; split it into individual cuisines in Power Query
-- for a true count per individual cuisine.
SELECT
    cuisines,
    COUNT(*) AS restaurant_count
FROM zomato_bangalore
WHERE location = 'Indiranagar'
GROUP BY cuisines
ORDER BY restaurant_count DESC;

-- Task 3: Average cost for two by restaurant type
SELECT
    rest_type,
    ROUND(AVG(approx_cost_for_two), 2) AS average_cost_for_two
FROM zomato_bangalore
GROUP BY rest_type
ORDER BY average_cost_for_two DESC;

-- Task 4: Low-rated restaurants with more than 200 votes
SELECT
    name,
    location,
    rate,
    votes,
    rest_type
FROM zomato_bangalore
WHERE rate < 3.0
  AND votes > 200
ORDER BY votes DESC;

-- Possible marketing action (business suggestion):
-- Review customer feedback, improve service/food consistency, and run
-- a limited targeted promotion to encourage repeat visits and new reviews.

-- Task 5: Segment restaurants by cost for two
SELECT
    name,
    location,
    approx_cost_for_two,
    CASE
        WHEN approx_cost_for_two < 500 THEN 'Budget'
        WHEN approx_cost_for_two <= 1500 THEN 'Mid-range'
        ELSE 'Premium'
    END AS market_category
FROM zomato_bangalore
ORDER BY approx_cost_for_two;
