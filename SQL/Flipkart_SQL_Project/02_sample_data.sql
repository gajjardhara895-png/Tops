-- 02_sample_data.sql
-- Sample data. Order dates are relative to today so date queries
-- (last 15 days, recency, monthly trend) always return rows.

USE flipkart_db;

INSERT INTO employees (name, city, salary, department) VALUES
('Aarav Shah',    'Ahmedabad', 45000, 'IT'),
('Bhavna Patel',  'Surat',     38000, 'HR'),
('Chirag Mehta',  'Mumbai',    62000, 'IT'),
('Dipti Joshi',   'Pune',      41000, 'Finance'),
('Esha Kapoor',   'Delhi',     55000, 'Marketing'),
('Farhan Khan',   'Bengaluru', 72000, 'IT'),
('Gita Rao',      'Ahmedabad', 36000, 'HR'),
('Harsh Vora',    'Surat',     48000, 'Finance'),
('Isha Nair',     'Mumbai',    59000, 'Marketing'),
('Jay Trivedi',   'Ahmedabad', 51000, 'IT');

INSERT INTO sellers (seller_name, city, rating) VALUES
('Ekart Retail Hub',  'Ahmedabad', 4.6),
('TechWorld Traders', 'Mumbai',    4.2),
('StyleKart',         'Delhi',     3.9),
('HomeNeeds Store',   'Bengaluru', 4.8),
('BookBazaar',        'Pune',      3.4),
('Idle Seller',       'Surat',     3.0);

INSERT INTO customers (name, email, mobile_no, city, address) VALUES
('Rahul Mehta',     'rahul.mehta@gmail.com',   '9876500001', 'Ahmedabad', '12 CG Road, Ahmedabad'),
('Riya Shah',       'riya.shah@yahoo.com',     '9876500002', 'Ahmedabad', '45 SG Highway, Ahmedabad'),
('Amit Patel',      'amit.patel@gmail.com',    '9876500003', 'Surat',     '8 Ring Road, Surat'),
('Neha Verma',      'neha.verma@outlook.com',  '9876500004', 'Delhi',     '22 Connaught Place, Delhi'),
('Rohan Gupta',     'rohan.g@gmail.com',       '9876500005', 'Mumbai',    '5 Marine Drive, Mumbai'),
('Sneha Iyer',      'sneha.iyer@gmail.com',    '9876500006', 'Bengaluru', '14 MG Road, Bengaluru'),
('Karan Singh',     'karan.singh@yahoo.com',   '9876500007', 'Delhi',     '9 Lajpat Nagar, Delhi'),
('Pooja Nair',      'pooja.nair@hotmail.com',  '9876500008', 'Pune',      '31 FC Road, Pune'),
('  vikram joshi ', 'vikram.joshi@gmail.com',  '9876500009', 'Ahmedabad', '77 Satellite, Ahmedabad'),
('Anjali Desai',    'anjali.desai@gmail.com',  '9876500010', 'Surat',     '3 Adajan, Surat'),
('Rajesh Kumar',    'rajesh.k@gmail.com',      '9876500011', 'Mumbai',    '18 Andheri, Mumbai'),
('Divya Rao',       'divya.rao@yahoo.com',     '9876500012', 'Bengaluru', '60 Indiranagar, Bengaluru');

INSERT INTO products (product_name, category, price, stock, seller_id) VALUES
('Cotton Shirt',         'Clothing',    899,   120, 3),
('Denim Jeans',          'Clothing',    1999,  80,  3),
('Formal Shirt',         'Clothing',    1299,  60,  3),
('Running Shoes',        'Footwear',    3499,  45,  3),
('Smartphone X1',        'Electronics', 18999, 30,  2),
('Laptop Pro 15',        'Electronics', 54999, 12,  2),
('Bluetooth Headphones', 'Electronics', 2499,  0,   2),
('Smart Watch',          'Electronics', 7999,  8,   2),
('Mixer Grinder',        'Home',        3299,  25,  4),
('Air Fryer',            'Home',        6999,  15,  4),
('Study Table',          'Furniture',   8499,  6,   4),
('Office Chair',         'Furniture',   12499, 10,  4),
('SQL Mastery Book',     'Books',       599,   200, 5),
('Python Handbook',      'Books',       749,   150, 5),
('Tablet Z',             'Electronics', 15999, 20,  1),
('Wireless Mouse',       'Electronics', 799,   90,  1);

