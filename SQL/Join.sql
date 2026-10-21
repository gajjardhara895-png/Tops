CREATE DATABASE shopping_db;
USE shopping_db;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE sellers (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(100),
    rating DECIMAL(3,2),
    city VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2),
    category VARCHAR(50),
    seller_id INT,
    stock INT,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_status VARCHAR(50),
    payment_method VARCHAR(50),
    order_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE deliveries (
    delivery_id INT PRIMARY KEY,
    order_id INT,
    delivery_partner VARCHAR(100),
    delivery_status VARCHAR(50),
    delivery_days INT,
    shipment_mode VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    product_id INT,
    customer_id INT,
    review_text VARCHAR(255),
    rating INT,
    review_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customers VALUES
(1, 'Amit', 'amit@gmail.com', 'Ahmedabad'),
(2, 'Priya', 'priya@gmail.com', 'Surat'),
(3, 'Rahul', 'rahul@gmail.com', 'Vadodara'),
(4, 'Neha', 'neha@gmail.com', 'Ahmedabad'),
(5, 'Karan', 'karan@gmail.com', 'Rajkot');

INSERT INTO sellers VALUES
(1, 'Tech World', 4.50, 'Ahmedabad'),
(2, 'Fashion Hub', 4.20, 'Surat'),
(3, 'Home Store', 3.90, 'Vadodara'),
(4, 'Book Point', 4.70, 'Rajkot');

INSERT INTO products VALUES
(1, 'Laptop', 55000, 'Electronics', 1, 10),
(2, 'Mobile', 25000, 'Electronics', 1, 20),
(3, 'T-Shirt', 800, 'Fashion', 2, 50),
(4, 'Shoes', 2000, 'Fashion', 2, 30),
(5, 'Chair', 3500, 'Furniture', 3, 15),
(6, 'SQL Book', 600, 'Books', 4, 40);

INSERT INTO orders VALUES
(101, 1, '2026-10-01', 'Delivered', 'UPI', 55800),
(102, 2, '2026-10-03', 'Shipped', 'Card', 25000),
(103, 1, '2026-10-05', 'Delivered', 'Cash', 2800),
(104, 3, '2026-10-07', 'Pending', 'UPI', 3500),
(105, 4, '2026-10-10', 'Cancelled', 'Card', 600);

INSERT INTO order_items VALUES
(1, 101, 1, 1, 55000),
(2, 101, 6, 1, 600),
(3, 102, 2, 1, 25000),
(4, 103, 3, 1, 800),
(5, 103, 4, 1, 2000),
(6, 104, 5, 1, 3500),
(7, 105, 6, 1, 600);

INSERT INTO deliveries VALUES
(1, 101, 'Blue Dart', 'Delivered', 3, 'Air'),
(2, 102, 'Delhivery', 'In Transit', 4, 'Road'),
(3, 103, 'DTDC', 'Delivered', 2, 'Road'),
(4, 104, 'Blue Dart', 'Pending', NULL, 'Road');

INSERT INTO reviews VALUES
(1, 1, 1, 'Excellent laptop', 5, '2026-10-02'),
(2, 2, 2, 'Good mobile', 4, '2026-10-04'),
(3, 3, 1, 'Nice T-shirt', 4, '2026-10-06'),
(4, 5, 3, 'Average chair', 3, '2026-10-08'),
(5, 1, 4, 'Very good product', 5, '2026-10-11');

SHOW TABLES;

SELECT * FROM customers;
SELECT * FROM sellers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM deliveries;
SELECT * FROM reviews;

# SQL JOIN Practice — 100 Queries

-- 1. Highest review rating received by each product
SELECT p.product_name, MAX(r.rating) AS highest_rating
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name;

-- 2. Payment methods associated with at least two deliveries
SELECT o.payment_method, COUNT(d.delivery_id) AS total_deliveries
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id
GROUP BY o.payment_method
HAVING COUNT(d.delivery_id) >= 2;

-- 3. Different sellers in the same city
SELECT s1.seller_name AS seller_1,
       s2.seller_name AS seller_2, s1.city
FROM sellers s1
JOIN sellers s2
ON s1.city = s2.city AND s1.seller_id < s2.seller_id;

-- 4. Customer name, order ID, product name and review rating
-- Reviews are not linked to particular orders.
SELECT c.customer_name, o.order_id, p.product_name, r.rating
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN reviews r ON r.customer_id = c.customer_id
JOIN products p ON p.product_id = r.product_id;

-- 5. Customers whose average review rating is above 4
SELECT c.customer_id, c.customer_name,
       AVG(r.rating) AS average_rating
FROM customers c
JOIN reviews r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING AVG(r.rating) > 4.0;

-- 6. Every product with review count and average rating
SELECT p.product_name, COUNT(r.review_id) AS review_count,
       AVG(r.rating) AS average_rating
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name;

-- 7. Customers who have both orders and reviews
SELECT DISTINCT c.customer_name, o.order_id, r.review_id
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN reviews r ON c.customer_id = r.customer_id;

-- 8. Products without reviews using RIGHT JOIN
SELECT p.product_name
FROM reviews r
RIGHT JOIN products p ON r.product_id = p.product_id
WHERE r.review_id IS NULL;

-- 9. Review count per product, including zero reviews
SELECT p.product_name, COUNT(r.review_id) AS review_count
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name;

-- 10. Customers, payment methods and shipment modes
SELECT c.customer_name, o.payment_method, d.shipment_mode
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN deliveries d ON o.order_id = d.order_id;

-- 11. Every customer and number of orders
SELECT c.customer_name, COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 12. All products and average review ratings using RIGHT JOIN
SELECT p.product_name, AVG(r.rating) AS average_rating
FROM reviews r
RIGHT JOIN products p ON r.product_id = p.product_id
GROUP BY p.product_id, p.product_name;

-- 13. Customer names, order statuses and delivery days for Bike shipments
SELECT c.customer_name, o.order_status, d.delivery_days
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN deliveries d ON o.order_id = d.order_id
WHERE d.shipment_mode = 'Bike';

-- 14. Average review rating for each product
SELECT p.product_name, AVG(r.rating) AS average_rating
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name;

-- 15. Customers with more than one order
SELECT c.customer_name, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 1;

-- 16. Orders without matching delivery records
SELECT o.*
FROM orders o
LEFT JOIN deliveries d ON o.order_id = d.order_id
WHERE d.delivery_id IS NULL;

-- 17. Delivered orders with customer names and dates
SELECT c.customer_name, o.order_id, o.order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered';

-- 18. Every order and delivery details
SELECT o.order_id, d.delivery_partner,
       d.delivery_status, d.delivery_days
FROM orders o
LEFT JOIN deliveries d ON o.order_id = d.order_id;

-- 19. Distinct customers reviewing each product category
SELECT p.category,
       COUNT(DISTINCT r.customer_id) AS distinct_customers
FROM products p
JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.category;

-- 20. Average delivery days for each customer city
SELECT c.city, AVG(d.delivery_days) AS average_delivery_days
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN deliveries d ON o.order_id = d.order_id
GROUP BY c.city;

-- 21. Order IDs and delivery partners for Bike shipments
SELECT o.order_id, d.delivery_partner
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id
WHERE d.shipment_mode = 'Bike';

-- 22. Average delivery days by payment method
SELECT o.payment_method,
       AVG(d.delivery_days) AS average_delivery_days
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id
GROUP BY o.payment_method;

-- 23. Customer names, cities and order dates
SELECT c.customer_name, c.city, o.order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

-- 24. All orders with delivery days, including missing deliveries
SELECT o.order_id, d.delivery_days
FROM orders o
LEFT JOIN deliveries d ON o.order_id = d.order_id;

-- 25. Average review rating given by each customer
SELECT c.customer_name, AVG(r.rating) AS average_rating
FROM customers c
LEFT JOIN reviews r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 26. Customers from Surat and their order details
SELECT c.customer_name, o.*
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.city = 'Surat';

-- 27. Orders placed in 2024 with customers and delivery statuses
SELECT c.customer_name, o.order_id, o.order_date,
       d.delivery_status
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN deliveries d ON o.order_id = d.order_id
WHERE o.order_date >= '2024-01-01'
  AND o.order_date < '2025-01-01';

-- 28. Customer name, order ID and delivery partner
SELECT c.customer_name, o.order_id, d.delivery_partner
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN deliveries d ON o.order_id = d.order_id;

-- 29. RIGHT JOIN to show all products and matching reviews
SELECT p.product_name, r.review_id, r.rating
FROM reviews r
RIGHT JOIN products p ON r.product_id = p.product_id;

-- 30. Count reviewed products by category
SELECT p.category,
       COUNT(DISTINCT CASE
           WHEN r.review_id IS NOT NULL THEN p.product_id
       END) AS reviewed_products
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.category;

-- 31. Product names, prices and reviewer names
SELECT p.product_name, p.price, c.customer_name
FROM products p
JOIN reviews r ON p.product_id = r.product_id
JOIN customers c ON r.customer_id = c.customer_id;

-- 32. Every product and any reviews received
SELECT p.product_name, r.review_text, r.rating
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id;

-- 33. Product names and cities of reviewers
SELECT p.product_name, c.city
FROM products p
JOIN reviews r ON p.product_id = r.product_id
JOIN customers c ON r.customer_id = c.customer_id;

-- 34. Product name, seller name and seller city
SELECT p.product_name, s.seller_name, s.city
FROM products p
JOIN sellers s ON p.seller_id = s.seller_id;

-- The supplied sample data DOES contain matching seller IDs.
-- For example, product 101 has seller_id = 1.
-- If no rows appear, check that you are using shopping_db_fixed
-- and that both tables contain the sample data.

-- 35. All orders and delivery partners using RIGHT JOIN
SELECT o.order_id, d.delivery_partner
FROM deliveries d
RIGHT JOIN orders o ON d.order_id = o.order_id;

-- 36. Each order ID with its delivery partner
SELECT o.order_id, d.delivery_partner
FROM orders o
LEFT JOIN deliveries d ON o.order_id = d.order_id;

-- 37. All customers, their orders and deliveries
SELECT c.customer_name, o.order_id,
       d.delivery_partner, d.delivery_status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN deliveries d ON o.order_id = d.order_id;

-- 38. Every product with its most recent review date
SELECT p.product_name, MAX(r.review_date) AS latest_review_date
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name;

-- 39. Order IDs, delivery days and delivery statuses
SELECT o.order_id, d.delivery_days, d.delivery_status
FROM orders o
LEFT JOIN deliveries d ON o.order_id = d.order_id;

-- 40. Customer names with products they reviewed
SELECT c.customer_name, p.product_name
FROM customers c
JOIN reviews r ON c.customer_id = r.customer_id
JOIN products p ON r.product_id = p.product_id;

-- 41. Product names, review comments and dates
SELECT p.product_name, r.review_text, r.review_date
FROM products p
JOIN reviews r ON p.product_id = r.product_id;

-- 42. Customer name, product name and rating
SELECT c.customer_name, p.product_name, r.rating
FROM customers c
JOIN reviews r ON c.customer_id = r.customer_id
JOIN products p ON r.product_id = p.product_id;

-- 43. Customers and order IDs for UPI orders
SELECT c.customer_name, o.order_id
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.payment_method = 'UPI';

-- 44. All customers and number of reviews written
SELECT c.customer_name, COUNT(r.review_id) AS review_count
FROM customers c
LEFT JOIN reviews r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 45. Every product review and reviewer city
SELECT p.product_name, r.review_id, c.city
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
LEFT JOIN customers c ON r.customer_id = c.customer_id;

-- 46. Customers who gave ratings above 4
SELECT c.customer_name, p.product_name, r.rating
FROM customers c
JOIN reviews r ON c.customer_id = r.customer_id
JOIN products p ON r.product_id = p.product_id
WHERE r.rating > 4.0;

-- 47. All customers and their orders, retaining unmatched customers
SELECT c.customer_name, o.order_id, o.order_status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- 48. Customers without orders using RIGHT JOIN
SELECT c.customer_name
FROM orders o
RIGHT JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- 49. Review comments, customer city and product category
SELECT r.review_text, c.city, p.category
FROM reviews r
JOIN customers c ON r.customer_id = c.customer_id
JOIN products p ON r.product_id = p.product_id;

-- 50. Customers who placed orders but never wrote reviews
SELECT c.customer_id, c.customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN reviews r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) > 0
   AND COUNT(DISTINCT r.review_id) = 0;

