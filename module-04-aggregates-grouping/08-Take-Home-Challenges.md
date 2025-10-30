# Take-Home Challenges (Advanced, Aggregates & Grouping)

Three multi-part exercises using MySQL aggregates and grouping. Includes open-ended components and detailed solutions with trade-offs.

**Beginner Tip:** These challenges require multiple skills combined! Work through each part methodically. Check intermediate results with COUNT(*) to verify your logic. It's okay to revisit earlier exercises if you need a refresher. Compare your approach with the solutions—there's often more than one way!

---

## Challenge 1: Customer Activity Summary (40–50 min)
Scenario: Build summaries of customer activity by city and status.

Schema and sample data
```sql
DROP TABLE IF EXISTS thc4_customers;
CREATE TABLE thc4_customers (
  customer_id INT PRIMARY KEY,
  full_name VARCHAR(60),
  city VARCHAR(40)
);
INSERT INTO thc4_customers VALUES
(1,'Ava Brown','Austin'),(2,'Noah Smith','Dallas'),(3,'Mia Chen','Austin'),(4,'Leo Park',NULL),
(5,'Zoe Li','Seattle'),(6,'Sam Wu','Seattle'),(7,'Ivy Nguyen','Portland'),(8,'Ethan Johnson','Dallas'),
(9,'Olivia Garcia','Austin'),(10,'Lucas Miller','Portland'),(11,'Emma Davis',NULL),(12,'William Moore','Seattle');

DROP TABLE IF EXISTS thc4_orders;
CREATE TABLE thc4_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  status VARCHAR(20)
);
INSERT INTO thc4_orders VALUES
(101,1,'2025-03-01','shipped'),(102,2,'2025-03-02','shipped'),(103,3,'2025-03-02','processing'),
(104,3,'2025-03-03','cancelled'),(105,5,'2025-03-05','processing'),(106,6,'2025-03-06','shipped'),
(107,7,'2025-03-07','processing'),(108,8,'2025-03-08','shipped'),(109,9,'2025-03-09','shipped'),
(110,10,'2025-03-10','cancelled'),(111,11,'2025-03-11','processing'),(112,12,'2025-03-12','shipped'),
(113,1,'2025-03-13','processing'),(114,2,'2025-03-14','cancelled'),(115,4,'2025-03-15','shipped'),
(116,4,'2025-03-16','processing');
```
Parts
A) Orders per status overall.
B) Orders per city (NULL as 'Unknown').
C) Orders per city and status with counts.
D) Open-ended: Identify the top city by shipped orders and include ties.

Solutions and notes
```sql
-- A
SELECT status, COUNT(*) AS cnt
FROM thc4_orders
GROUP BY status
ORDER BY cnt DESC, status;

-- B
SELECT COALESCE(city,'Unknown') AS city_label, COUNT(*) AS orders_cnt
FROM thc4_orders o
JOIN thc4_customers c ON c.customer_id = o.customer_id
GROUP BY COALESCE(city,'Unknown')
ORDER BY orders_cnt DESC, city_label;

-- C
SELECT COALESCE(city,'Unknown') AS city_label, status, COUNT(*) AS cnt
FROM thc4_orders o
JOIN thc4_customers c ON c.customer_id = o.customer_id
GROUP BY COALESCE(city,'Unknown'), status
ORDER BY city_label, cnt DESC;

-- D (top city by shipped, ties included)
WITH shipped AS (
  SELECT COALESCE(city,'Unknown') AS city_label, COUNT(*) AS shipped_cnt
  FROM thc4_orders o
  JOIN thc4_customers c ON c.customer_id = o.customer_id
  WHERE status = 'shipped'
  GROUP BY COALESCE(city,'Unknown')
)
SELECT s.*
FROM shipped s
WHERE s.shipped_cnt = (SELECT MAX(shipped_cnt) FROM shipped)
ORDER BY s.city_label;
```
Trade-offs
- CTE used for readability; can be replaced by a subquery if desired.
- Consider indexing `orders.status` and `orders.customer_id` for performance.

---

## Challenge 2: Category Sales Metrics (45–55 min)
Scenario: Summarize category performance with items sold and revenue.

