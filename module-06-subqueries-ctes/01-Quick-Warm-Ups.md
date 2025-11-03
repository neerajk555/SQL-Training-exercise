# Quick Warm-Ups — Subqueries & CTEs (5–10 min each)

Each exercise includes a tiny setup, a task, expected output, and an answer. Run each in its own session.

## 📋 Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Write scalar subqueries (return one value)
- Use EXISTS for semi-joins (check if related rows exist)
- Handle NOT IN vs NOT EXISTS with NULL safety
- Create CTEs with WITH clause for readable multi-step queries
- Understand correlated vs non-correlated subqueries

### Key Subquery Concepts for Beginners
**Types of Subqueries:**
1. **Scalar subquery**: Returns exactly one value (one row, one column)
   - Used in SELECT, WHERE, or HAVING
   - Example: `(SELECT AVG(price) FROM products)`

2. **Row subquery**: Returns one row with multiple columns
   - Example: `(SELECT MIN(price), MAX(price) FROM products)`

3. **Table subquery**: Returns multiple rows and columns
   - Used in FROM (derived table) or with IN/EXISTS
   - Example: `(SELECT category, AVG(price) FROM products GROUP BY category)`

**EXISTS vs IN:**
- `EXISTS`: Checks if any row exists (stops at first match—efficient!)
- `IN`: Checks if value matches any in a list
- `NOT IN` with NULLs: Returns no results! (Use NOT EXISTS instead)

**CTEs (Common Table Expressions):**
- Defined with WITH clause before main query
- Makes complex queries readable and testable
- Can reference earlier CTEs in the same WITH clause
- Syntax: `WITH cte_name AS (SELECT ...) SELECT ... FROM cte_name`

### Execution Tips
1. **Test inner queries first**: Run subquery separately to verify results
2. **Check for NULLs**: Use NOT EXISTS instead of NOT IN when NULLs possible
3. **CTEs for clarity**: Use WITH when query has multiple steps
4. **Correlated subqueries**: Reference outer table in inner query

**Beginner Tip:** Subqueries are queries inside queries. CTEs (WITH clause) make complex queries easier to read. EXISTS checks if a related row exists. These patterns help you break down complex problems into manageable pieces!

---

## 1) Scalar Subquery in SELECT — 7 min
Scenario: Show each product with its category name via scalar subquery.

Sample data
```sql
DROP TABLE IF EXISTS wu6_categories;
CREATE TABLE wu6_categories (category_id INT PRIMARY KEY, name VARCHAR(40));
INSERT INTO wu6_categories VALUES (1,'stationery'),(2,'home');

DROP TABLE IF EXISTS wu6_products;
CREATE TABLE wu6_products (product_id INT PRIMARY KEY, category_id INT, name VARCHAR(60));
INSERT INTO wu6_products VALUES (10,1,'Notebook'),(11,2,'Lamp');
```
Task: Return product name and category (via subquery in SELECT).

Expected output
```
name     | category
Notebook | stationery
Lamp     | home
```

Solution
```sql
SELECT p.name,
  (SELECT c.name FROM wu6_categories c WHERE c.category_id = p.category_id) AS category
FROM wu6_products p
ORDER BY p.name;
```

---

## 2) EXISTS (semi-join) — 6 min
Scenario: List customers who have at least one order.

Sample data
```sql
DROP TABLE IF EXISTS wu6_customers;
CREATE TABLE wu6_customers (customer_id INT PRIMARY KEY, full_name VARCHAR(60));
INSERT INTO wu6_customers VALUES (1,'Ava'),(2,'Noah'),(3,'Mia');

DROP TABLE IF EXISTS wu6_orders;
CREATE TABLE wu6_orders (order_id INT PRIMARY KEY, customer_id INT);
INSERT INTO wu6_orders VALUES (100,1),(101,1),(102,2);
```
Task: Return full_name for customers with an order.

Expected output
```
full_name
Ava
Noah
```

Solution
```sql
SELECT c.full_name
FROM wu6_customers c
WHERE EXISTS (
  SELECT 1 FROM wu6_orders o WHERE o.customer_id = c.customer_id
)
ORDER BY c.full_name;
```

---

## 3) NOT IN vs NOT EXISTS with NULLs — 9 min
Scenario: Find products not ordered; ensure NULL-safety.

Sample data
```sql
DROP TABLE IF EXISTS wu6_p;
CREATE TABLE wu6_p (product_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO wu6_p VALUES (1,'Notebook'),(2,'Lamp'),(3,'Mug');

DROP TABLE IF EXISTS wu6_oi;
CREATE TABLE wu6_oi (order_item_id INT PRIMARY KEY, product_id INT);
INSERT INTO wu6_oi VALUES (1,1),(2,NULL); -- note NULL product_id
```
Task: Return product names never appearing in order items.

Expected output
```
name
Lamp
Mug
```

Solution (prefer NOT EXISTS)
```sql
SELECT p.name
FROM wu6_p p
WHERE NOT EXISTS (
  SELECT 1 FROM wu6_oi oi WHERE oi.product_id = p.product_id
)
ORDER BY p.name;
-- Avoid NOT IN (SELECT product_id ... ) when subquery may return NULL.
```

---

## 4) Derived Table (FROM subquery) — 7 min
Scenario: Count orders per customer using a subquery in FROM.

Sample data
```sql
-- reuse wu6_customers and wu6_orders from #2
```
Task: Return customer name and order_count using a derived table alias t.

Expected output
```
full_name | order_count
Ava       | 2
Mia       | 0
Noah      | 1
```

Solution
```sql
SELECT c.full_name, COALESCE(t.order_count,0) AS order_count
FROM wu6_customers c
LEFT JOIN (
  SELECT o.customer_id, COUNT(*) AS order_count
  FROM wu6_orders o
  GROUP BY o.customer_id
) t ON t.customer_id = c.customer_id
ORDER BY c.full_name;
```

---

## 5) Simple CTE for Staging — 8 min
Scenario: Stage active students, then count enrollments.

Sample data
```sql
DROP TABLE IF EXISTS wu6_students;
CREATE TABLE wu6_students (student_id INT PRIMARY KEY, name VARCHAR(60), active TINYINT);
INSERT INTO wu6_students VALUES (1,'Ava',1),(2,'Noah',0),(3,'Mia',1);

DROP TABLE IF EXISTS wu6_enrollments;
CREATE TABLE wu6_enrollments (student_id INT, course_code VARCHAR(10));
INSERT INTO wu6_enrollments VALUES (1,'CS101'),(3,'DS201'),(3,'CS101');
```
Task: Using a CTE `active_students`, return name and enrollment_count for active students only.

Expected output
```
name | enrollment_count
Ava  | 1
Mia  | 2
```

Solution
```sql
WITH active_students AS (
  SELECT student_id, name FROM wu6_students WHERE active = 1
)
SELECT a.name, COUNT(e.course_code) AS enrollment_count
FROM active_students a
LEFT JOIN wu6_enrollments e ON e.student_id = a.student_id
GROUP BY a.name
ORDER BY a.name;
```
