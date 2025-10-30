# Real-World Project — Marketplace Sales (45–60 min)

Company background
- Acme Marketplace connects customers with multiple stores. Each order can have multiple items. Operations wants insights across stores, categories, and customers.

Business problem
- Produce store- and category-level performance, identify underperforming entities, and compute customer lifetime value.

Database (6 tables, 30+ rows total)
```sql
-- Stores
DROP TABLE IF EXISTS rwp5_stores;
CREATE TABLE rwp5_stores (store_id INT PRIMARY KEY, name VARCHAR(60), city VARCHAR(40));
INSERT INTO rwp5_stores VALUES
(1,'Central','Austin'),(2,'North','Dallas'),(3,'West','Seattle');

-- Employees (store-level sales reps)
DROP TABLE IF EXISTS rwp5_employees;
CREATE TABLE rwp5_employees (emp_id INT PRIMARY KEY, full_name VARCHAR(60), store_id INT);
INSERT INTO rwp5_employees VALUES
(10,'Alice',1),(11,'Bob',1),(12,'Cara',2),(13,'Drew',2),(14,'Evan',3);

-- Customers
DROP TABLE IF EXISTS rwp5_customers;
CREATE TABLE rwp5_customers (customer_id INT PRIMARY KEY, full_name VARCHAR(60), city VARCHAR(40));
INSERT INTO rwp5_customers VALUES
(100,'Ava Brown','Austin'),(101,'Noah Smith','Dallas'),(102,'Mia Chen','Austin'),(103,'Leo Park','Seattle'),
(104,'Zoe Li','Seattle'),(105,'Sam Wu','Seattle'),(106,'Ivy Nguyen','Dallas'),(107,'Ethan Johnson','Austin');

-- Products and categories
DROP TABLE IF EXISTS rwp5_categories;
CREATE TABLE rwp5_categories (category_id INT PRIMARY KEY, name VARCHAR(40));
INSERT INTO rwp5_categories VALUES (1,'stationery'),(2,'home'),(3,'kitchen'),(4,'electronics');

DROP TABLE IF EXISTS rwp5_products;
CREATE TABLE rwp5_products (product_id INT PRIMARY KEY, category_id INT, name VARCHAR(60), price DECIMAL(7,2));
INSERT INTO rwp5_products VALUES
(1,1,'Notebook',4.99),(2,1,'Pen Set',3.50),(3,2,'Lamp',12.00),(4,2,'LED Strip',22.00),
(5,3,'Mug',7.99),(6,3,'Cutting Board',13.50),(7,4,'Mouse',19.00),(8,4,'Keyboard',39.00),
(9,2,'Throw Pillow',18.00),(10,1,'Stapler',8.99);

-- Orders (taken by employee at a store)
DROP TABLE IF EXISTS rwp5_orders;
CREATE TABLE rwp5_orders (order_id INT PRIMARY KEY, customer_id INT, store_id INT, emp_id INT, order_date DATE);
INSERT INTO rwp5_orders VALUES
(2001,100,1,10,'2025-03-01'),(2002,101,2,12,'2025-03-01'),(2003,100,1,11,'2025-03-02'),(2004,102,1,10,'2025-03-03'),
(2005,103,3,14,'2025-03-04'),(2006,104,3,14,'2025-03-04'),(2007,105,3,14,'2025-03-05'),(2008,106,2,13,'2025-03-06'),
(2009,107,1,11,'2025-03-07'),(2010,106,2,13,'2025-03-08');

-- Order items
DROP TABLE IF EXISTS rwp5_order_items;
CREATE TABLE rwp5_order_items (order_item_id INT PRIMARY KEY, order_id INT, product_id INT, qty INT);
INSERT INTO rwp5_order_items VALUES
(1,2001,1,2),(2,2001,5,1),(3,2002,3,1),(4,2002,4,1),(5,2003,2,3),(6,2003,1,1),(7,2004,6,1),(8,2004,7,1),
(9,2005,5,2),(10,2005,9,1),(11,2006,3,1),(12,2007,5,1),(13,2007,1,2),(14,2008,8,1),(15,2008,7,1),
(16,2009,10,1),(17,2009,2,2),(18,2010,4,1),(19,2010,3,1),(20,2010,1,1);
```

