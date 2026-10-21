-- 06_union_subqueries.sql
-- Topics: UNION, UNION ALL, scalar / correlated / derived-table subqueries,
--         IN, EXISTS, ANY, ALL

USE flipkart_db;

-- Part A: UNION and UNION ALL

SELECT name FROM customers UNION SELECT seller_name FROM sellers;          -- removes duplicates

SELECT city FROM customers UNION ALL SELECT city FROM sellers;             -- keeps duplicates
SELECT city FROM customers UNION     SELECT city FROM sellers;             -- combined unique city list

SELECT order_id, status FROM orders WHERE status = 'Delivered'
UNION ALL
SELECT order_id, status FROM orders WHERE status = 'Cancelled';

-- Activity log using orders + deliveries
SELECT order_id, order_date AS activity_date, 'Order Placed' AS activity FROM orders
UNION ALL
SELECT d.order_id, o.order_date, CONCAT('Delivery - ', d.delivery_status)
FROM deliveries d JOIN orders o ON o.order_id = d.order_id
ORDER BY activity_date, order_id;

-- Customer count and order count in one result
SELECT 'Customers' AS metric, COUNT(*) AS total FROM customers
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders;

-- Sort a UNION result (ORDER BY goes at the very end)
SELECT name AS name FROM customers
UNION
SELECT seller_name FROM sellers
ORDER BY name;

-- Products and sellers names
SELECT product_name AS name, 'Product' AS type FROM products
UNION ALL
SELECT seller_name, 'Seller' FROM sellers;

-- Mini Project: Flipkart User Directory (role column)
SELECT customer_id AS id, TRIM(name) AS name, email, city, 'Customer' AS role FROM customers
UNION ALL
SELECT seller_id, seller_name, NULL, city, 'Seller' FROM sellers
ORDER BY role, name;

-- Part B: Subqueries

-- Products above average price
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Latest order details
SELECT * FROM orders WHERE order_date = (SELECT MAX(order_date) FROM orders);

-- Customers with orders / products with reviews (IN)
SELECT * FROM customers WHERE customer_id IN (SELECT customer_id FROM orders);
SELECT * FROM products  WHERE product_id  IN (SELECT product_id  FROM reviews);

-- Products priced above their category average (correlated)
SELECT * FROM products p
WHERE price > (SELECT AVG(price) FROM products WHERE category = p.category);

-- Orders after the average order date
SELECT * FROM orders
WHERE order_date > (SELECT FROM_DAYS(AVG(TO_DAYS(order_date))) FROM orders);

-- Customers without orders (NOT IN with NULL guard / NOT EXISTS)
SELECT * FROM customers
WHERE customer_id NOT IN (SELECT customer_id FROM orders WHERE customer_id IS NOT NULL);

SELECT * FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);

-- Products with max price per category
SELECT * FROM products p
WHERE price = (SELECT MAX(price) FROM products WHERE category = p.category);

-- Count orders using a subquery; subquery in SELECT; derived table
SELECT COUNT(*) AS total_orders FROM (SELECT order_id FROM orders) t;

SELECT c.name,
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id) AS order_count
FROM customers c;

SELECT category, avg_price
FROM (SELECT category, AVG(price) AS avg_price FROM products GROUP BY category) t
WHERE avg_price > 5000;

-- EXISTS vs IN
SELECT * FROM customers c WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
SELECT * FROM customers WHERE customer_id IN (SELECT customer_id FROM orders);

-- Part C: Extra subquery questions

-- 1. Customers whose total spending is above the average spending
SELECT customer_id, SUM(amount) AS total_spent
FROM orders GROUP BY customer_id
HAVING SUM(amount) > (SELECT AVG(t.total)
                      FROM (SELECT SUM(amount) AS total FROM orders GROUP BY customer_id) t);

-- 2. Customers with more orders than the average number of orders
SELECT customer_id, COUNT(*) AS cnt
FROM orders GROUP BY customer_id
HAVING COUNT(*) > (SELECT AVG(t.cnt)
                   FROM (SELECT COUNT(*) AS cnt FROM orders GROUP BY customer_id) t);

-- 3. Products above average price
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- 4. Sellers with more products than the average per seller
SELECT seller_id, COUNT(*) AS product_cnt
FROM products GROUP BY seller_id
HAVING COUNT(*) > (SELECT AVG(t.cnt)
                   FROM (SELECT COUNT(*) AS cnt FROM products GROUP BY seller_id) t);

-- 5. Customers who never placed an order
SELECT * FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);

-- 6. Orders above the average order amount
SELECT * FROM orders WHERE amount > (SELECT AVG(amount) FROM orders);

