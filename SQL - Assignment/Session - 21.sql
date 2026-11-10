-- SESSION 21: SQL + Excel Integration (MySQL version)
-- The original task mentions SQL Server. These are equivalent MySQL examples
-- for practicing with a MySQL database and Excel Power Query.

-- Task 1: Select restaurant data for Excel Power Query.
-- In Excel, use Data > Get Data > From Database > From MySQL Database.
SELECT name, cuisine, rating
FROM Restaurants;

-- Task 2: Parameterized query example.
-- In Power Query, create a parameter named pCuisine and pass its value
-- through the connector/query. Example SQL for a selected cuisine:
-- Replace 'Chinese' with the value supplied by your Power Query parameter.
SELECT name, cuisine, rating
FROM Restaurants
WHERE cuisine = 'Chinese';

-- Task 3: Refreshing data
-- In Excel, configure the MySQL connection and choose Data > Refresh All.
-- New source rows will appear after a successful refresh.

-- Task 4: Filter restaurants with rating above 4.0 for a dashboard.
SELECT name, cuisine, rating
FROM Restaurants
WHERE rating > 4.0
ORDER BY rating DESC;

-- Task 5: Restaurants in a rating range.
SELECT name, cuisine, rating
FROM Restaurants
WHERE rating BETWEEN 3.5 AND 5.0
ORDER BY rating DESC;

-- Excel/Power Query notes:
-- Manage Parameters can hold the selected cuisine/rating values.
-- For a fully dynamic parameterized connection, bind those parameters
-- in Power Query rather than leaving the example literal in production.