-- (customer, product, days_ago, amount, payment, status)
INSERT INTO orders (customer_id, product_id, order_date, amount, payment_method, status) VALUES
(1, 1,  DATE_SUB(CURDATE(), INTERVAL 5   DAY), 899,   'UPI',  'Delivered'),
(1, 5,  DATE_SUB(CURDATE(), INTERVAL 20  DAY), 18999, 'Card', 'Delivered'),
(2, 2,  DATE_SUB(CURDATE(), INTERVAL 8   DAY), 1999,  'COD',  'Delivered'),
(2, 3,  DATE_SUB(CURDATE(), INTERVAL 40  DAY), 1299,  'UPI',  'Delivered'),
(3, 6,  DATE_SUB(CURDATE(), INTERVAL 12  DAY), 54999, 'Card', 'Delivered'),
(3, 16, DATE_SUB(CURDATE(), INTERVAL 60  DAY), 799,   'UPI',  'Delivered'),
(4, 9,  DATE_SUB(CURDATE(), INTERVAL 3   DAY), 3299,  'COD',  'Pending'),
(4, 10, DATE_SUB(CURDATE(), INTERVAL 25  DAY), 6999,  'UPI',  'Delivered'),
(5, 5,  DATE_SUB(CURDATE(), INTERVAL 15  DAY), 18999, 'Card', 'Cancelled'),
(5, 8,  DATE_SUB(CURDATE(), INTERVAL 70  DAY), 7999,  'UPI',  'Delivered'),
(5, 1,  DATE_SUB(CURDATE(), INTERVAL 90  DAY), 899,   'COD',  'Delivered'),
(6, 12, DATE_SUB(CURDATE(), INTERVAL 10  DAY), 12499, 'Card', 'Delivered'),
(6, 11, DATE_SUB(CURDATE(), INTERVAL 35  DAY), 8499,  'UPI',  'Delivered'),
(7, 4,  DATE_SUB(CURDATE(), INTERVAL 2   DAY), 3499,  'COD',  'Pending'),
(7, 3,  DATE_SUB(CURDATE(), INTERVAL 55  DAY), 1299,  'UPI',  'Delivered'),
(8, 15, DATE_SUB(CURDATE(), INTERVAL 18  DAY), 15999, 'Card', 'Delivered'),
(8, 16, DATE_SUB(CURDATE(), INTERVAL 100 DAY), 799,   'COD',  'Delivered'),
(9, 7,  DATE_SUB(CURDATE(), INTERVAL 30  DAY), 2499,  'UPI',  'Delivered'),
(9, 2,  DATE_SUB(CURDATE(), INTERVAL 45  DAY), 1999,  'UPI',  'Cancelled'),
(10, 9, DATE_SUB(CURDATE(), INTERVAL 7   DAY), 3299,  'Card', 'Delivered'),
(10, 1, DATE_SUB(CURDATE(), INTERVAL 150 DAY), 899,   'COD',  'Delivered'),
(1, 16, DATE_SUB(CURDATE(), INTERVAL 75  DAY), 799,   'UPI',  'Delivered'),
(1, 3,  DATE_SUB(CURDATE(), INTERVAL 120 DAY), 1299,  'COD',  'Delivered'),
(3, 5,  DATE_SUB(CURDATE(), INTERVAL 180 DAY), 18999, 'Card', 'Delivered'),
(5, 2,  DATE_SUB(CURDATE(), INTERVAL 200 DAY), 1999,  'UPI',  'Delivered'),
(6, 16, DATE_SUB(CURDATE(), INTERVAL 1   DAY), 799,   'UPI',  'Pending'),
(2, 15, DATE_SUB(CURDATE(), INTERVAL 22  DAY), 15999, 'Card', 'Delivered'),
(4, 1,  DATE_SUB(CURDATE(), INTERVAL 65  DAY), 899,   'UPI',  'Delivered'),
(8, 10, DATE_SUB(CURDATE(), INTERVAL 85  DAY), 6999,  'COD',  'Delivered'),
(10, 12,DATE_SUB(CURDATE(), INTERVAL 14  DAY), 12499, 'UPI',  'Delivered');

