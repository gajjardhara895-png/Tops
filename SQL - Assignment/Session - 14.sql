
CREATE DATABASE ranking_assignment;
USE ranking_assignment;


-- Q1: ROW_NUMBER() - Assign sequential number to each order per user

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2)
);

INSERT INTO Orders VALUES
(1, 101, '2026-11-01', 500),
(2, 101, '2026-11-03', 800),
(3, 101, '2026-11-05', 1200),
(4, 102, '2026-11-02', 600),
(5, 102, '2026-11-04', 900),
(6, 103, '2026-11-01', 700),
(7, 103, '2026-11-06', 1500);

SELECT
    order_id,
    user_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER(
        PARTITION BY user_id
        ORDER BY order_date DESC
    ) AS row_num
FROM Orders;


-- Q2: RANK() - Rank songs based on streams within each artist

CREATE TABLE Songs (
    song_id INT PRIMARY KEY,
    artist VARCHAR(100),
    streams BIGINT
);

INSERT INTO Songs VALUES
(1, 'Arijit Singh', 5000000),
(2, 'Arijit Singh', 8000000),
(3, 'Arijit Singh', 8000000),
(4, 'Taylor Swift', 10000000),
(5, 'Taylor Swift', 7000000),
(6, 'Taylor Swift', 5000000),
(7, 'Shreya Ghoshal', 6000000),
(8, 'Shreya Ghoshal', 4000000);

SELECT
    song_id,
    artist,
    streams,
    RANK() OVER(
        PARTITION BY artist
        ORDER BY streams DESC
    ) AS song_rank
FROM Songs;


-- Q3: DENSE_RANK() - Rank movies within each genre

CREATE TABLE Movies (
    movie_id INT PRIMARY KEY,
    genre VARCHAR(50),
    rating DECIMAL(3,1)
);

INSERT INTO Movies VALUES
(1, 'Action', 4.5),
(2, 'Action', 4.8),
(3, 'Action', 4.8),
(4, 'Comedy', 3.9),
(5, 'Comedy', 4.5),
(6, 'Comedy', 4.2),
(7, 'Drama', 4.7),
(8, 'Drama', 4.1);

SELECT
    movie_id,
    genre,
    rating,
    DENSE_RANK() OVER(
        PARTITION BY genre
        ORDER BY rating DESC
    ) AS movie_rank
FROM Movies;


-- Q4: ROW_NUMBER() - Top 3 influencers per platform

CREATE TABLE Influencers (
    id INT PRIMARY KEY,
    platform VARCHAR(50),
    followers BIGINT
);

INSERT INTO Influencers VALUES
(1, 'Instagram', 500000),
(2, 'Instagram', 900000),
(3, 'Instagram', 700000),
(4, 'Instagram', 300000),
(5, 'YouTube', 2000000),
(6, 'YouTube', 1500000),
(7, 'YouTube', 3000000),
(8, 'YouTube', 1000000),
(9, 'Facebook', 400000),
(10, 'Facebook', 800000),
(11, 'Facebook', 600000),
(12, 'Facebook', 200000);

WITH InfluencerRanking AS (
    SELECT
        id,
        platform,
        followers,
        ROW_NUMBER() OVER(
            PARTITION BY platform
            ORDER BY followers DESC
        ) AS row_num
    FROM Influencers
)
SELECT
    id,
    platform,
    followers,
    row_num
FROM InfluencerRanking
WHERE row_num <= 3
ORDER BY platform, row_num;

