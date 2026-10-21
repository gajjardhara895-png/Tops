-- 11_final_reports.sql
-- Final deliverable: management dashboard queries that combine
-- every topic (joins, CTEs, windows, CASE, dates, strings, views).
-- Run 09_views_indexes.sql first (uses vw_executive_dashboard).

USE flipkart_db;

-- Report 1: Executive KPI summary
WITH kpi AS (
    SELECT COUNT(*) AS total_orders,
           SUM(status = 'Delivered') AS delivered,
           SUM(status = 'Cancelled') AS cancelled,
           SUM(status = 'Pending')   AS pending,
           SUM(CASE WHEN status <> 'Cancelled' THEN amount ELSE 0 END) AS net_revenue
    FROM orders)
SELECT total_orders, delivered, cancelled, pending, net_revenue,
       ROUND(delivered * 100 / total_orders, 2) AS delivery_rate_pct,
       (SELECT COUNT(*) FROM customers)         AS total_customers,
       (SELECT ROUND(AVG(delivery_days), 2) FROM deliveries WHERE delivery_days IS NOT NULL) AS avg_delivery_days
FROM kpi;

-- Report 2: Monthly sales trend with growth
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS ym, COUNT(*) AS orders, SUM(amount) AS sales
    FROM orders WHERE status <> 'Cancelled'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m'))
SELECT ym, orders, sales,
       ROUND((sales - LAG(sales) OVER (ORDER BY ym)) * 100 / LAG(sales) OVER (ORDER BY ym), 2) AS growth_pct
FROM monthly ORDER BY ym;

-- Report 3: Customer segmentation with value and recency
WITH stats AS (
    SELECT c.customer_id, TRIM(c.name) AS name, c.city,
           COUNT(o.order_id) AS orders,
           COALESCE(SUM(o.amount), 0) AS total_spent,
           MAX(o.order_date) AS last_order
    FROM customers c LEFT JOIN orders o ON o.customer_id = c.customer_id AND o.status <> 'Cancelled'
    GROUP BY c.customer_id, c.name, c.city)
SELECT name, city, orders, total_spent, last_order,
       DATEDIFF(CURDATE(), last_order) AS days_since_last_order,
       CASE WHEN orders = 0 THEN 'Inactive'
            WHEN orders <= 2 THEN 'Occasional'
            ELSE 'Frequent' END AS segment,
       CASE WHEN last_order >= CURDATE() - INTERVAL 30 DAY THEN 'Recent'
            WHEN last_order IS NULL THEN 'Never'
            ELSE 'Lapsed' END AS recency,
       DENSE_RANK() OVER (ORDER BY total_spent DESC) AS spend_rank
FROM stats
ORDER BY spend_rank;

-- Report 4: Product price intelligence and top 2 per category
WITH sales AS (
    SELECT product_id, COUNT(*) AS times_ordered
    FROM orders WHERE status <> 'Cancelled' GROUP BY product_id),
ranked AS (
    SELECT p.product_name, p.category, p.price, p.stock,
           COALESCE(s.times_ordered, 0) AS times_ordered,
           ROUND(AVG(p.price) OVER (PARTITION BY p.category), 2) AS category_avg,
           DENSE_RANK() OVER (PARTITION BY p.category ORDER BY p.price DESC) AS price_rank
    FROM products p LEFT JOIN sales s ON s.product_id = p.product_id)
SELECT product_name, category, price, category_avg,
       CASE WHEN price > category_avg THEN 'Premium' ELSE 'Standard' END AS segment,
       CASE WHEN stock = 0 THEN 'Out of Stock'
            WHEN stock < 10 THEN 'Low Stock' ELSE 'In Stock' END AS inventory_status,
       times_ordered
FROM ranked
WHERE price_rank <= 2
ORDER BY category, price_rank;

-- Report 5: Delivery scorecard by partner
SELECT delivery_partner,
       COUNT(*) AS deliveries,
       ROUND(AVG(delivery_days), 2) AS avg_days,
       SUM(delivery_days > 5)       AS delayed_count,
       CASE WHEN AVG(delivery_days) <= 3 THEN 'Excellent'
            WHEN AVG(delivery_days) <= 5 THEN 'Good'
            ELSE 'Poor' END AS performance,
       RANK() OVER (ORDER BY AVG(delivery_days)) AS rank_no
FROM deliveries
WHERE delivery_days IS NOT NULL AND order_id IN (SELECT order_id FROM orders)
GROUP BY delivery_partner;

-- Report 6: Seller performance
SELECT s.seller_name, s.rating,
       COUNT(DISTINCT p.product_id) AS products,
       COUNT(o.order_id)            AS orders,
       COALESCE(SUM(o.amount), 0)   AS revenue,
       CASE WHEN COUNT(p.product_id) = 0 THEN 'No Products'
            WHEN COUNT(o.order_id)  = 0 THEN 'No Sales'
            ELSE 'Selling' END AS seller_status
FROM sellers s
LEFT JOIN products p ON p.seller_id = s.seller_id
LEFT JOIN orders   o ON o.product_id = p.product_id AND o.status <> 'Cancelled'
GROUP BY s.seller_id, s.seller_name, s.rating
ORDER BY revenue DESC;

-- Report 7: Payment method mix
SELECT payment_method,
       COUNT(*) AS orders,
       ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 2) AS share_pct,
       SUM(amount) AS revenue
FROM orders GROUP BY payment_method ORDER BY orders DESC;

-- Report 8: Marketing - customers by email domain
SELECT SUBSTRING_INDEX(email, '@', -1) AS email_domain,
       COUNT(*) AS customers,
       GROUP_CONCAT(TRIM(name) ORDER BY name SEPARATOR ', ') AS names
FROM customers GROUP BY email_domain ORDER BY customers DESC;

-- Report 9: Data quality audit
SELECT 'Orders without delivery' AS issue, COUNT(*) AS cnt
FROM orders o LEFT JOIN deliveries d ON d.order_id = o.order_id WHERE d.delivery_id IS NULL
UNION ALL
SELECT 'Deliveries without order', COUNT(*)
FROM deliveries d LEFT JOIN orders o ON o.order_id = d.order_id WHERE o.order_id IS NULL
UNION ALL
SELECT 'Products without reviews', COUNT(*)
FROM products p LEFT JOIN reviews r ON r.product_id = p.product_id WHERE r.review_id IS NULL
UNION ALL
SELECT 'Customers without orders', COUNT(*)
FROM customers c LEFT JOIN orders o ON o.customer_id = c.customer_id WHERE o.order_id IS NULL
UNION ALL
SELECT 'Names with extra spaces', COUNT(*) FROM customers WHERE name <> TRIM(name);

-- Report 10: Executive dashboard view snapshot
SELECT * FROM vw_executive_dashboard ORDER BY order_date DESC LIMIT 10;
