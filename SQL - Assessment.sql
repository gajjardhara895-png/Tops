/*
===============================================================================
DATA ANALYTICS - MODULE 4 SQL ASSESSMENT (M4-A1)
MySQL 8.0+
Complete solution: Sections A, B, C and D

HOW TO RUN:
1. Open MySQL Workbench.
2. Open this .sql file.
3. Execute the script from top to bottom.
4. If your MySQL version is older than 8.0, CTEs and window functions may fail.
5. Section D includes an AI-style first draft and a corrected query for testing.

Note: Sample data is fictional and created only for this assessment.
===============================================================================
*/

CREATE DATABASE IF NOT EXISTS m4a1_assessment;
USE m4a1_assessment;

-- ============================================================================
-- SECTION A - CONCEPT APPLICATION (Written answers in SQL comments)
-- ============================================================================

/*
A1. GROUP BY and HAVING
GROUP BY groups rows by restaurant, allowing SUM(total_amount) and
COUNT(order_id) to calculate revenue and order count for each restaurant.
HAVING filters the grouped result, for example:
HAVING SUM(total_amount) > 100000 AND COUNT(order_id) >= 50.
WHERE filters individual rows before aggregation, so it cannot directly
filter an aggregate such as SUM(total_amount). Replacing HAVING with
WHERE SUM(...) would cause an invalid use of group function error in MySQL.

A2. JOIN for all registered customers
Use LEFT JOIN from customers to orders. It keeps every customer from the
left table and returns NULL for order columns when no order exists.
INNER JOIN returns only matching customer/order rows, so customers who
never ordered would disappear from the report.

A3. Subquery for faster delivery agents
Use a scalar subquery in WHERE:
WHERE agent_average < (SELECT AVG(delivery_time_mins) FROM deliveries).
The inner query returns one value (the overall average), so a scalar
subquery is appropriate. A table subquery is not needed. A scalar
subquery in SELECT can also be valid if it returns one value; the main
reason to put it in WHERE here is that we are filtering agents by the
overall average, not merely displaying the average.

A4. RANK() versus DENSE_RANK()
RANK() gives tied rows the same rank and leaves a gap after the tie.
DENSE_RANK() gives tied rows the same rank but does not leave a gap.
Example for revenues 9000, 9000, 7000:
RANK()       = 1, 1, 3
DENSE_RANK() = 1, 1, 2
For a top-three revenue-level report, DENSE_RANK() includes the next
distinct revenue level as rank 3. RANK() would skip rank 2 in this example.

A5. CASE WHEN customer segmentation
CASE WHEN total_spend > 5000 THEN 'Platinum'
     WHEN total_spend >= 2000 THEN 'Gold'
     ELSE 'Standard' END
Exactly Rs 5,000 is Gold because it is not greater than 5,000 and it
satisfies the second condition. CASE checks WHEN conditions from top to
bottom and returns the first matching result.

A6. Database indexes
An index is a data structure (commonly a B-tree in MySQL/InnoDB) that
helps the engine locate matching rows without scanning every row.
An index on frequently used JOIN keys can reduce lookup work and improve
joins, filters and sorting. However, indexes consume storage and make
INSERT, UPDATE and DELETE slower because the index must also be maintained.
Too many indexes can increase storage, write cost and optimizer complexity.
Index columns based on actual query patterns and execution plans.
*/

-- ============================================================================
-- SECTION B - PRACTICAL CODING TASKS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TASK 1: Menu & Order Explorer
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS food_orders;
CREATE TABLE food_orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    restaurant_name VARCHAR(100) NOT NULL,
    item_ordered VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    price_per_item DECIMAL(10,2) NOT NULL,
    order_date DATE NOT NULL,
    city VARCHAR(50) NOT NULL
);

INSERT INTO food_orders
(order_id, customer_name, restaurant_name, item_ordered, quantity,
 price_per_item, order_date, city)
