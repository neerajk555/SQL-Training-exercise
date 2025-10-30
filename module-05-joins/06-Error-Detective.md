# Error Detective — Joins (5 challenges)

Each challenge includes a scenario, broken query, error or wrong result, sample data, expected output, guiding questions, and a fix explanation.

**Beginner Tip:** Join bugs often produce too many rows (cartesian product) or too few (wrong join type). Count rows before and after joining. Check your ON conditions carefully. These exercises teach you to spot common join pitfalls!

---

## ED1) The Accidental CROSS JOIN
Scenario: Analyst forgot the ON clause between orders and customers.

Sample data
```sql
DROP TABLE IF EXISTS ed5_1_customers;
CREATE TABLE ed5_1_customers (customer_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO ed5_1_customers VALUES (1,'Ava'),(2,'Noah');

DROP TABLE IF EXISTS ed5_1_orders;
CREATE TABLE ed5_1_orders (order_id INT PRIMARY KEY, customer_id INT);
INSERT INTO ed5_1_orders VALUES (10,1),(11,2);
```
Broken query and symptom
```sql
SELECT * FROM ed5_1_orders o JOIN ed5_1_customers c; -- returns 4 rows (cartesian)
```
Expected output
```
order_id | customer_id | name
10       | 1           | Ava
11       | 2           | Noah
```
Guiding questions
- What clause is missing? How many rows should join return?

Fix and explanation
```sql
SELECT o.order_id, o.customer_id, c.name
FROM ed5_1_orders o
JOIN ed5_1_customers c ON c.customer_id = o.customer_id;
-- ON specifies the join key; without it you get a CROSS JOIN (cartesian product).
```

---

## ED2) LEFT JOIN turned INNER by WHERE filter
Scenario: We want all courses even without enrollments, but WHERE filters rows on the right table.

Sample data
```sql
DROP TABLE IF EXISTS ed5_2_courses;
CREATE TABLE ed5_2_courses (course_id INT PRIMARY KEY, code VARCHAR(10));
INSERT INTO ed5_2_courses VALUES (1,'CS101'),(2,'DS201');

DROP TABLE IF EXISTS ed5_2_enrollments;
CREATE TABLE ed5_2_enrollments (course_id INT, student_id INT);
INSERT INTO ed5_2_enrollments VALUES (1,101);
```
Broken query
```sql
SELECT c.code, e.student_id
FROM ed5_2_courses c
LEFT JOIN ed5_2_enrollments e ON e.course_id = c.course_id
WHERE e.student_id IS NOT NULL; -- drops DS201
```
Expected output
```
code  | student_id
CS101 | 101
DS201 | NULL
```
Fix and explanation
```sql
SELECT c.code, e.student_id
FROM ed5_2_courses c
LEFT JOIN ed5_2_enrollments e ON e.course_id = c.course_id
-- remove WHERE predicate that eliminates NULLs (or move predicates to ON)
ORDER BY c.code;
```
Explanation: Filtering the right-side columns in WHERE after a LEFT JOIN removes NULL-extended rows, effectively making it an INNER JOIN.

---

## ED3) Duplicate Counting in Many-to-Many
Scenario: Counting customers by category after joining customers→orders→items→products duplicates rows and inflates counts.

Sample data
```sql
DROP TABLE IF EXISTS ed5_3_customers;
CREATE TABLE ed5_3_customers (customer_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO ed5_3_customers VALUES (1,'Ava'),(2,'Noah');

DROP TABLE IF EXISTS ed5_3_orders;
CREATE TABLE ed5_3_orders (order_id INT PRIMARY KEY, customer_id INT);
INSERT INTO ed5_3_orders VALUES (100,1),(101,1),(102,2);

DROP TABLE IF EXISTS ed5_3_products;
CREATE TABLE ed5_3_products (product_id INT PRIMARY KEY, category VARCHAR(30));
INSERT INTO ed5_3_products VALUES (1,'stationery'),(2,'home');

DROP TABLE IF EXISTS ed5_3_order_items;
CREATE TABLE ed5_3_order_items (order_item_id INT PRIMARY KEY, order_id INT, product_id INT);
INSERT INTO ed5_3_order_items VALUES (1,100,1),(2,100,2),(3,101,1),(4,102,2);
```
Broken approach
```sql
SELECT p.category, COUNT(o.customer_id) AS customers
FROM ed5_3_customers c
JOIN ed5_3_orders o ON o.customer_id = c.customer_id
JOIN ed5_3_order_items oi ON oi.order_id = o.order_id
JOIN ed5_3_products p ON p.product_id = oi.product_id
GROUP BY p.category; -- customers inflated by multiple items/orders
```
Expected output (distinct customers per category)
```
category    | customers
home        | 2
stationery  | 1
```
Fix and explanation
```sql
SELECT p.category, COUNT(DISTINCT o.customer_id) AS customers
FROM ed5_3_orders o
JOIN ed5_3_order_items oi ON oi.order_id = o.order_id
JOIN ed5_3_products p ON p.product_id = oi.product_id
GROUP BY p.category;
-- DISTINCT removes duplicates caused by many-to-many joins.
```

---

## ED4) Wrong Join Key
Scenario: Orders were joined to products directly on product_id (missing order_items), causing NULLs or mismatches.

Sample data
```sql
DROP TABLE IF EXISTS ed5_4_orders;
CREATE TABLE ed5_4_orders (order_id INT PRIMARY KEY);
INSERT INTO ed5_4_orders VALUES (2001),(2002);

DROP TABLE IF EXISTS ed5_4_products;
CREATE TABLE ed5_4_products (product_id INT PRIMARY KEY, price DECIMAL(7,2));
INSERT INTO ed5_4_products VALUES (1,4.99),(2,12.00);

DROP TABLE IF EXISTS ed5_4_order_items;
CREATE TABLE ed5_4_order_items (order_item_id INT PRIMARY KEY, order_id INT, product_id INT, qty INT);
INSERT INTO ed5_4_order_items VALUES (1,2001,1,2),(2,2002,2,1);
```
Broken query
```sql
SELECT o.order_id, SUM(p.price) AS revenue
FROM ed5_4_orders o
LEFT JOIN ed5_4_products p ON p.product_id = o.order_id -- nonsensical key
GROUP BY o.order_id;
```
Fix and explanation
```sql
SELECT o.order_id, SUM(oi.qty * p.price) AS revenue
FROM ed5_4_orders o
JOIN ed5_4_order_items oi ON oi.order_id = o.order_id
JOIN ed5_4_products p ON p.product_id = oi.product_id
GROUP BY o.order_id;
-- Join on the bridge (order_items) where the relationship exists.
```

---

## ED5) Ambiguous Column Name
Scenario: Column `customer_id` exists in both tables; query omits table alias.

Sample data
```sql
DROP TABLE IF EXISTS ed5_5_customers;
CREATE TABLE ed5_5_customers (customer_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO ed5_5_customers VALUES (1,'Ava');

DROP TABLE IF EXISTS ed5_5_orders;
CREATE TABLE ed5_5_orders (order_id INT PRIMARY KEY, customer_id INT);
INSERT INTO ed5_5_orders VALUES (10,1);
```
Broken query (error)
```sql
SELECT customer_id FROM ed5_5_orders o JOIN ed5_5_customers c ON customer_id = c.customer_id;
-- Error: Column 'customer_id' in on clause is ambiguous
```
Fix and explanation
```sql
SELECT o.customer_id
FROM ed5_5_orders o JOIN ed5_5_customers c ON o.customer_id = c.customer_id;
-- Always qualify shared column names using table aliases.
```