-- 51. Different orders with the same payment method
SELECT o1.order_id AS order_1, o2.order_id AS order_2,
       o1.payment_method
FROM orders o1
JOIN orders o2
ON o1.payment_method = o2.payment_method
AND o1.order_id < o2.order_id;

-- 52. Reviews rated at least 4 with customer and product names
SELECT c.customer_name, p.product_name, r.rating
FROM reviews r
JOIN products p ON r.product_id = p.product_id
JOIN customers c ON r.customer_id = c.customer_id
WHERE r.rating >= 4;

-- 53. Every customer and latest order date using RIGHT JOIN
SELECT c.customer_name, MAX(o.order_date) AS latest_order_date
FROM orders o
RIGHT JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 54. Orders and deliveries both marked Delivered
SELECT c.customer_name, o.order_id
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN deliveries d ON o.order_id = d.order_id
WHERE o.order_status = 'Delivered'
  AND d.delivery_status = 'Delivered';

-- 55. Count delivered orders per customer
SELECT c.customer_name,
       SUM(CASE WHEN o.order_status = 'Delivered'
                THEN 1 ELSE 0 END) AS delivered_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 56. Latest order date for each customer, including customers with no orders
SELECT c.customer_name, MAX(o.order_date) AS latest_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 57. Delivery partners with average delivery time above one day
SELECT delivery_partner, AVG(delivery_days) AS average_days
FROM deliveries
GROUP BY delivery_partner
HAVING AVG(delivery_days) > 1;