VALUES
(1,'Aarav Shah','Spice Hub','Paneer Tikka',2,320.00,'2026-10-01','Mumbai'),
(2,'Diya Patel','Burger Point','Classic Burger',1,250.00,'2026-10-02','Ahmedabad'),
(3,'Rohan Mehta','Pizza Town','Farmhouse Pizza',2,650.00,'2026-10-03','Surat'),
(4,'Meera Joshi','Spice Hub','Veg Thali',3,280.00,'2026-10-04','Mumbai'),
(5,'Kabir Desai','Royal Biryani','Chicken Biryani',2,420.00,'2026-10-05','Pune'),
(6,'Anaya Shah','Pizza Town','Cheese Pizza',1,550.00,'2026-10-06','Mumbai'),
(7,'Vivaan Patel','Burger Point','Double Burger',2,390.00,'2026-10-07','Surat'),
(8,'Isha Mehta','South Meals','Masala Dosa',3,180.00,'2026-10-08','Ahmedabad'),
(9,'Arjun Shah','Royal Biryani','Veg Biryani',2,350.00,'2026-10-09','Mumbai'),
(10,'Sara Khan','Pizza Town','Paneer Pizza',1,720.00,'2026-10-10','Pune');

-- B1(a): Display all Mumbai orders, highest item price first.
SELECT *
FROM food_orders
WHERE city = 'Mumbai'
ORDER BY price_per_item DESC;

-- B1(b): Distinct restaurants that have received orders.
SELECT DISTINCT restaurant_name
FROM food_orders
ORDER BY restaurant_name;

-- B1(c): Top 5 most expensive individual orders.
SELECT order_id, customer_name, restaurant_name, item_ordered,
       quantity, price_per_item, city
FROM food_orders
ORDER BY price_per_item DESC
LIMIT 5;


-- ----------------------------------------------------------------------------
-- TASK 2: Restaurant Revenue Summary
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS delivery_orders;
CREATE TABLE delivery_orders (
    order_id INT PRIMARY KEY,
    restaurant_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    order_date DATE NOT NULL
);

INSERT INTO delivery_orders
(order_id, restaurant_name, city, total_amount, order_status, order_date)
VALUES
(101,'Spice Hub','Mumbai',2200,'Completed','2026-10-01'),
(102,'Spice Hub','Mumbai',3100,'Completed','2026-10-02'),
(103,'Spice Hub','Mumbai',1800,'Completed','2026-10-03'),
(104,'Spice Hub','Mumbai',3500,'Completed','2026-10-04'),
(105,'Pizza Town','Surat',4200,'Completed','2026-10-01'),
(106,'Pizza Town','Surat',3900,'Completed','2026-10-02'),
(107,'Pizza Town','Surat',2800,'Completed','2026-10-03'),
(108,'Burger Point','Ahmedabad',1500,'Completed','2026-10-04'),
(109,'Burger Point','Ahmedabad',1900,'Completed','2026-10-05'),
(110,'Royal Biryani','Pune',5200,'Completed','2026-10-06'),
(111,'Royal Biryani','Pune',6100,'Completed','2026-10-07'),
(112,'South Meals','Ahmedabad',900,'Completed','2026-10-08');

-- B2(a,b,c): SUM, COUNT, AVG; only revenue above Rs 5,000;
-- classify qualifying restaurants using CASE WHEN.
SELECT
    restaurant_name,
    SUM(total_amount) AS total_revenue,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(total_amount), 2) AS average_order_value,
    CASE
        WHEN SUM(total_amount) > 10000 THEN 'High Revenue'
        ELSE 'Moderate Revenue'
    END AS revenue_category
FROM delivery_orders
GROUP BY restaurant_name
HAVING SUM(total_amount) > 5000
ORDER BY total_revenue DESC;


-- ----------------------------------------------------------------------------
-- TASK 3: Customer-Order-Restaurant Joined Report
-- Separate b_ table names keep this task independent from the capstone.
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS b_orders;
DROP TABLE IF EXISTS b_customers;
DROP TABLE IF EXISTS b_restaurants;

