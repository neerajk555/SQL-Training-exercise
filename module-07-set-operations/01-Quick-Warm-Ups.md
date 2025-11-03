# Quick Warm-Ups — Set Operations (5–10 min each)

Each exercise includes a tiny setup, a task, expected output, and an answer. Run each in its own session.

**Beginner Tip:** Set operations combine results from multiple queries. UNION removes duplicates, UNION ALL keeps them all. INTERSECT finds common rows, EXCEPT finds differences. Always match column count and types!

---

## 1) Combine Active and Inactive Users (UNION) — 7 min
Scenario: Merge two user lists and remove duplicates.

Sample data
```sql
DROP TABLE IF EXISTS wu7_active_users;
CREATE TABLE wu7_active_users (user_id INT PRIMARY KEY, username VARCHAR(60));
INSERT INTO wu7_active_users VALUES (1,'alice'),(2,'bob'),(3,'carol');

DROP TABLE IF EXISTS wu7_inactive_users;
CREATE TABLE wu7_inactive_users (user_id INT PRIMARY KEY, username VARCHAR(60));
INSERT INTO wu7_inactive_users VALUES (3,'carol'),(4,'dave'),(5,'eve');
```
Task: Return all unique user_id and username from both tables.

Expected output
```
user_id | username
1       | alice
2       | bob
3       | carol
4       | dave
5       | eve
```

Solution
```sql
-- UNION automatically removes duplicates (carol appears once)
SELECT user_id, username FROM wu7_active_users
UNION
SELECT user_id, username FROM wu7_inactive_users
ORDER BY user_id;
```

---

## 2) All Orders Including Duplicates (UNION ALL) — 6 min
Scenario: Combine current and archived orders, keeping all rows.

Sample data
```sql
DROP TABLE IF EXISTS wu7_current_orders;
CREATE TABLE wu7_current_orders (order_id INT, amount DECIMAL(8,2));
INSERT INTO wu7_current_orders VALUES (101,50.00),(102,75.50);

DROP TABLE IF EXISTS wu7_archived_orders;
CREATE TABLE wu7_archived_orders (order_id INT, amount DECIMAL(8,2));
INSERT INTO wu7_archived_orders VALUES (102,75.50),(103,120.00);
```
Task: Return all orders from both tables (including duplicates).

Expected output
```
order_id | amount
101      | 50.00
102      | 75.50
102      | 75.50
103      | 120.00
```

Solution
```sql
-- UNION ALL keeps all rows, even duplicates
SELECT order_id, amount FROM wu7_current_orders
UNION ALL
SELECT order_id, amount FROM wu7_archived_orders
ORDER BY order_id;
```

---

## 3) Common Products (INTERSECT Alternative) — 8 min
Scenario: Find products available in both warehouses.

Sample data
```sql
DROP TABLE IF EXISTS wu7_warehouse_a;
CREATE TABLE wu7_warehouse_a (product_id INT PRIMARY KEY, product_name VARCHAR(60));
INSERT INTO wu7_warehouse_a VALUES (1,'Laptop'),(2,'Mouse'),(3,'Keyboard');

DROP TABLE IF EXISTS wu7_warehouse_b;
CREATE TABLE wu7_warehouse_b (product_id INT PRIMARY KEY, product_name VARCHAR(60));
INSERT INTO wu7_warehouse_b VALUES (2,'Mouse'),(3,'Keyboard'),(4,'Monitor');
```
Task: Return products that exist in BOTH warehouses (use INNER JOIN or INTERSECT if MySQL 8.0.31+).

Expected output
```
product_id | product_name
2          | Mouse
3          | Keyboard
```

Solution (INNER JOIN for compatibility)
```sql
-- Simulate INTERSECT with INNER JOIN
SELECT DISTINCT a.product_id, a.product_name
FROM wu7_warehouse_a a
INNER JOIN wu7_warehouse_b b ON a.product_id = b.product_id
ORDER BY a.product_id;

-- Or with INTERSECT (MySQL 8.0.31+)
-- SELECT product_id, product_name FROM wu7_warehouse_a
-- INTERSECT
-- SELECT product_id, product_name FROM wu7_warehouse_b
-- ORDER BY product_id;
```

---

## 4) Products Only in Warehouse A (EXCEPT Alternative) — 8 min
Scenario: Find products in warehouse A but NOT in warehouse B.

Sample data
```sql
DROP TABLE IF EXISTS wu7_wh_a;
CREATE TABLE wu7_wh_a (product_id INT PRIMARY KEY);
INSERT INTO wu7_wh_a VALUES (10),(11),(12);

DROP TABLE IF EXISTS wu7_wh_b;
CREATE TABLE wu7_wh_b (product_id INT PRIMARY KEY);
INSERT INTO wu7_wh_b VALUES (11),(13);
```
Task: Return product_id from A that's NOT in B (use LEFT JOIN ... IS NULL or EXCEPT).

Expected output
```
product_id
10
12
```

Solution (LEFT JOIN for compatibility)
```sql
-- Simulate EXCEPT with LEFT JOIN ... IS NULL
SELECT a.product_id
FROM wu7_wh_a a
LEFT JOIN wu7_wh_b b ON a.product_id = b.product_id
WHERE b.product_id IS NULL
ORDER BY a.product_id;

-- Or with EXCEPT (MySQL 8.0.31+)
-- SELECT product_id FROM wu7_wh_a
-- EXCEPT
-- SELECT product_id FROM wu7_wh_b
-- ORDER BY product_id;
```

---

## 5) Three-Way Union with Labels — 9 min
Scenario: Combine three employee lists with source labels.

Sample data
```sql
DROP TABLE IF EXISTS wu7_full_time;
CREATE TABLE wu7_full_time (emp_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO wu7_full_time VALUES (1,'Alice'),(2,'Bob');

DROP TABLE IF EXISTS wu7_part_time;
CREATE TABLE wu7_part_time (emp_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO wu7_part_time VALUES (3,'Carol');

DROP TABLE IF EXISTS wu7_contractors;
CREATE TABLE wu7_contractors (emp_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO wu7_contractors VALUES (4,'Dave'),(5,'Eve');
```
Task: Combine all employees with a source column ('FT', 'PT', 'Contractor').

Expected output
```
emp_id | name  | source
1      | Alice | FT
2      | Bob   | FT
3      | Carol | PT
4      | Dave  | Contractor
5      | Eve   | Contractor
```

Solution
```sql
-- Use UNION ALL to keep all rows and add literal labels
SELECT emp_id, name, 'FT' AS source FROM wu7_full_time
UNION ALL
SELECT emp_id, name, 'PT' AS source FROM wu7_part_time
UNION ALL
SELECT emp_id, name, 'Contractor' AS source FROM wu7_contractors
ORDER BY emp_id;
```

---

**Time Estimate Check:** Each warm-up should take 5–10 minutes. If you're taking longer, focus on understanding the set operation syntax. If faster, great—you're ready for guided activities!

**Next Step:** Move to `02-Guided-Step-by-Step.md` for structured scenarios with checkpoints.