-- 58. Each order with customer and delivery partner
SELECT o.order_id, c.customer_name, d.delivery_partner
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN deliveries d ON o.order_id = d.order_id;

-- 59. Customer order count and review statistics without inflated counts
SELECT c.customer_id, c.customer_name,
       COALESCE(oc.order_count, 0) AS order_count,
       COALESCE(rc.review_count, 0) AS review_count,
       rc.average_rating
FROM customers c
LEFT JOIN (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
) oc ON c.customer_id = oc.customer_id
LEFT JOIN (
    SELECT customer_id, COUNT(*) AS review_count,
           AVG(rating) AS average_rating
    FROM reviews
    GROUP BY customer_id
) rc ON c.customer_id = rc.customer_id;

-- 60. Every customer and any orders placed
SELECT c.customer_name, o.order_id, o.order_status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- 61. All customers and orders using RIGHT JOIN
SELECT c.customer_name, o.order_id, o.order_status
FROM orders o
RIGHT JOIN customers c ON o.customer_id = c.customer_id;

-- 62. All customers with review counts using RIGHT JOIN
SELECT c.customer_name, COUNT(r.review_id) AS review_count
FROM reviews r
RIGHT JOIN customers c ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 63. All customers and their reviews using RIGHT JOIN
SELECT c.customer_name, r.review_id, r.rating
FROM reviews r
RIGHT JOIN customers c ON r.customer_id = c.customer_id;

