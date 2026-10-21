-- 10_procedures_triggers.sql
-- Topics: stored procedures (IN / OUT / IF), triggers (BEFORE/AFTER x INSERT/UPDATE/DELETE),
--         SIGNAL, NEW / OLD, audit logging, inventory protection, reward automation
-- Run with the mysql client (it understands DELIMITER).

USE flipkart_db;

-- Supporting log / audit tables

CREATE TABLE IF NOT EXISTS audit_log (
    log_id      INT AUTO_INCREMENT PRIMARY KEY,
    table_name  VARCHAR(50),
    action_type VARCHAR(20),
    record_id   INT,
    log_time    DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS review_log (review_id INT, product_id INT, log_time DATETIME);
CREATE TABLE IF NOT EXISTS customer_activity (customer_id INT, activity_type VARCHAR(50), activity_time DATETIME);
CREATE TABLE IF NOT EXISTS inventory_log (product_id INT, stock_added INT, log_time DATETIME);
CREATE TABLE IF NOT EXISTS delivery_partner_change (order_id INT, old_partner VARCHAR(50), new_partner VARCHAR(50), change_time DATETIME);
CREATE TABLE IF NOT EXISTS customer_address_log (customer_id INT, old_address VARCHAR(200), new_address VARCHAR(200), change_time DATETIME);
CREATE TABLE IF NOT EXISTS price_change_log (product_id INT, old_price DECIMAL(10,2), new_price DECIMAL(10,2), change_time DATETIME);
CREATE TABLE IF NOT EXISTS deleted_reviews_log (review_id INT, product_id INT, customer_id INT, deleted_time DATETIME);
CREATE TABLE IF NOT EXISTS product_archive (product_id INT, product_name VARCHAR(100), deleted_time DATETIME);
CREATE TABLE IF NOT EXISTS seller_removal_log (seller_id INT, seller_name VARCHAR(100), removal_time DATETIME);

-- Make the script re-runnable
DROP PROCEDURE IF EXISTS sp_delivered_orders;
DROP PROCEDURE IF EXISTS sp_orders_by_customer;
DROP PROCEDURE IF EXISTS sp_total_orders;
DROP PROCEDURE IF EXISTS sp_customer_type;
DROP PROCEDURE IF EXISTS sp_insert_order;

DROP TRIGGER IF EXISTS trg_customer_email_check;
DROP TRIGGER IF EXISTS trg_review_default_date;
DROP TRIGGER IF EXISTS trg_delivery_days_cap;
DROP TRIGGER IF EXISTS trg_review_log;
DROP TRIGGER IF EXISTS trg_customer_welcome;
DROP TRIGGER IF EXISTS trg_product_initial_stock;
DROP TRIGGER IF EXISTS trg_delivery_status_check;
DROP TRIGGER IF EXISTS trg_customer_mobile_unique;
DROP TRIGGER IF EXISTS trg_stock_guard;
DROP TRIGGER IF EXISTS trg_delivery_partner_change;
DROP TRIGGER IF EXISTS trg_customer_address_log;
DROP TRIGGER IF EXISTS trg_price_change_log;
DROP TRIGGER IF EXISTS trg_customer_delete_check;
DROP TRIGGER IF EXISTS trg_product_delete_check;
DROP TRIGGER IF EXISTS trg_delivery_delete_check;
DROP TRIGGER IF EXISTS trg_review_deleted_log;
DROP TRIGGER IF EXISTS trg_product_archive;
DROP TRIGGER IF EXISTS trg_seller_removal_log;
DROP TRIGGER IF EXISTS trg_order_activity_log;
DROP TRIGGER IF EXISTS trg_mark_frequent_customer;
DROP TRIGGER IF EXISTS trg_products_audit_ins;
DROP TRIGGER IF EXISTS trg_products_audit_upd;
DROP TRIGGER IF EXISTS trg_products_audit_del;

DELIMITER //

-- Part A: Stored procedures

-- Procedure for delivered orders
CREATE PROCEDURE sp_delivered_orders()
BEGIN
    SELECT * FROM orders WHERE status = 'Delivered';
END //

-- Procedure with an IN parameter
CREATE PROCEDURE sp_orders_by_customer(IN p_customer_id INT)
BEGIN
    SELECT * FROM orders WHERE customer_id = p_customer_id;
END //

-- Procedure with an OUT parameter (calculate total orders)
CREATE PROCEDURE sp_total_orders(IN p_customer_id INT, OUT p_total INT)
BEGIN
    SELECT COUNT(*) INTO p_total FROM orders WHERE customer_id = p_customer_id;
END //

-- Procedure using IF
CREATE PROCEDURE sp_customer_type(IN p_customer_id INT)
BEGIN
    DECLARE v_cnt INT;
    SELECT COUNT(*) INTO v_cnt FROM orders WHERE customer_id = p_customer_id;
    IF v_cnt = 0 THEN
        SELECT 'Inactive' AS customer_type;
    ELSEIF v_cnt <= 2 THEN
        SELECT 'Occasional' AS customer_type;
    ELSE
        SELECT 'Frequent' AS customer_type;
    END IF;
END //

-- Order Automation: procedure to insert an order
CREATE PROCEDURE sp_insert_order(
    IN p_customer_id INT, IN p_product_id INT,
    IN p_amount DECIMAL(10,2), IN p_payment VARCHAR(20))
BEGIN
    INSERT INTO orders (customer_id, product_id, order_date, amount, payment_method, status)
    VALUES (p_customer_id, p_product_id, CURDATE(), p_amount, p_payment, 'Pending');
END //

-- Part B: Triggers - BEFORE INSERT

-- Block customer insert if the email has no '@'
CREATE TRIGGER trg_customer_email_check
BEFORE INSERT ON customers FOR EACH ROW
BEGIN
    IF NEW.email NOT LIKE '%@%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid email: must contain @';
    END IF;
END //

-- Default review_date to today when NULL
CREATE TRIGGER trg_review_default_date
BEFORE INSERT ON reviews FOR EACH ROW
BEGIN
    IF NEW.review_date IS NULL THEN
        SET NEW.review_date = CURRENT_DATE;
    END IF;
END //

-- Cap delivery_days at 30
CREATE TRIGGER trg_delivery_days_cap
BEFORE INSERT ON deliveries FOR EACH ROW
BEGIN
    IF NEW.delivery_days > 30 THEN
        SET NEW.delivery_days = 30;
    END IF;
END //

-- Part B: Triggers - AFTER INSERT

CREATE TRIGGER trg_review_log
AFTER INSERT ON reviews FOR EACH ROW
BEGIN
    INSERT INTO review_log (review_id, product_id, log_time)
    VALUES (NEW.review_id, NEW.product_id, NOW());
END //

CREATE TRIGGER trg_customer_welcome
AFTER INSERT ON customers FOR EACH ROW
BEGIN
    INSERT INTO customer_activity (customer_id, activity_type, activity_time)
    VALUES (NEW.customer_id, 'New Signup', NOW());
END //

CREATE TRIGGER trg_product_initial_stock
AFTER INSERT ON products FOR EACH ROW
BEGIN
    INSERT INTO inventory_log (product_id, stock_added, log_time)
    VALUES (NEW.product_id, NEW.stock, NOW());
END //

-- Order Automation: log every new order
CREATE TRIGGER trg_order_activity_log
AFTER INSERT ON orders FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, action_type, record_id)
    VALUES ('orders', 'INSERT', NEW.order_id);
