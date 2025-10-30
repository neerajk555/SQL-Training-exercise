# Independent Practice — Joins (7 exercises)

Includes 3 easy, 3 medium, and 1 challenge. Each exercise has a time estimate, scenario, schema with data, requirements, example output, success criteria, tiered hints, and a detailed solution with alternatives.

**Beginner Tip:** Joins combine multiple tables. Start with Easy exercises to build confidence with INNER and LEFT joins. Check row counts after each join to verify it's working correctly. If you get more rows than expected, you might have a many-to-many relationship. Use hints progressively when stuck!

---

## Easy 🟢 (10–12 min each)

### E1) Orders with Customer Name
Scenario: Display each order’s id, date, and customer full name.

Schema and sample data (run as-is)
```sql
DROP TABLE IF EXISTS ip5_e_customers;
CREATE TABLE ip5_e_customers (customer_id INT PRIMARY KEY, full_name VARCHAR(60));
INSERT INTO ip5_e_customers VALUES (1,'Ava Brown'),(2,'Noah Smith'),(3,'Mia Chen');

DROP TABLE IF EXISTS ip5_e_orders;
CREATE TABLE ip5_e_orders (order_id INT PRIMARY KEY, customer_id INT, order_date DATE);
INSERT INTO ip5_e_orders VALUES (101,1,'2025-03-01'),(102,2,'2025-03-02'),(103,1,'2025-03-04');
```
Requirements
- Return order_id, order_date, full_name.
- Sort by order_id.

Example output
```
order_id | order_date  | full_name
101      | 2025-03-01  | Ava Brown
102      | 2025-03-02  | Noah Smith
103      | 2025-03-04  | Ava Brown
```
Success criteria
- Correct join on customer_id.
- All rows present and correctly ordered.

Hints
- L1: Use INNER JOIN.
- L2: Join orders alias o to customers alias c.
- L3: SELECT o.order_id, o.order_date, c.full_name.

Solution
```sql
SELECT o.order_id, o.order_date, c.full_name
FROM ip5_e_orders o
JOIN ip5_e_customers c ON c.customer_id = o.customer_id
ORDER BY o.order_id;
```

---

### E2) Courses with Instructor (or TBD)
Scenario: Show all courses and instructor name if assigned, otherwise 'TBD'.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip5_e_courses;
CREATE TABLE ip5_e_courses (course_id INT PRIMARY KEY, code VARCHAR(10), instructor_id INT);
INSERT INTO ip5_e_courses VALUES (10,'CS101',1),(20,'DS201',2),(30,'CS199',NULL);