CREATE TABLE b_customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE b_restaurants (
    restaurant_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    cuisine_type VARCHAR(50),
    city VARCHAR(50) NOT NULL
);

CREATE TABLE b_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    amount DECIMAL(10,2) NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES b_customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES b_restaurants(restaurant_id)
);

INSERT INTO b_customers VALUES
(1,'Aarav Shah','Mumbai','9000000001'),
(2,'Diya Patel','Ahmedabad','9000000002'),
(3,'Rohan Mehta','Surat','9000000003'),
(4,'Meera Joshi','Mumbai','9000000004'),
(5,'Kabir Desai','Pune','9000000005'),
(6,'Anaya Shah','Ahmedabad','9000000006'),
(7,'Vivaan Patel','Surat','9000000007'),
(8,'Isha Mehta','Mumbai','9000000008');

INSERT INTO b_restaurants VALUES
(1,'Spice Hub','Indian','Mumbai'),
(2,'Burger Point','Fast Food','Ahmedabad'),
(3,'Pizza Town','Italian','Surat'),
(4,'Royal Biryani','Indian','Pune'),
(5,'South Meals','South Indian','Mumbai'),
(6,'Green Bowl','Healthy','Ahmedabad');

-- Customers 7 and 8 intentionally have no orders.
INSERT INTO b_orders VALUES
(201,1,1,850,'2026-10-01'),
(202,2,2,450,'2026-10-02'),
(203,3,3,1250,'2026-10-03'),
(204,4,5,620,'2026-10-04'),
(205,5,4,980,'2026-10-05'),
(206,6,6,540,'2026-10-06');

-- B3(a): INNER JOIN - only customers who placed orders.
SELECT
    o.order_id,
    c.name AS customer_name,
    r.name AS restaurant_name,
    o.amount,
    o.order_date
FROM b_orders AS o
INNER JOIN b_customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN b_restaurants AS r
    ON o.restaurant_id = r.restaurant_id
ORDER BY o.order_id;

-- B3(b): LEFT JOIN - all customers, including customers without orders.
SELECT
    c.customer_id,
    c.name AS customer_name,
    c.city AS customer_city,
    o.order_id,
    o.amount,
    o.order_date,
    r.name AS restaurant_name
FROM b_customers AS c
LEFT JOIN b_orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN b_restaurants AS r
    ON o.restaurant_id = r.restaurant_id
ORDER BY c.customer_id;

-- B3(c): Orders where customer and restaurant belong to the same city.
SELECT
    o.order_id,
    c.name AS customer_name,
    c.city AS customer_city,
    r.name AS restaurant_name,
    r.city AS restaurant_city,
    o.amount
FROM b_orders AS o
INNER JOIN b_customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN b_restaurants AS r
    ON o.restaurant_id = r.restaurant_id
WHERE c.city = r.city
ORDER BY o.order_id;


-- ----------------------------------------------------------------------------
-- TASK 4: Delivery Agent Performance Ranking
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS deliveries;
CREATE TABLE deliveries (
    delivery_id INT PRIMARY KEY,
    agent_name VARCHAR(100) NOT NULL,
    restaurant_name VARCHAR(100) NOT NULL,
    delivery_time_mins DECIMAL(6,2),
    order_date DATE NOT NULL
);

INSERT INTO deliveries VALUES
(1,'Amit','Spice Hub',25,'2026-10-01'),
(2,'Amit','Pizza Town',30,'2026-10-02'),
(3,'Amit','Burger Point',28,'2026-10-03'),
(4,'Neha','Spice Hub',35,'2026-10-01'),
(5,'Neha','Pizza Town',32,'2026-10-02'),
(6,'Neha','South Meals',38,'2026-10-03'),
(7,'Raj','Burger Point',22,'2026-10-01'),
(8,'Raj','Spice Hub',24,'2026-10-02'),
(9,'Raj','Pizza Town',26,'2026-10-04'),
(10,'Pooja','South Meals',40,'2026-10-01'),
(11,'Pooja','Burger Point',36,'2026-10-02'),
(12,'Pooja','Spice Hub',42,'2026-10-05');