-- 64. Customer payment methods and reviewed products
-- These are separate relationships, not proof of purchase.
SELECT c.customer_name, o.order_id, o.payment_method,
       p.product_name AS reviewed_product
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN reviews r ON c.customer_id = r.customer_id
LEFT JOIN products p ON r.product_id = p.product_id;

-- 65. Customer names alongside order IDs
SELECT c.customer_name, o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- 66. Shipment modes used for at least two orders
SELECT d.shipment_mode, COUNT(DISTINCT o.order_id) AS total_orders,
       AVG(d.delivery_days) AS average_delivery_days
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id
GROUP BY d.shipment_mode
HAVING COUNT(DISTINCT o.order_id) >= 2;

-- 67. Order count per customer, including zero
SELECT c.customer_name, COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 68. Customer names, order IDs and delivery days above one day
SELECT c.customer_name, o.order_id, d.delivery_days
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN deliveries d ON o.order_id = d.order_id
WHERE d.delivery_days > 1;

-- 69. All orders and matching deliveries using RIGHT JOIN
SELECT o.order_id, d.delivery_partner, d.delivery_status
FROM deliveries d
RIGHT JOIN orders o ON d.order_id = o.order_id;

-- 70. Count deliveries handled by each partner using orders and deliveries
SELECT d.delivery_partner, COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id
GROUP BY d.delivery_partner;