END //

-- Customer Reward Automation: mark Frequent after 5 orders
CREATE TRIGGER trg_mark_frequent_customer
AFTER INSERT ON orders FOR EACH ROW
BEGIN
    DECLARE v_cnt INT;
    SELECT COUNT(*) INTO v_cnt FROM orders WHERE customer_id = NEW.customer_id;
    IF v_cnt >= 5 THEN
        UPDATE customers SET customer_type = 'Frequent' WHERE customer_id = NEW.customer_id;
    END IF;
END //

-- Part B: Triggers - BEFORE UPDATE

-- Cannot mark Delivered when delivery_days is NULL
CREATE TRIGGER trg_delivery_status_check
BEFORE UPDATE ON deliveries FOR EACH ROW
BEGIN
    IF NEW.delivery_status = 'Delivered' AND NEW.delivery_days IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'delivery_days required before marking Delivered';
    END IF;
END //

-- Block a mobile number that already exists on another customer
CREATE TRIGGER trg_customer_mobile_unique
BEFORE UPDATE ON customers FOR EACH ROW
BEGIN
    IF NEW.mobile_no <> OLD.mobile_no AND EXISTS (
        SELECT 1 FROM customers
        WHERE mobile_no = NEW.mobile_no AND customer_id <> OLD.customer_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mobile number already exists';
    END IF;
END //

-- Inventory Protection: no negative stock, and no drop of more than 50 units at once
CREATE TRIGGER trg_stock_guard
BEFORE UPDATE ON products FOR EACH ROW
BEGIN
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock cannot be negative';
    END IF;
    IF OLD.stock - NEW.stock > 50 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot reduce stock by more than 50 at once';
    END IF;
END //

-- Part B: Triggers - AFTER UPDATE

CREATE TRIGGER trg_delivery_partner_change
AFTER UPDATE ON deliveries FOR EACH ROW
BEGIN
    IF NOT (OLD.delivery_partner <=> NEW.delivery_partner) THEN
        INSERT INTO delivery_partner_change (order_id, old_partner, new_partner, change_time)
        VALUES (OLD.order_id, OLD.delivery_partner, NEW.delivery_partner, NOW());
    END IF;
END //

CREATE TRIGGER trg_customer_address_log
AFTER UPDATE ON customers FOR EACH ROW
BEGIN
    IF NOT (OLD.address <=> NEW.address) THEN
        INSERT INTO customer_address_log (customer_id, old_address, new_address, change_time)
        VALUES (OLD.customer_id, OLD.address, NEW.address, NOW());
    END IF;
END //

-- Log price changes, and stock changes, only when the value really changed
CREATE TRIGGER trg_price_change_log
AFTER UPDATE ON products FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO price_change_log (product_id, old_price, new_price, change_time)
        VALUES (OLD.product_id, OLD.price, NEW.price, NOW());
    END IF;
    IF OLD.stock <> NEW.stock THEN
        INSERT INTO inventory_log (product_id, stock_added, log_time)
        VALUES (NEW.product_id, NEW.stock - OLD.stock, NOW());
    END IF;
END //

-- Audit and Compliance: log every insert / update / delete on products
CREATE TRIGGER trg_products_audit_ins AFTER INSERT ON products FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, action_type, record_id) VALUES ('products', 'INSERT', NEW.product_id);
END //