-- B4: CTE, RANK(), scalar subquery and CASE WHEN.
WITH agent_stats AS (
    SELECT
        agent_name,
        AVG(delivery_time_mins) AS avg_delivery_time
    FROM deliveries
    WHERE delivery_time_mins IS NOT NULL
    GROUP BY agent_name
)
SELECT
    agent_name,
    ROUND(avg_delivery_time, 2) AS avg_delivery_time,
    RANK() OVER (ORDER BY avg_delivery_time ASC) AS speed_rank,
    ROUND(
        (SELECT AVG(delivery_time_mins)
         FROM deliveries
         WHERE delivery_time_mins IS NOT NULL), 2
    ) AS platform_avg_time,
    CASE
        WHEN avg_delivery_time <=
             (SELECT AVG(delivery_time_mins)
              FROM deliveries
              WHERE delivery_time_mins IS NOT NULL)
        THEN 'On Track'
        ELSE 'Needs Improvement'
    END AS performance_status
FROM agent_stats
ORDER BY speed_rank, agent_name;


-- ============================================================================
-- SECTION C - MINI CAPSTONE PROJECT
-- Food Delivery Analytics - SQL Backend
-- ============================================================================

DROP VIEW IF EXISTS vw_daily_order_summary;
DROP TABLE IF EXISTS cap_orders;
DROP TABLE IF EXISTS delivery_agents;
DROP TABLE IF EXISTS cap_restaurants;
DROP TABLE IF EXISTS cap_customers;

CREATE TABLE cap_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE cap_restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(100) NOT NULL,
    cuisine_type VARCHAR(50),
    city VARCHAR(50) NOT NULL
);

CREATE TABLE delivery_agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE cap_orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    agent_id INT NOT NULL,
    order_amount DECIMAL(10,2) NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    order_date DATE NOT NULL,
    delivery_time_mins DECIMAL(6,2),
    FOREIGN KEY (customer_id) REFERENCES cap_customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES cap_restaurants(restaurant_id),
    FOREIGN KEY (agent_id) REFERENCES delivery_agents(agent_id)
);

-- 10 customers across Mumbai, Ahmedabad and Surat.
INSERT INTO cap_customers VALUES
(1,'Aarav Shah','Mumbai','9100000001'),
(2,'Diya Patel','Ahmedabad','9100000002'),
(3,'Rohan Mehta','Surat','9100000003'),
(4,'Meera Joshi','Mumbai','9100000004'),
(5,'Kabir Desai','Pune','9100000005'),
(6,'Anaya Shah','Ahmedabad','9100000006'),
(7,'Vivaan Patel','Surat','9100000007'),
(8,'Isha Mehta','Mumbai','9100000008'),
(9,'Arjun Shah','Surat','9100000009'),
(10,'Sara Khan','Ahmedabad','9100000010');

-- 10 restaurants.
INSERT INTO cap_restaurants VALUES
(1,'Spice Hub','Indian','Mumbai'),
(2,'Pizza Town','Italian','Mumbai'),
(3,'Burger Point','Fast Food','Ahmedabad'),
(4,'Royal Biryani','Indian','Ahmedabad'),
(5,'South Meals','South Indian','Surat'),
(6,'Green Bowl','Healthy','Surat'),
(7,'Tandoori House','Indian','Pune'),
(8,'Cafe Central','Cafe','Pune'),
(9,'Dosa Corner','South Indian','Mumbai'),
(10,'Wok Express','Chinese','Ahmedabad');

