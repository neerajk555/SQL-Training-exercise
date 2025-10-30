# Guided Step-by-Step — Joins (15–20 min each)

Three guided activities to practice multi-table joins, ON vs WHERE with outer joins, and anti/semi-joins. Each includes setup, checkpoints, common mistakes, a full solution, and discussion questions.

---

## Activity 1: Customer Spend Rollup (E-commerce)
Business context: Marketing wants each customer’s total spend.

Database setup
```sql
DROP TABLE IF EXISTS gs5_customers;
CREATE TABLE gs5_customers (
  customer_id INT PRIMARY KEY,
  full_name VARCHAR(60)
);
INSERT INTO gs5_customers VALUES
(1,'Ava Brown'),(2,'Noah Smith'),(3,'Mia Chen'),(4,'Leo Park');

DROP TABLE IF EXISTS gs5_orders;
CREATE TABLE gs5_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE
);
INSERT INTO gs5_orders VALUES
(101,1,'2025-03-01'),(102,2,'2025-03-02'),(103,1,'2025-03-04');

DROP TABLE IF EXISTS gs5_products;
CREATE TABLE gs5_products (
  product_id INT PRIMARY KEY,
  name VARCHAR(60),
  price DECIMAL(7,2)
);
INSERT INTO gs5_products VALUES
(1,'Notebook',4.99),(2,'Lamp',12.00),(3,'Mug',7.99);

DROP TABLE IF EXISTS gs5_order_items;
CREATE TABLE gs5_order_items (
  order_item_id INT PRIMARY KEY,
  order_id INT,
  product_id INT,
  qty INT
);
INSERT INTO gs5_order_items VALUES
(1,101,1,2),(2,101,3,1),(3,102,2,1),(4,103,1,1);
```
Final goal: List one row per customer with total_spend (sum of qty*price), 0 for customers with no orders.

Steps with checkpoints
1) Join customers→orders (LEFT JOIN). Check that Mia and Leo appear (even if no orders).
2) Join order_items and products to compute line value (qty*price).
3) Aggregate per customer. Use COALESCE to turn NULL into 0.
4) Order by total_spend desc.

Common mistakes
- Using INNER JOIN drops customers with no orders.
- Putting filters on orders in WHERE instead of ON, turning LEFT into INNER.
- Forgetting to multiply qty by price before SUM.

Solution
```sql
SELECT c.customer_id, c.full_name,
       COALESCE(SUM(oi.qty * p.price), 0) AS total_spend
FROM gs5_customers c
LEFT JOIN gs5_orders o ON o.customer_id = c.customer_id
LEFT JOIN gs5_order_items oi ON oi.order_id = o.order_id
LEFT JOIN gs5_products p ON p.product_id = oi.product_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_spend DESC, c.customer_id;
```

Discussion
- When should predicates go in ON vs WHERE with LEFT JOIN?
- How would you include only 2025 orders without dropping customers with no 2025 orders?

---

## Activity 2: Course Roster Summary (Education)
Business context: Department chair wants enrollments per course with instructor.

Database setup
```sql
DROP TABLE IF EXISTS gs5_instructors;
CREATE TABLE gs5_instructors (instructor_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO gs5_instructors VALUES (1,'Dr. Kim'),(2,'Prof. Lee');

DROP TABLE IF EXISTS gs5_courses;
CREATE TABLE gs5_courses (course_id INT PRIMARY KEY, code VARCHAR(10), title VARCHAR(80), instructor_id INT);
INSERT INTO gs5_courses VALUES (10,'CS101','Intro to CS',1),(20,'DS201','Data Systems',2),(30,'CS199','Special Topics',NULL);

DROP TABLE IF EXISTS gs5_students;
CREATE TABLE gs5_students (student_id INT PRIMARY KEY, full_name VARCHAR(60));
INSERT INTO gs5_students VALUES (101,'Ava'),(102,'Noah'),(103,'Mia');

DROP TABLE IF EXISTS gs5_enrollments;
CREATE TABLE gs5_enrollments (student_id INT, course_id INT);
INSERT INTO gs5_enrollments VALUES (101,10),(102,10),(103,20);
```
Final goal: One row per course with course code, title, instructor name (or 'TBD'), and enrolled_count (0 for none).

Steps with checkpoints
1) Join courses→instructors (LEFT) to get instructor name.
2) Join enrollments (LEFT) and aggregate count of students per course.
3) Use COALESCE for instructor name when NULL.

Common mistakes
- Using INNER JOIN to instructors hides courses without an instructor.
- Counting enrollments without DISTINCT when duplicates exist.

Solution
```sql
SELECT c.code, c.title,
       COALESCE(i.name,'TBD') AS instructor,
       COUNT(e.student_id) AS enrolled_count
FROM gs5_courses c
LEFT JOIN gs5_instructors i ON i.instructor_id = c.instructor_id
LEFT JOIN gs5_enrollments e ON e.course_id = c.course_id
GROUP BY c.code, c.title, COALESCE(i.name,'TBD')
ORDER BY c.code;
```

Discussion
- If duplicate enrollments were possible, how would you guard against them?
- How would you filter to only courses with at least 2 students?

---

## Activity 3: Patient Visit Insights (Healthcare)
Business context: Operations wants patients without visits and those with multiple diagnoses.

Database setup
```sql
DROP TABLE IF EXISTS gs5_patients;
CREATE TABLE gs5_patients (patient_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO gs5_patients VALUES (1,'Ana'),(2,'Ben'),(3,'Cara');

DROP TABLE IF EXISTS gs5_visits;
CREATE TABLE gs5_visits (visit_id INT PRIMARY KEY, patient_id INT, visit_date DATE);
INSERT INTO gs5_visits VALUES (1001,1,'2025-01-01'),(1002,1,'2025-02-01'),(1003,3,'2025-02-10');

DROP TABLE IF EXISTS gs5_diagnoses;
CREATE TABLE gs5_diagnoses (diag_id INT PRIMARY KEY, visit_id INT, code VARCHAR(10));
INSERT INTO gs5_diagnoses VALUES (1,1001,'A10'),(2,1001,'B20'),(3,1002,'C30'),(4,1003,'A10');
```
Final goals:
A) List patients with no visits.
B) List patients with 2+ diagnoses across all their visits.

Steps with checkpoints
- A1) LEFT JOIN patients→visits and filter WHERE visits.visit_id IS NULL.
- B1) Join visits→diagnoses, then to patients. Group by patient and HAVING COUNT(diag_id) >= 2.

Common mistakes
- Filtering visits in WHERE before anti-join check.
- Counting distinct visits instead of diagnoses when the goal is diagnoses.

Solutions
```sql
-- A) Patients without visits
SELECT p.name
FROM gs5_patients p
LEFT JOIN gs5_visits v ON v.patient_id = p.patient_id
WHERE v.visit_id IS NULL
ORDER BY p.name;

-- B) Patients with 2+ diagnoses (across visits)
SELECT p.name, COUNT(d.diag_id) AS total_diagnoses
FROM gs5_patients p
JOIN gs5_visits v ON v.patient_id = p.patient_id
JOIN gs5_diagnoses d ON d.visit_id = v.visit_id
GROUP BY p.name
HAVING COUNT(d.diag_id) >= 2
ORDER BY total_diagnoses DESC, p.name;
```

Discussion
- How would you find patients with 2+ visits instead?
- When would EXISTS be clearer than joins here?