DROP TABLE IF EXISTS ip5_e_instructors;
CREATE TABLE ip5_e_instructors (instructor_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO ip5_e_instructors VALUES (1,'Dr. Kim'),(2,'Prof. Lee');
```
Requirements
- Return code, instructor (or 'TBD').
- Include courses with no instructor.

Example output
```
code  | instructor
CS101 | Dr. Kim
CS199 | TBD
DS201 | Prof. Lee
```
Success criteria
- LEFT JOIN preserves NULL instructor_id rows.

Hints
- L1: LEFT JOIN from courses to instructors.
- L2: COALESCE name to 'TBD'.
- L3: ORDER BY code.

Solution
```sql
SELECT c.code, COALESCE(i.name,'TBD') AS instructor
FROM ip5_e_courses c
LEFT JOIN ip5_e_instructors i ON i.instructor_id = c.instructor_id
ORDER BY c.code;
```

---

### E3) Products Never Sold
Scenario: Find products that never appear in any order items.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip5_e_products;
CREATE TABLE ip5_e_products (product_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO ip5_e_products VALUES (1,'Notebook'),(2,'Lamp'),(3,'Mug');

DROP TABLE IF EXISTS ip5_e_order_items;
CREATE TABLE ip5_e_order_items (order_item_id INT PRIMARY KEY, order_id INT, product_id INT);
INSERT INTO ip5_e_order_items VALUES (1,101,1),(2,101,1),(3,102,2);
```
Requirements
- Return product names never referenced by order items.

Example output
```
name
Mug
```
Success criteria
- Correct LEFT JOIN anti-join pattern.

Hints
- L1: LEFT JOIN products to order_items.
- L2: Filter WHERE order_item_id IS NULL.
- L3: ORDER BY name.

Solution
```sql
SELECT p.name
FROM ip5_e_products p
LEFT JOIN ip5_e_order_items oi ON oi.product_id = p.product_id
WHERE oi.order_item_id IS NULL
ORDER BY p.name;
```

---

## Medium 🟡 (15–18 min each)

### M1) Revenue by Category
Scenario: Show revenue by category using items and products.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip5_m_products;
CREATE TABLE ip5_m_products (product_id INT PRIMARY KEY, name VARCHAR(60), category VARCHAR(30), price DECIMAL(7,2));
INSERT INTO ip5_m_products VALUES
(1,'Notebook','stationery',4.99),(2,'Lamp','home',12.00),(3,'Mug','kitchen',7.99),(4,'Pen','stationery',2.50);

DROP TABLE IF EXISTS ip5_m_order_items;
CREATE TABLE ip5_m_order_items (order_item_id INT PRIMARY KEY, order_id INT, product_id INT, qty INT);
INSERT INTO ip5_m_order_items VALUES
(1,101,1,2),(2,101,3,1),(3,102,2,1),(4,103,1,1),(5,103,4,3);
```
Requirements
- Return category, SUM(qty*price) AS revenue.
- Order by revenue desc.

Example output
```
category   | revenue
stationery | 12.47
home       | 12.00
kitchen    | 7.99
```
Success criteria
- Correct join and multiplication.

Hints
- L1: JOIN order_items to products.
- L2: GROUP BY category.
- L3: SUM(qty*price).

Solution
```sql
SELECT p.category, SUM(oi.qty * p.price) AS revenue
FROM ip5_m_order_items oi
JOIN ip5_m_products p ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC;
```

---

### M2) Employees and Departments (including empty departments)
Scenario: List each department name and number of employees, including departments with zero employees.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip5_m_departments;
CREATE TABLE ip5_m_departments (dept_id INT PRIMARY KEY, name VARCHAR(40));
INSERT INTO ip5_m_departments VALUES (1,'Engineering'),(2,'HR'),(3,'Sales');

DROP TABLE IF EXISTS ip5_m_employees;
CREATE TABLE ip5_m_employees (emp_id INT PRIMARY KEY, full_name VARCHAR(60), dept_id INT);
INSERT INTO ip5_m_employees VALUES (10,'Alice',1),(11,'Bob',1),(12,'Cara',3);
```
Requirements
- Return department name and employee_count.
- Include HR with 0 employees.

Example output
```
name        | employee_count
Engineering | 2
HR          | 0
Sales       | 1
```
Success criteria
- LEFT JOIN from departments to employees.

Hints
- L1: LEFT JOIN.
- L2: COUNT(emp_id).
- L3: GROUP BY department name.

Solution
```sql
SELECT d.name, COUNT(e.emp_id) AS employee_count
FROM ip5_m_departments d
LEFT JOIN ip5_m_employees e ON e.dept_id = d.dept_id
GROUP BY d.name
ORDER BY d.name;
```

---

### M3) Students Missing Prereqs (semi-join)
Scenario: Show students enrolled in DS201 who have NOT completed CS101.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip5_m_students;
CREATE TABLE ip5_m_students (student_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO ip5_m_students VALUES (1,'Ava'),(2,'Noah'),(3,'Mia');

DROP TABLE IF EXISTS ip5_m_completions;
CREATE TABLE ip5_m_completions (student_id INT, course_code VARCHAR(10));
INSERT INTO ip5_m_completions VALUES (1,'CS101'),(3,'CS101');

DROP TABLE IF EXISTS ip5_m_enrollments;
CREATE TABLE ip5_m_enrollments (student_id INT, course_code VARCHAR(10));
INSERT INTO ip5_m_enrollments VALUES (1,'DS201'),(2,'DS201'),(3,'DS201');
```
Requirements
- Return names of students enrolled in DS201 who have not completed CS101.

Example output
```
name
Noah
```
Success criteria
- Use LEFT anti-join or NOT EXISTS correctly.

Hints
- L1: Start from enrollments filtered to DS201.
- L2: Anti-join to completions on CS101.
- L3: WHERE c.student_id IS NULL or NOT EXISTS subquery.

Solution (two ways)
```sql
-- LEFT anti-join
SELECT s.name
FROM ip5_m_enrollments e
JOIN ip5_m_students s ON s.student_id = e.student_id
LEFT JOIN ip5_m_completions c
  ON c.student_id = e.student_id AND c.course_code = 'CS101'
WHERE e.course_code = 'DS201' AND c.student_id IS NULL
ORDER BY s.name;

-- NOT EXISTS
SELECT s.name
FROM ip5_m_enrollments e
JOIN ip5_m_students s ON s.student_id = e.student_id
WHERE e.course_code = 'DS201'
  AND NOT EXISTS (
    SELECT 1
    FROM ip5_m_completions c
    WHERE c.student_id = e.student_id AND c.course_code = 'CS101'
  )
ORDER BY s.name;
```

---

## Challenge 🔴 (25–30 min)

### C1) Marketplace Analytics (many-to-many)
Scenario: A marketplace has sellers and products; orders contain multiple products. Compute key metrics.

Schema and sample data (≈18 rows)
```sql
DROP TABLE IF EXISTS ip5_c_sellers;
CREATE TABLE ip5_c_sellers (seller_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO ip5_c_sellers VALUES (1,'Shop A'),(2,'Shop B'),(3,'Shop C');

DROP TABLE IF EXISTS ip5_c_products;
CREATE TABLE ip5_c_products (product_id INT PRIMARY KEY, seller_id INT, name VARCHAR(60), price DECIMAL(7,2));
INSERT INTO ip5_c_products VALUES
(1,1,'Notebook',4.99),(2,1,'Pen',2.50),(3,2,'Lamp',12.00),(4,2,'LED Strip',22.00),(5,3,'Mug',7.99);

DROP TABLE IF EXISTS ip5_c_orders;
CREATE TABLE ip5_c_orders (order_id INT PRIMARY KEY, order_date DATE);
INSERT INTO ip5_c_orders VALUES (1001,'2025-03-01'),(1002,'2025-03-02'),(1003,'2025-03-03');

DROP TABLE IF EXISTS ip5_c_order_items;
CREATE TABLE ip5_c_order_items (order_item_id INT PRIMARY KEY, order_id INT, product_id INT, qty INT);
INSERT INTO ip5_c_order_items VALUES
(1,1001,1,2),(2,1001,5,1),(3,1002,3,1),(4,1002,4,1),(5,1003,2,3),(6,1003,1,1);
```
Requirements
- A) Revenue by seller (sum of qty*price).
- B) Top product by revenue per seller (1 row per seller).
- C) Sellers with no sales (if any) should appear with revenue 0 in part A.

Example outputs (abridged)
```
seller  | revenue
Shop A  | 15.97
Shop B  | 34.00
Shop C  | 7.99
```
Success criteria
- Handle many-to-many multiplicative effects.
- Use window function or anti-join for top-per-group.

Hints
- L1: Join items→products, then group by seller.
- L2: For top per group, use ROW_NUMBER() OVER (PARTITION BY seller ORDER BY revenue DESC).
- L3: For sellers with no sales, LEFT JOIN from sellers.

Solution
```sql
-- A) Revenue by seller (include zero)
SELECT s.name AS seller,
       COALESCE(SUM(oi.qty * p.price),0) AS revenue
FROM ip5_c_sellers s
LEFT JOIN ip5_c_products p ON p.seller_id = s.seller_id
LEFT JOIN ip5_c_order_items oi ON oi.product_id = p.product_id
GROUP BY s.name
ORDER BY revenue DESC, s.name;

-- B) Top product by revenue per seller
WITH seller_product AS (
  SELECT s.name AS seller, p.name AS product,
         SUM(oi.qty * p.price) AS revenue,
         ROW_NUMBER() OVER (PARTITION BY s.seller_id ORDER BY SUM(oi.qty * p.price) DESC) AS rn
  FROM ip5_c_sellers s
  JOIN ip5_c_products p ON p.seller_id = s.seller_id
  LEFT JOIN ip5_c_order_items oi ON oi.product_id = p.product_id
  GROUP BY s.seller_id, s.name, p.name
)
SELECT seller, product, revenue
FROM seller_product
WHERE rn = 1
ORDER BY seller;
```

Alternatives
- Pre-aggregate order_items by product first to reduce row explosion before joining to sellers.