-- 10 delivery agents.
INSERT INTO delivery_agents VALUES
(1,'Amit','Mumbai','9200000001'),
(2,'Neha','Mumbai','9200000002'),
(3,'Raj','Ahmedabad','9200000003'),
(4,'Pooja','Ahmedabad','9200000004'),
(5,'Karan','Surat','9200000005'),
(6,'Riya','Surat','9200000006'),
(7,'Dev','Pune','9200000007'),
(8,'Maya','Pune','9200000008'),
(9,'Irfan','Mumbai','9200000009'),
(10,'Tina','Ahmedabad','9200000010');

-- 20 orders. Dates are relative to CURDATE() so the last-7-days
-- view returns sample records whenever this script is executed.
INSERT INTO cap_orders
(order_id, customer_id, restaurant_id, agent_id, order_amount,
 order_status, order_date, delivery_time_mins)
VALUES
(1001,1,1,1,1800,'Completed',CURDATE()-INTERVAL 1 DAY,25),
(1002,2,3,3,2200,'Completed',CURDATE()-INTERVAL 1 DAY,30),
(1003,3,5,5,1400,'Completed',CURDATE()-INTERVAL 2 DAY,28),
(1004,4,2,2,2600,'Completed',CURDATE()-INTERVAL 2 DAY,32),
(1005,5,7,7,3100,'Completed',CURDATE()-INTERVAL 3 DAY,35),
(1006,6,4,4,1900,'Completed',CURDATE()-INTERVAL 3 DAY,27),
(1007,7,6,6,2400,'Completed',CURDATE()-INTERVAL 4 DAY,29),
(1008,8,9,9,1600,'Completed',CURDATE()-INTERVAL 4 DAY,24),
(1009,9,5,5,2800,'Completed',CURDATE()-INTERVAL 5 DAY,31),
(1010,10,10,10,3500,'Completed',CURDATE()-INTERVAL 5 DAY,33),
(1011,1,1,1,2100,'Completed',CURDATE()-INTERVAL 6 DAY,26),
(1012,2,3,3,1700,'Completed',CURDATE()-INTERVAL 6 DAY,34),
(1013,3,5,5,2300,'Completed',CURDATE()-INTERVAL 7 DAY,29),
(1014,4,2,2,4200,'Completed',CURDATE()-INTERVAL 8 DAY,36),
(1015,5,7,7,1500,'Cancelled',CURDATE()-INTERVAL 9 DAY,NULL),
(1016,6,4,4,2700,'Completed',CURDATE()-INTERVAL 10 DAY,28),
(1017,7,6,6,3300,'Completed',CURDATE()-INTERVAL 11 DAY,30),
(1018,8,9,9,900,'Completed',CURDATE()-INTERVAL 12 DAY,22),
(1019,9,5,5,5100,'Completed',CURDATE()-INTERVAL 13 DAY,38),
(1020,10,10,10,1200,'Completed',CURDATE()-INTERVAL 14 DAY,25),
-- Additional completed orders make the >3 restaurant report and
-- Section D's >5 orders-per-agent filter return meaningful results.
(1021,1,1,1,1300,'Completed',CURDATE()-INTERVAL 15 DAY,24),
(1022,4,1,1,1450,'Completed',CURDATE()-INTERVAL 16 DAY,26),
(1023,8,2,1,1750,'Completed',CURDATE()-INTERVAL 17 DAY,29),
(1024,1,2,1,1950,'Completed',CURDATE()-INTERVAL 18 DAY,27),
(1025,2,3,3,1550,'Completed',CURDATE()-INTERVAL 15 DAY,31),
(1026,6,3,3,1650,'Completed',CURDATE()-INTERVAL 16 DAY,32),
(1027,10,4,3,1850,'Completed',CURDATE()-INTERVAL 17 DAY,30),
(1028,2,10,3,2050,'Completed',CURDATE()-INTERVAL 18 DAY,34),
(1029,3,5,5,1250,'Completed',CURDATE()-INTERVAL 15 DAY,28),
(1030,7,5,5,1350,'Completed',CURDATE()-INTERVAL 16 DAY,29),
(1031,9,6,5,1550,'Completed',CURDATE()-INTERVAL 17 DAY,33),
(1032,3,6,5,1650,'Completed',CURDATE()-INTERVAL 18 DAY,30);