Schema and sample data
```sql
DROP TABLE IF EXISTS thc4_products;
CREATE TABLE thc4_products (
  product_id INT PRIMARY KEY,
  name VARCHAR(60),
  category VARCHAR(30),
  price DECIMAL(7,2)
);
INSERT INTO thc4_products VALUES
(1,'Notebook','stationery',4.99),(2,'Desk Lamp','home',12.00),(3,'Yoga Mat','fitness',24.50),
(4,'Coffee Mug','kitchen',7.99),(5,'Pen Set','stationery',3.75),(6,'Throw Pillow','home',18.00),
(7,'Water Bottle','fitness',15.00),(8,'Cutting Board','kitchen',13.50),(9,'LED Strip','home',22.00),
(10,'Mouse Pad','electronics',9.50);

DROP TABLE IF EXISTS thc4_order_items;
CREATE TABLE thc4_order_items (
  order_item_id INT PRIMARY KEY,
  order_id INT,
  product_id INT,
  qty INT
);
INSERT INTO thc4_order_items VALUES
(1,101,1,2),(2,101,4,1),(3,102,2,1),(4,102,5,3),(5,103,3,1),(6,104,3,1),
(7,105,1,2),(8,106,6,2),(9,106,2,1),(10,107,5,1),(11,108,5,2),(12,109,1,1),
(13,110,7,2),(14,111,8,1),(15,112,9,1),(16,112,10,1),(17,113,4,3),(18,114,2,2),
(19,115,7,1),(20,115,3,1),(21,116,6,1),(22,116,8,1);
```
Parts
A) Items sold by category: `SUM(qty)` ignoring NULL.
B) Revenue by category: `SUM(qty*price)` using a join.
C) Average line value by category: `AVG(qty*price)`, NULL-safe.
D) Open-ended: Return top 2 categories by revenue and include a `rank` label (1 or 2). Prefer a window function; for older versions, use a CASE plus correlated subqueries.

Solutions and notes
```sql
-- A
SELECT p.category, SUM(COALESCE(oi.qty,0)) AS items_sold
FROM thc4_order_items oi
JOIN thc4_products p ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY items_sold DESC, p.category;

-- B
SELECT p.category, SUM(COALESCE(oi.qty,0) * p.price) AS revenue
FROM thc4_order_items oi
JOIN thc4_products p ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- C
SELECT p.category,
       AVG(CASE WHEN oi.qty IS NULL THEN NULL ELSE oi.qty * p.price END) AS avg_line_value
FROM thc4_order_items oi
JOIN thc4_products p ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY avg_line_value DESC;

-- D (rank top 2 by revenue)
SELECT category, revenue,
       CASE WHEN rn = 1 THEN 1 WHEN rn = 2 THEN 2 END AS rank_label
FROM (
  SELECT p.category, SUM(COALESCE(oi.qty,0) * p.price) AS revenue,
         ROW_NUMBER() OVER (ORDER BY SUM(COALESCE(oi.qty,0) * p.price) DESC) AS rn
  FROM thc4_order_items oi
  JOIN thc4_products p ON p.product_id = oi.product_id
  GROUP BY p.category
) x
WHERE rn <= 2
ORDER BY rn;
```
Trade-offs
- Window functions require MySQL 8.0+; fallback would use correlated subqueries.

---

## Challenge 3: Monthly Trend with Thresholds (50–60 min)
Scenario: Create a month-over-month orders trend and flag low-volume months.

Schema and sample data
```sql
DROP TABLE IF EXISTS thc4_orders_dates;
CREATE TABLE thc4_orders_dates (
  id INT PRIMARY KEY,
  order_date DATE
);
INSERT INTO thc4_orders_dates VALUES
(1,'2025-01-01'),(2,'2025-01-15'),(3,'2025-01-20'),
(4,'2025-02-10'),(5,'2025-02-11'),(6,'2025-02-28'),
(7,'2025-03-01'),(8,'2025-03-20'),
(9,'2025-04-05'),(10,'2025-04-18'),
(11,'2025-05-07'),(12,'2025-06-22');
```
Parts
A) Group by month label `DATE_FORMAT(order_date,'%Y-%m')` and count orders.
B) Add a `volume_flag` column: 'low' (<2), 'ok' (2–3), 'high' (>3) using CASE on counts in a wrapping SELECT.
C) Open-ended: Ensure chronological ordering and provide a pretty `month_name` like 'January 2025'.

Solutions and notes
```sql
-- A
SELECT DATE_FORMAT(order_date,'%Y-%m') AS ym, COUNT(*) AS orders_cnt
FROM thc4_orders_dates
GROUP BY DATE_FORMAT(order_date,'%Y-%m')
ORDER BY ym;

-- B (wrap to label thresholds)
SELECT ym, orders_cnt,
       CASE WHEN orders_cnt < 2 THEN 'low'
            WHEN orders_cnt <= 3 THEN 'ok'
            ELSE 'high' END AS volume_flag
FROM (
  SELECT DATE_FORMAT(order_date,'%Y-%m') AS ym, COUNT(*) AS orders_cnt
  FROM thc4_orders_dates
  GROUP BY DATE_FORMAT(order_date,'%Y-%m')
) t
ORDER BY ym;

-- C (pretty month label)
SELECT DATE_FORMAT(STR_TO_DATE(CONCAT(ym,'-01'), '%Y-%m-%d'), '%M %Y') AS month_name,
       orders_cnt
FROM (
  SELECT DATE_FORMAT(order_date,'%Y-%m') AS ym, COUNT(*) AS orders_cnt
  FROM thc4_orders_dates
  GROUP BY DATE_FORMAT(order_date,'%Y-%m')
) t
ORDER BY ym;
```
Trade-offs
- Wrapping the aggregate lets you label counts cleanly.
- For large tables, pre-aggregate into summary tables.
