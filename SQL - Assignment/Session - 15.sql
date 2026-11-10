
CREATE DATABASE date_function_assignment;
USE date_function_assignment;


-- Q1: NOW() - Display current date and time

SELECT NOW() AS CurrentDateTime;


-- Q2: YEAR(), MONTH(), DAY() - Extract date parts

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    order_date DATE
);

INSERT INTO Orders VALUES
(1, '2026-11-01'),
(2, '2026-10-15'),
(3, '2026-09-20'),
(4, '2026-08-10'),
(5, '2026-07-25');

SELECT
    order_id,
    order_date,
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    DAY(order_date) AS order_day
FROM Orders;


-- Q3: DATE_SUB() - Calculate expected pickup date

CREATE TABLE Deliveries (
    delivery_id INT PRIMARY KEY,
    delivery_date DATE
);

INSERT INTO Deliveries VALUES
(1, '2026-11-10'),
(2, '2026-11-12'),
(3, '2026-11-15'),
(4, '2026-11-18'),
(5, '2026-11-20');

SELECT
    delivery_date,
    DATE_SUB(delivery_date, INTERVAL 2 DAY)
    AS expected_pickup_date
FROM Deliveries;


-- Q4: DATEDIFF() - Calculate subscription duration

CREATE TABLE Subscriptions (
    user_id INT,
    start_date DATE,
    end_date DATE
);

INSERT INTO Subscriptions VALUES
(101, '2026-01-01', '2026-12-31'),
(102, '2026-02-01', '2026-08-01'),
(103, '2026-03-15', '2026-09-15'),
(104, '2026-04-01', '2026-10-01'),
(105, '2026-05-10', '2026-11-10');

SELECT
    user_id,
    start_date,
    end_date,
    DATEDIFF(end_date, start_date)
    AS subscription_days
FROM Subscriptions;


-- Q5: NOW() and DATEDIFF() - Find users
-- Who have not logged in for more than 30 days

CREATE TABLE AppLogins (
    user_id INT PRIMARY KEY,
    last_login_date DATE
);

INSERT INTO AppLogins VALUES
(101, '2026-10-01'),
(102, '2026-11-01'),
(103, '2026-09-15'),
(104, '2026-10-20'),
(105, '2026-08-01');

SELECT
    user_id,
    last_login_date
FROM AppLogins
WHERE DATEDIFF(NOW(), last_login_date) > 30;