-- 71. Cities with at least one Delivered order
SELECT c.city, COUNT(o.order_id) AS delivered_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.city;

-- 72. Customer cities with at least two orders
SELECT c.city, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city
HAVING COUNT(o.order_id) >= 2;

-- 73. Customer city, order date and delivery status
SELECT c.city, o.order_date, d.delivery_status
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN deliveries d ON o.order_id = d.order_id;

-- 74. Delivered orders with customer names and delivery partners
SELECT c.customer_name, o.order_id, d.delivery_partner
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN deliveries d ON o.order_id = d.order_id
WHERE o.order_status = 'Delivered'
  AND d.delivery_status = 'Delivered';

-- 75. Different customers living in the same city
SELECT c1.customer_name AS customer_1,
       c2.customer_name AS customer_2, c1.city
FROM customers c1
JOIN customers c2
ON c1.city = c2.city
AND c1.customer_id < c2.customer_id;

-- 76. Customers who have never submitted a review
SELECT c.customer_id, c.customer_name
FROM customers c
LEFT JOIN reviews r ON c.customer_id = r.customer_id
WHERE r.review_id IS NULL;

-- 77. Different products in the same category
SELECT p1.product_name AS product_1,
       p2.product_name AS product_2, p1.category
FROM products p1
JOIN products p2
ON p1.category = p2.category
AND p1.product_id < p2.product_id;

-- 78. Customers who paid by Credit Card and delivery partners
SELECT c.customer_name, o.order_id, d.delivery_partner
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN deliveries d ON o.order_id = d.order_id
WHERE o.payment_method = 'Credit Card';

-- 79. Products that have never been reviewed
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
WHERE r.review_id IS NULL;

-- 80. Order IDs, payment methods and shipment modes
SELECT o.order_id, o.payment_method, d.shipment_mode
FROM orders o
LEFT JOIN deliveries d ON o.order_id = d.order_id;

-- 81. Latest order date and order count for each customer
SELECT c.customer_id, c.customer_name,
       MAX(o.order_date) AS latest_order_date,
       COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 82. Product names, prices, reviewer names and review dates
SELECT p.product_name, p.price, c.customer_name, r.review_date
FROM products p
JOIN reviews r ON p.product_id = r.product_id
JOIN customers c ON r.customer_id = c.customer_id;

-- 83. Every product and average rating, including unrated products
SELECT p.product_name, AVG(r.rating) AS average_rating
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name;

-- 84. Food-category products with reviewer names and ratings
SELECT p.product_name, c.customer_name, r.rating
FROM products p
JOIN reviews r ON p.product_id = r.product_id
JOIN customers c ON r.customer_id = c.customer_id
WHERE p.category = 'Food';

-- 85. Products with more than one review
SELECT p.product_name, COUNT(r.review_id) AS review_count
FROM products p
JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
HAVING COUNT(r.review_id) > 1;

-- 86. Every customer and any reviews they wrote
SELECT c.customer_name, r.review_id, r.review_text, r.rating
FROM customers c
LEFT JOIN reviews r ON c.customer_id = r.customer_id;

-- 87. Reviewed product categories and ratings for Ahmedabad or Surat
SELECT c.customer_name, p.category, r.rating
FROM customers c
JOIN reviews r ON c.customer_id = r.customer_id
JOIN products p ON r.product_id = p.product_id
WHERE c.city IN ('Ahmedabad', 'Surat');