-- C1: Restaurant revenue report; only restaurants with more than 3 orders.
SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    COUNT(o.order_id) AS total_orders,
    SUM(o.order_amount) AS total_revenue,
    ROUND(AVG(o.order_amount), 2) AS average_order_value
FROM cap_restaurants AS r
INNER JOIN cap_orders AS o
    ON r.restaurant_id = o.restaurant_id
WHERE o.order_status = 'Completed'
GROUP BY r.restaurant_id, r.restaurant_name, r.city
HAVING COUNT(o.order_id) > 3
ORDER BY total_revenue DESC;

-- C2: Customer segmentation by total lifetime spend.
-- Exactly Rs 5,000 is Gold, based on the assessment's thresholds.
SELECT
    c.customer_id,
    c.customer_name,
    COALESCE(SUM(
        CASE WHEN o.order_status = 'Completed' THEN o.order_amount ELSE 0 END
    ), 0) AS total_spend,
    CASE
        WHEN COALESCE(SUM(
            CASE WHEN o.order_status = 'Completed' THEN o.order_amount ELSE 0 END
        ), 0) > 5000 THEN 'Platinum'
        WHEN COALESCE(SUM(
            CASE WHEN o.order_status = 'Completed' THEN o.order_amount ELSE 0 END
        ), 0) >= 2000 THEN 'Gold'
        ELSE 'Standard'
    END AS customer_segment
FROM cap_customers AS c
LEFT JOIN cap_orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spend DESC;

-- C3(a): Top 3 performing restaurants in each city using DENSE_RANK().
WITH restaurant_revenue AS (
    SELECT
        r.city,
        r.restaurant_id,
        r.restaurant_name,
        SUM(o.order_amount) AS total_revenue
    FROM cap_restaurants AS r
    INNER JOIN cap_orders AS o
        ON r.restaurant_id = o.restaurant_id
    WHERE o.order_status = 'Completed'
    GROUP BY r.city, r.restaurant_id, r.restaurant_name
),
ranked_restaurants AS (
    SELECT
        city,
        restaurant_id,
        restaurant_name,
        total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY city
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM restaurant_revenue
)
SELECT city, restaurant_id, restaurant_name, total_revenue, revenue_rank
FROM ranked_restaurants
WHERE revenue_rank <= 3
ORDER BY city, revenue_rank, restaurant_name;

-- C3(b): One most recent order per customer using ROW_NUMBER().
WITH customer_order_rank AS (
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_id,
        o.order_date,
        o.order_amount,
        o.order_status,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY o.order_date DESC, o.order_id DESC
        ) AS row_num
    FROM cap_customers AS c
    INNER JOIN cap_orders AS o
        ON c.customer_id = o.customer_id
)
SELECT customer_id, customer_name, order_id, order_date,
       order_amount, order_status
FROM customer_order_rank
WHERE row_num = 1
ORDER BY customer_id;

-- C4: Create a view joining all four tables.
CREATE OR REPLACE VIEW vw_daily_order_summary AS
SELECT
    o.order_date,
    c.customer_name,
    r.restaurant_name,
    a.agent_name,
    o.order_amount,
    o.delivery_time_mins
FROM cap_orders AS o
INNER JOIN cap_customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN cap_restaurants AS r
    ON o.restaurant_id = r.restaurant_id
INNER JOIN delivery_agents AS a
    ON o.agent_id = a.agent_id;

-- Query the view for orders placed in the last 7 days (including today).
SELECT
    order_date,
    customer_name,
    restaurant_name,
    agent_name,
    order_amount,
    delivery_time_mins
FROM vw_daily_order_summary
WHERE order_date >= CURDATE() - INTERVAL 6 DAY
  AND order_date <= CURDATE()
ORDER BY order_date DESC, customer_name;


-- ============================================================================
-- SECTION D - AI-AUGMENTED LEARNING
-- ============================================================================

