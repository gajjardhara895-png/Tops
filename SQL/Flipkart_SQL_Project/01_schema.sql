-- 01_schema.sql
-- Project : Flipkart Analytics Database
-- Topics  : DDL, constraints, primary / foreign keys, defaults

DROP DATABASE IF EXISTS flipkart_db;
CREATE DATABASE flipkart_db;
USE flipkart_db;

CREATE TABLE employees (
    emp_id     INT PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(100) NOT NULL,
    city       VARCHAR(50),
    salary     DECIMAL(10,2),
    department VARCHAR(50)
);

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY AUTO_INCREMENT,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(100),
    mobile_no     VARCHAR(15),
    city          VARCHAR(50),
    address       VARCHAR(200),
    customer_type VARCHAR(20) DEFAULT 'Regular'
);

CREATE TABLE sellers (
    seller_id   INT PRIMARY KEY AUTO_INCREMENT,
    seller_name VARCHAR(100) NOT NULL,
    city        VARCHAR(50),
    rating      DECIMAL(2,1)
);

CREATE TABLE products (
    product_id   INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(50),
    price        DECIMAL(10,2) NOT NULL,
    stock        INT DEFAULT 0,
    seller_id    INT,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE orders (
    order_id       INT PRIMARY KEY AUTO_INCREMENT,
    customer_id    INT,
    product_id     INT,
    order_date     DATE,
    amount         DECIMAL(10,2),
    payment_method VARCHAR(20),     -- UPI, COD, Card
    status         VARCHAR(20),     -- Delivered, Pending, Cancelled
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id)  REFERENCES products(product_id)
);

-- No foreign key on order_id on purpose: one orphan row is inserted
-- so the Data Quality Audit has something to find.
CREATE TABLE deliveries (
    delivery_id      INT PRIMARY KEY AUTO_INCREMENT,
    order_id         INT,
    delivery_partner VARCHAR(50),   -- Ekart, Delhivery, BlueDart
    delivery_days    INT,
    delivery_status  VARCHAR(20)    -- Delivered, In Transit
);

CREATE TABLE reviews (
    review_id   INT PRIMARY KEY AUTO_INCREMENT,
    product_id  INT,
    customer_id INT,
    rating      INT,
    review_date DATE
);