-- 88. Order count and review count without double-counting
SELECT c.customer_id, c.customer_name,
       COALESCE(o.order_count, 0) AS order_count,
       COALESCE(r.review_count, 0) AS review_count
FROM customers c
LEFT JOIN (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders GROUP BY customer_id
) o ON c.customer_id = o.customer_id
LEFT JOIN (
    SELECT customer_id, COUNT(*) AS review_count
    FROM reviews GROUP BY customer_id
) r ON c.customer_id = r.customer_id;

-- 89. Products whose highest rating is at least 4.5
SELECT p.product_name, MAX(r.rating) AS highest_rating
FROM products p
JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
HAVING MAX(r.rating) >= 4.5;

-- 90. Customer names, product names and review ratings
SELECT c.customer_name, p.product_name, r.rating
FROM customers c
JOIN reviews r ON c.customer_id = r.customer_id
JOIN products p ON r.product_id = p.product_id;

-- 91. All customers, reviews and reviewed product names
SELECT c.customer_name, r.review_id, p.product_name
FROM customers c
LEFT JOIN reviews r ON c.customer_id = r.customer_id
LEFT JOIN products p ON r.product_id = p.product_id;

-- 92. Customer names and product categories for their reviews
SELECT c.customer_name, p.category
FROM customers c
JOIN reviews r ON c.customer_id = r.customer_id
JOIN products p ON r.product_id = p.product_id;

-- 93. Customer names, order statuses and payment methods
SELECT c.customer_name, o.order_status, o.payment_method
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

-- 94. Count orders by customer city
SELECT c.city, COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city;

-- 95. Count orders per shipment mode
SELECT d.shipment_mode, COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id
GROUP BY d.shipment_mode;

-- 96. Customers whose order status is Delivered
-- Show the corresponding delivery status
SELECT c.customer_name, o.order_id,
       o.order_status, d.delivery_status
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN deliveries d ON o.order_id = d.order_id
WHERE o.order_status = 'Delivered';

-- 97. Customers who have never placed an order
SELECT c.customer_id, c.customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 98. Product categories with average review rating >= 4
SELECT p.category, AVG(r.rating) AS average_rating
FROM products p
JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.category
HAVING AVG(r.rating) >= 4.0;

-- 99. All products with reviewer names, when available
SELECT p.product_name, c.customer_name, r.rating
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
LEFT JOIN customers c ON r.customer_id = c.customer_id;

-- 100. Order marked Delivered but delivery not marked Delivered
SELECT c.customer_name, o.order_id,
       o.order_status, d.delivery_status
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN deliveries d ON o.order_id = d.order_id
WHERE o.order_status = 'Delivered'
  AND (d.delivery_status <> 'Delivered'
       OR d.delivery_status IS NULL);










CREATE DATABASE IF NOT EXISTS shopping_db;
USE shopping_db;

--  LEFT JOIN (8 QUESTIONS)

-- Q1. All customers and their orders
SELECT c.customer_id, c.customer_name, o.order_id, o.order_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- Q2. All customers with order details
SELECT c.customer_name, c.email, c.city,
       o.order_date, o.order_status, o.payment_method
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- Q3. All orders with store name
-- Current schema has no direct orders-sellers relationship.
-- Use orders.seller_id after adding and populating that column.

-- Q4. All customer-store combinations
SELECT c.customer_name, s.seller_name
FROM customers c
CROSS JOIN sellers s;

-- Q5. Customers without orders
SELECT c.customer_id, c.customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Q6. Customer names and order amounts
SELECT c.customer_name, o.order_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- Q7. All customers and their latest order
SELECT c.customer_id, c.customer_name,
       o.order_id, o.order_date, o.order_amount
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
AND o.order_date = (
    SELECT MAX(o2.order_date)
    FROM orders o2
    WHERE o2.customer_id = c.customer_id
);

-- Q8. Customers with payment details
SELECT c.customer_name, o.order_id,
       o.payment_method, o.order_status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;