/*
D1. EXACT PROMPT GIVEN TO AI
"Find the top 3 delivery agents per city for a food delivery platform,
ranked by number of completed orders, using window functions. Include each
agent's average delivery time alongside their rank. Filter the result to
agents who have completed more than 5 orders in that city. Sort by city
name alphabetically and rank ascending."

D2. AI'S ORIGINAL QUERY (intentionally contains a logical issue)
This first draft ranks all agents before filtering to agents with more
than 5 completed orders. That can produce gaps or omit the intended top
three among qualifying agents. It also does not exclude NULL delivery
times from the average explicitly.
*/

-- AI original draft:
WITH agent_city_stats AS (
    SELECT
        a.city,
        a.agent_id,
        a.agent_name,
        COUNT(o.order_id) AS completed_orders,
        AVG(o.delivery_time_mins) AS avg_delivery_time
    FROM delivery_agents AS a
    INNER JOIN cap_orders AS o
        ON a.agent_id = o.agent_id
    WHERE o.order_status = 'Completed'
    GROUP BY a.city, a.agent_id, a.agent_name
),
ai_ranked AS (
    SELECT
        city,
        agent_id,
        agent_name,
        completed_orders,
        avg_delivery_time,
        RANK() OVER (
            PARTITION BY city
            ORDER BY completed_orders DESC
        ) AS agent_rank
    FROM agent_city_stats
)
SELECT *
FROM ai_ranked
WHERE completed_orders > 5
  AND agent_rank <= 3
ORDER BY city, agent_rank;

 /*
D3. CORRECTED QUERY
Filter to agents with more than 5 completed orders inside the eligible
CTE first, then rank only those eligible agents. COUNT counts completed
orders; AVG ignores NULL values. If every delivery time is NULL, the
average remains NULL and is displayed as NULL.
*/

WITH agent_city_stats AS (
    SELECT
        a.city,
        a.agent_id,
        a.agent_name,
        COUNT(o.order_id) AS completed_orders,
        AVG(o.delivery_time_mins) AS avg_delivery_time
    FROM delivery_agents AS a
    INNER JOIN cap_orders AS o
        ON a.agent_id = o.agent_id
    WHERE o.order_status = 'Completed'
    GROUP BY a.city, a.agent_id, a.agent_name
),
eligible_agents AS (
    SELECT
        city,
        agent_id,
        agent_name,
        completed_orders,
        avg_delivery_time
    FROM agent_city_stats
    WHERE completed_orders > 5
),
ranked_eligible_agents AS (
    SELECT
        city,
        agent_id,
        agent_name,
        completed_orders,
        ROUND(avg_delivery_time, 2) AS avg_delivery_time,
        ROW_NUMBER() OVER (
            PARTITION BY city
            ORDER BY completed_orders DESC, agent_id
        ) AS agent_rank
    FROM eligible_agents
)
SELECT
    city,
    agent_id,
    agent_name,
    completed_orders,
    avg_delivery_time,
    agent_rank
FROM ranked_eligible_agents
WHERE agent_rank <= 3
ORDER BY city ASC, agent_rank ASC;

/*
D4. 3-4 LINE NOTE: WHAT WAS CHANGED AND WHY
1. The original draft ranked all agents first and applied the > 5 order
   condition afterward, which could give incorrect ranking positions.
2. The corrected query filters eligible agents in a separate CTE before
   applying the window function, so ranks are calculated only among
   agents with more than five completed orders in that city.
3. ROW_NUMBER() gives a unique, deterministic position; agent_id is used
   as a tie-breaker when completed-order counts are equal.
4. AVG() ignores NULL delivery times in MySQL. If all times are NULL,
   the average is NULL rather than a misleading zero.

TESTING NOTE:
Additional sample orders are included so several agents exceed five
completed orders in their city. The corrected Section D query should
therefore return qualifying agents when the script is run from top to bottom.
*/

-- ============================================================================
-- END OF ASSESSMENT
-- ============================================================================