-- Orders 7, 9, 19 intentionally have no delivery record.
-- Delivery 'order_id' 999 is an orphan record.
INSERT INTO deliveries (order_id, delivery_partner, delivery_days, delivery_status) VALUES
(1,'Ekart',2,'Delivered'),(2,'Delhivery',4,'Delivered'),(3,'Ekart',3,'Delivered'),
(4,'BlueDart',5,'Delivered'),(5,'Delhivery',6,'Delivered'),(6,'Ekart',2,'Delivered'),
(8,'Ekart',3,'Delivered'),(10,'BlueDart',7,'Delivered'),(11,'Delhivery',4,'Delivered'),
(12,'Ekart',5,'Delivered'),(13,'BlueDart',3,'Delivered'),(15,'Delhivery',2,'Delivered'),
(16,'Ekart',1,'Delivered'),(17,'Delhivery',8,'Delivered'),(18,'BlueDart',4,'Delivered'),
(20,'Ekart',2,'Delivered'),(21,'Delhivery',5,'Delivered'),(22,'Ekart',3,'Delivered'),
(23,'BlueDart',9,'Delivered'),(24,'Delhivery',4,'Delivered'),(25,'Ekart',6,'Delivered'),
(27,'Ekart',2,'Delivered'),(28,'BlueDart',4,'Delivered'),(29,'Delhivery',3,'Delivered'),
(30,'Ekart',2,'Delivered'),
(14,'Ekart',NULL,'In Transit'),(26,'Delhivery',NULL,'In Transit'),
(999,'BlueDart',3,'Delivered');

-- Products 7, 8, 11, 13, 14 intentionally have no reviews.
INSERT INTO reviews (product_id, customer_id, rating, review_date) VALUES
(1, 1, 5, DATE_SUB(CURDATE(), INTERVAL 3  DAY)),
(1, 5, 4, DATE_SUB(CURDATE(), INTERVAL 80 DAY)),
(2, 2, 4, DATE_SUB(CURDATE(), INTERVAL 6  DAY)),
(3, 2, 5, DATE_SUB(CURDATE(), INTERVAL 35 DAY)),
(4, 7, 3, DATE_SUB(CURDATE(), INTERVAL 1  DAY)),
(5, 1, 5, DATE_SUB(CURDATE(), INTERVAL 15 DAY)),
(5, 3, 4, DATE_SUB(CURDATE(), INTERVAL 170 DAY)),
(6, 3, 5, DATE_SUB(CURDATE(), INTERVAL 9  DAY)),
(9, 10,4, DATE_SUB(CURDATE(), INTERVAL 5  DAY)),
(10,4, 5, DATE_SUB(CURDATE(), INTERVAL 20 DAY)),
(12,6, 4, DATE_SUB(CURDATE(), INTERVAL 8  DAY)),
(15,8, 4, DATE_SUB(CURDATE(), INTERVAL 16 DAY)),
(16,3, 3, DATE_SUB(CURDATE(), INTERVAL 55 DAY)),
(16,8, 4, DATE_SUB(CURDATE(), INTERVAL 95 DAY));