Deliverables and acceptance criteria
1) Revenue by store
- Return store name and total revenue (qty*price). Include stores with zero revenue.
- Acceptance: One row per store, numbers >= 0, ordered by revenue desc.

2) Top category per store
- Return store, category, and revenue for the top category in that store (ties allowed).
- Acceptance: At least one category per store, uses proper partitioning to rank.

3) Customer lifetime value (CLV)
- Return customer name and total revenue across all orders.
- Acceptance: Customers with no orders appear with 0, ordered desc.

4) Employee productivity
- Return employee name, store, number of orders taken, and revenue from their orders.
- Acceptance: Employees with zero orders appear with 0 counts and 0 revenue.

5) Monthly revenue trend
- Return month label (YYYY-MM) and total revenue.
- Acceptance: Correct grouping by month, ordered chronologically.

Bonus objectives
- Add a metric: average order value by store.
- Identify customers who only bought from a single category (semi-join logic).

Evaluation rubric (10 pts total)
- Correctness (4): Outputs match acceptance criteria.
- Readability (3): Clear JOINs, aliases, and formatting.
- Robustness (2): Handles NULLs/unmatched rows.
- Performance (1): Avoids unnecessary cross joins; pre-aggregates when helpful.

Model solutions
```sql
-- 1) Revenue by store (include 0)
SELECT s.name AS store,
       COALESCE(SUM(oi.qty * p.price),0) AS revenue
FROM rwp5_stores s
LEFT JOIN rwp5_orders o ON o.store_id = s.store_id
LEFT JOIN rwp5_order_items oi ON oi.order_id = o.order_id
LEFT JOIN rwp5_products p ON p.product_id = oi.product_id
GROUP BY s.name
ORDER BY revenue DESC, s.name;

-- 2) Top category per store (ties allowed)
WITH store_category AS (
  SELECT s.store_id, s.name AS store, c.name AS category,
         SUM(oi.qty * p.price) AS revenue,
         DENSE_RANK() OVER (
           PARTITION BY s.store_id
           ORDER BY SUM(oi.qty * p.price) DESC
         ) AS rnk
  FROM rwp5_stores s
  JOIN rwp5_orders o ON o.store_id = s.store_id
  JOIN rwp5_order_items oi ON oi.order_id = o.order_id
  JOIN rwp5_products p ON p.product_id = oi.product_id
  JOIN rwp5_categories c ON c.category_id = p.category_id
  GROUP BY s.store_id, s.name, c.name
)
SELECT store, category, revenue
FROM store_category
WHERE rnk = 1
ORDER BY store, category;

-- 3) Customer lifetime value (include 0)
SELECT c.full_name AS customer,
       COALESCE(SUM(oi.qty * p.price),0) AS clv
FROM rwp5_customers c
LEFT JOIN rwp5_orders o ON o.customer_id = c.customer_id
LEFT JOIN rwp5_order_items oi ON oi.order_id = o.order_id
LEFT JOIN rwp5_products p ON p.product_id = oi.product_id
GROUP BY c.full_name
ORDER BY clv DESC, customer;

-- 4) Employee productivity (include zeros)
SELECT e.full_name AS employee, s.name AS store,
       COUNT(DISTINCT o.order_id) AS orders_taken,
       COALESCE(SUM(oi.qty * p.price),0) AS revenue
FROM rwp5_employees e
JOIN rwp5_stores s ON s.store_id = e.store_id
LEFT JOIN rwp5_orders o ON o.emp_id = e.emp_id
LEFT JOIN rwp5_order_items oi ON oi.order_id = o.order_id
LEFT JOIN rwp5_products p ON p.product_id = oi.product_id
GROUP BY e.full_name, s.name
ORDER BY revenue DESC, employee;

-- 5) Monthly revenue trend
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS ym,
       SUM(oi.qty * p.price) AS revenue
FROM rwp5_orders o
JOIN rwp5_order_items oi ON oi.order_id = o.order_id
JOIN rwp5_products p ON p.product_id = oi.product_id
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
ORDER BY ym;
```

Performance notes
- Pre-aggregate order_items by product or by order before joining to reduce row counts.
- Index join keys: orders(store_id, customer_id, emp_id), order_items(order_id, product_id), products(product_id, category_id).
- For large data, consider summary tables for daily/monthly revenue.
