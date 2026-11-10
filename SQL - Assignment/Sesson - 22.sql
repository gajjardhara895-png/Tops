-- SESSION 22: SQL + Python Integration (MySQL version)
-- Topics: pandas read_sql(), Jupyter SQL magic, SQL + Python for EDA
-- The source assignment mentions SQLite. These SQL statements use MySQL
-- so they can be practiced with your MySQL database.

-- Task 1: Select restaurant records (use this query with pandas.read_sql)
SELECT name, cuisine, rating
FROM restaurants;

-- Python example:
-- import pandas as pd
-- from sqlalchemy import create_engine
-- engine = create_engine("mysql+pymysql://USER:PASSWORD@HOST:3306/your_database")
-- df = pd.read_sql("SELECT name, cuisine, rating FROM restaurants", engine)
-- print(df.head())

-- Task 2: Movies with rating above 8 (query for notebook SQL cell)
SELECT *
FROM movies
WHERE rating > 8;

-- Task 3: Last 100 orders, newest first
SELECT *
FROM orders
ORDER BY order_date DESC
LIMIT 100;

-- Python example for top 3 most ordered food items:
-- orders_df = pd.read_sql(
--     "SELECT * FROM orders ORDER BY order_date DESC LIMIT 100", engine
-- )
-- top_items = orders_df["food_item"].value_counts().head(3)
-- print(top_items)

-- Task 4: Team-wise match count query for a bar chart
-- Assumes matches has team1 and team2 columns.
SELECT team, COUNT(*) AS matches_played
FROM (
    SELECT team1 AS team FROM matches
    UNION ALL
    SELECT team2 AS team FROM matches
) AS team_appearances
GROUP BY team
ORDER BY matches_played DESC;

-- Python plotting example:
-- import matplotlib.pyplot as plt
-- team_counts = df["team"].value_counts()
-- team_counts.plot(kind="bar")
-- plt.xlabel("Team")
-- plt.ylabel("Matches Played")
-- plt.title("Matches Played by Team")
-- plt.tight_layout()
-- plt.show()

-- Task 5: Users who have placed more than 5 orders
SELECT
    u.user_id,
    u.username,
    COUNT(o.order_id) AS total_orders
FROM users AS u
INNER JOIN orders AS o
    ON u.user_id = o.user_id
GROUP BY u.user_id, u.username
HAVING COUNT(o.order_id) > 5;

-- Python example:
-- result_df = pd.read_sql("""SELECT u.user_id, u.username,
--     COUNT(o.order_id) AS total_orders
--     FROM users u
--     JOIN orders o ON u.user_id = o.user_id
--     GROUP BY u.user_id, u.username
--     HAVING COUNT(o.order_id) > 5""", engine)