-- 4. RIGHT JOIN (8 QUESTIONS)

-- Q1. All orders with customer names
SELECT o.order_id, o.order_amount, c.customer_name, c.city
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;

-- Q2. All stores, including stores without orders
-- Requires a seller_id/store_id relationship in orders.

-- Q3. All stores and corresponding orders
-- Requires a seller_id/store_id relationship in orders.

-- Q4. Stores without associated orders
-- Requires a seller_id/store_id relationship in orders.

-- Q5. All orders with customer data
SELECT o.order_id, o.order_date, o.order_status, c.customer_name
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;

-- Q6. All stores with order details
-- Requires a seller_id/store_id relationship in orders.

-- Q7. Stores with customers who ordered from them
-- Requires a seller_id/store_id relationship in orders.

-- Q8. Total orders per store
-- Requires a seller_id/store_id relationship in orders.


-- 5. FULL OUTER JOIN (8 QUESTIONS)
-- MySQL does not directly support FULL OUTER JOIN.
-- Use LEFT JOIN UNION RIGHT JOIN.

-- Q1. All customers and orders, matched or unmatched
SELECT c.customer_id, c.customer_name, o.order_id, o.order_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
UNION
SELECT c.customer_id, c.customer_name, o.order_id, o.order_amount
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;

-- Q2. All customers and sellers
-- No order-based relationship exists in this schema.
SELECT c.customer_id, c.customer_name, s.seller_id, s.seller_name
FROM customers c
CROSS JOIN sellers s;

-- Q3. Orders without a matching customer
SELECT o.*
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Q4. Customers without orders and orders without customers
SELECT c.customer_id, c.customer_name, o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
UNION ALL
SELECT c.customer_id, c.customer_name, o.order_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Q5. Every customer and order, including unmatched records
SELECT c.customer_id, c.customer_name, o.order_id, o.order_status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
UNION
SELECT c.customer_id, c.customer_name, o.order_id, o.order_status
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;

-- Q6. All customer and order columns
SELECT c.customer_id, c.customer_name, o.order_id,
       o.customer_id AS order_customer_id, o.order_date,
       o.order_status, o.payment_method, o.order_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
UNION
SELECT c.customer_id, c.customer_name, o.order_id,
       o.customer_id AS order_customer_id, o.order_date,
       o.order_status, o.payment_method, o.order_amount
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;

-- Q7. Customers with no orders and orders with no customers
SELECT c.customer_id, c.customer_name, o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
UNION ALL
SELECT c.customer_id, c.customer_name, o.order_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Q8. All sellers and orders, including unmatched records
-- Requires a seller_id/store_id relationship in orders.


-- 6. CROSS JOIN (8 QUESTIONS)

-- Q1. All possible customer-store combinations
SELECT c.customer_id, c.customer_name, s.seller_id, s.seller_name
FROM customers c
CROSS JOIN sellers s;

-- Q2. All possible order-customer combinations
SELECT o.order_id, c.customer_id, c.customer_name
FROM orders o
CROSS JOIN customers c;

-- Q3. Every store and product pair
SELECT s.seller_name, p.product_name, p.price
FROM sellers s
CROSS JOIN products p;

-- Q4. All customers and payment statuses
SELECT c.customer_name, p.payment_status
FROM customers c
CROSS JOIN (
    SELECT 'Paid' AS payment_status
    UNION ALL SELECT 'Pending'
    UNION ALL SELECT 'Failed'
) p;

-- Q5. All stores and existing order statuses
SELECT s.seller_name, x.order_status
FROM sellers s
CROSS JOIN (
    SELECT DISTINCT order_status
    FROM orders
) x;

-- Q6. All combinations of customer and store IDs
SELECT c.customer_id, s.seller_id
FROM customers c
CROSS JOIN sellers s;

-- Q7. All customer and order pairs, regardless of match
SELECT c.customer_name, o.order_id, o.order_status
FROM customers c
CROSS JOIN orders o;

-- Q8. Count all possible customer-store combinations
SELECT COUNT(*) AS total_combinations
FROM customers
CROSS JOIN sellers;