-- 7. Customers whose total purchase equals the maximum total purchase
SELECT customer_id, SUM(amount) AS total
FROM orders GROUP BY customer_id
HAVING SUM(amount) = (SELECT MAX(t.total)
                      FROM (SELECT SUM(amount) AS total FROM orders GROUP BY customer_id) t);

-- 8. Products not associated with any seller
SELECT * FROM products
WHERE seller_id IS NULL OR seller_id NOT IN (SELECT seller_id FROM sellers);

-- 9. Customers in cities where more than one customer exists
SELECT * FROM customers
WHERE city IN (SELECT city FROM customers GROUP BY city HAVING COUNT(*) > 1);

-- 10. Sellers with at least one product priced below the average
SELECT * FROM sellers s
WHERE EXISTS (SELECT 1 FROM products p
              WHERE p.seller_id = s.seller_id
                AND p.price < (SELECT AVG(price) FROM products));

-- 11. Customers whose total spending is higher than ANY Ahmedabad customer
--     (ANY = higher than the lowest; use ALL for "higher than every one")
SELECT customer_id, SUM(amount) AS total
FROM orders GROUP BY customer_id
HAVING SUM(amount) > ANY (SELECT SUM(o.amount)
                          FROM orders o JOIN customers c ON c.customer_id = o.customer_id
                          WHERE c.city = 'Ahmedabad' GROUP BY o.customer_id);

-- 12. Products priced higher than ALL products of seller_id = 1
SELECT * FROM products
WHERE price > ALL (SELECT price FROM products WHERE seller_id = 1);

-- 13. Customers who ordered every product (returns none with this data)
SELECT customer_id FROM orders
GROUP BY customer_id
HAVING COUNT(DISTINCT product_id) = (SELECT COUNT(*) FROM products);

-- 14. Sellers who sell ONLY products priced above average
SELECT * FROM sellers s
WHERE EXISTS (SELECT 1 FROM products p WHERE p.seller_id = s.seller_id)
  AND NOT EXISTS (SELECT 1 FROM products p
                  WHERE p.seller_id = s.seller_id
                    AND p.price <= (SELECT AVG(price) FROM products));

-- 15. Customers whose latest order amount > their own average order amount
SELECT o.customer_id, o.amount AS latest_amount
FROM orders o
WHERE o.order_date = (SELECT MAX(order_date) FROM orders WHERE customer_id = o.customer_id)
  AND o.amount > (SELECT AVG(amount) FROM orders WHERE customer_id = o.customer_id);

-- 16. Sellers whose product count equals the maximum product count
SELECT seller_id, COUNT(*) AS product_cnt
FROM products GROUP BY seller_id
HAVING COUNT(*) = (SELECT MAX(t.cnt)
                   FROM (SELECT COUNT(*) AS cnt FROM products GROUP BY seller_id) t);

-- 17. Products ordered more times than the average order frequency
SELECT product_id, COUNT(*) AS times_ordered
FROM orders GROUP BY product_id
HAVING COUNT(*) > (SELECT AVG(t.cnt)
                   FROM (SELECT COUNT(*) AS cnt FROM orders GROUP BY product_id) t);

-- 18. Customers contributing more than 70 percent of total revenue
--     (returns no rows with the sample data; try 0.2 to see output)
SELECT customer_id, SUM(amount) AS total
FROM orders GROUP BY customer_id
HAVING SUM(amount) > 0.7 * (SELECT SUM(amount) FROM orders);

-- 19. Sellers with products listed but none of them ordered
SELECT * FROM sellers s
WHERE EXISTS (SELECT 1 FROM products p WHERE p.seller_id = s.seller_id)
  AND NOT EXISTS (SELECT 1 FROM products p JOIN orders o ON o.product_id = p.product_id
                  WHERE p.seller_id = s.seller_id);

-- 20. Top 3 customers by spending WITHOUT LIMIT
SELECT t1.customer_id, t1.total
FROM (SELECT customer_id, SUM(amount) AS total FROM orders GROUP BY customer_id) t1
WHERE (SELECT COUNT(*)
       FROM (SELECT customer_id, SUM(amount) AS total FROM orders GROUP BY customer_id) t2
       WHERE t2.total > t1.total) < 3
ORDER BY t1.total DESC;

-- Mini Project: Premium Product Identification
SELECT p.product_id, p.product_name, p.category, p.price,
       CASE WHEN p.price > (SELECT AVG(price) FROM products WHERE category = p.category)
            THEN 'Premium' ELSE 'Normal' END AS segment
FROM products p;

-- Mini Project: Active Customer Analysis
SELECT c.customer_id, TRIM(c.name) AS name, MAX(o.order_date) AS last_order_date,
       COUNT(o.order_id) AS orders,
       CASE WHEN COUNT(o.order_id) = 0 THEN 'No Orders' ELSE 'Has Orders' END AS status
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY last_order_date DESC;