CREATE TRIGGER trg_products_audit_upd AFTER UPDATE ON products FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, action_type, record_id) VALUES ('products', 'UPDATE', NEW.product_id);
END //

-- Part B: Triggers - BEFORE DELETE

CREATE TRIGGER trg_customer_delete_check
BEFORE DELETE ON customers FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM orders WHERE customer_id = OLD.customer_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer has orders; cannot delete';
    END IF;
END //

CREATE TRIGGER trg_product_delete_check
BEFORE DELETE ON products FOR EACH ROW
BEGIN
    IF OLD.stock > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product still has stock; cannot delete';
    END IF;
END //

CREATE TRIGGER trg_delivery_delete_check
BEFORE DELETE ON deliveries FOR EACH ROW
BEGIN
    IF OLD.delivery_status = 'In Transit' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Delivery is In Transit; cannot delete';
    END IF;
END //

-- Part B: Triggers - AFTER DELETE

CREATE TRIGGER trg_review_deleted_log
AFTER DELETE ON reviews FOR EACH ROW
BEGIN
    INSERT INTO deleted_reviews_log (review_id, product_id, customer_id, deleted_time)
    VALUES (OLD.review_id, OLD.product_id, OLD.customer_id, NOW());
END //

CREATE TRIGGER trg_product_archive
AFTER DELETE ON products FOR EACH ROW
BEGIN
    INSERT INTO product_archive (product_id, product_name, deleted_time)
    VALUES (OLD.product_id, OLD.product_name, NOW());
    INSERT INTO audit_log (table_name, action_type, record_id) VALUES ('products', 'DELETE', OLD.product_id);
END //

CREATE TRIGGER trg_seller_removal_log
AFTER DELETE ON sellers FOR EACH ROW
BEGIN
    INSERT INTO seller_removal_log (seller_id, seller_name, removal_time)
    VALUES (OLD.seller_id, OLD.seller_name, NOW());
END //

DELIMITER ;

-- Part C: Calling procedures

CALL sp_delivered_orders();
CALL sp_orders_by_customer(1);
CALL sp_total_orders(1, @total);
SELECT @total AS customer_1_total_orders;
CALL sp_customer_type(1);

-- Part D: Testing triggers (wrapped in a transaction, then rolled back,
-- so your sample data stays unchanged)

START TRANSACTION;

-- New customer -> welcome record
INSERT INTO customers (name, email, mobile_no, city, address)
VALUES ('Test User', 'test@gmail.com', '9999999999', 'Ahmedabad', 'Test Address');
SELECT * FROM customer_activity;

-- Delivery with 45 days -> capped to 30
INSERT INTO deliveries (order_id, delivery_partner, delivery_days, delivery_status)
VALUES (1, 'Ekart', 45, 'Delivered');
SELECT order_id, delivery_days FROM deliveries ORDER BY delivery_id DESC LIMIT 1;

-- Review with NULL date -> today
INSERT INTO reviews (product_id, customer_id, rating, review_date) VALUES (7, 9, 4, NULL);
SELECT * FROM reviews ORDER BY review_id DESC LIMIT 1;
SELECT * FROM review_log;

-- Price change -> logged
UPDATE products SET price = 949 WHERE product_id = 1;
SELECT * FROM price_change_log;

-- Address change -> logged
UPDATE customers SET address = '99 New Address, Ahmedabad' WHERE customer_id = 1;
SELECT * FROM customer_address_log;

-- Partner change -> logged
UPDATE deliveries SET delivery_partner = 'BlueDart' WHERE order_id = 1;
SELECT * FROM delivery_partner_change;

-- Procedure + trigger: insert an order and see it logged
CALL sp_insert_order(1, 16, 799, 'UPI');
SELECT * FROM audit_log;

ROLLBACK;

-- These statements are blocked by triggers. Run one at a time to see the error:
-- INSERT INTO customers (name, email) VALUES ('Bad Email', 'no-at-sign');
-- UPDATE products SET stock = stock - 60 WHERE product_id = 1;
-- DELETE FROM customers WHERE customer_id = 1;
-- DELETE FROM deliveries WHERE order_id = 14;

-- Remove a trigger
-- DROP TRIGGER IF EXISTS trg_customer_welcome;
-- Drop a procedure
-- DROP PROCEDURE IF EXISTS sp_customer_type;
