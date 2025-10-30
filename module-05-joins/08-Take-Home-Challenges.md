# Take-Home Challenges — Joins (Advanced)

Three multi-part exercises with realistic datasets. Include open-ended components and solutions with trade-offs.

**Beginner Tip:** Multi-table challenges can feel overwhelming at first! Draw the relationships between tables if it helps. Join two tables first, verify the result, then add the third. Check row counts at each step. Take breaks when stuck—fresh eyes often spot the issue!

---

## Challenge 1: Customer Journey Insights (E-commerce) — 45–55 min
Scenario: Model a typical e-commerce journey and derive insights via joins.

Schema and sample data
```sql
DROP TABLE IF EXISTS thc5_users;
CREATE TABLE thc5_users (user_id INT PRIMARY KEY, name VARCHAR(60), city VARCHAR(40));
INSERT INTO thc5_users VALUES
(1,'Ava','Austin'),(2,'Noah','Dallas'),(3,'Mia','Austin'),(4,'Leo','Seattle'),(5,'Zoe','Seattle');

DROP TABLE IF EXISTS thc5_sessions;
CREATE TABLE thc5_sessions (session_id INT PRIMARY KEY, user_id INT, started_at DATETIME);
INSERT INTO thc5_sessions VALUES
(100,1,'2025-03-01 09:00:00'),(101,1,'2025-03-02 10:00:00'),(102,2,'2025-03-01 09:30:00'),(103,4,'2025-03-03 11:00:00');

DROP TABLE IF EXISTS thc5_orders;
CREATE TABLE thc5_orders (order_id INT PRIMARY KEY, user_id INT, order_date DATE);
INSERT INTO thc5_orders VALUES
(2001,1,'2025-03-01'),(2002,2,'2025-03-02'),(2003,1,'2025-03-04'),(2004,5,'2025-03-05');

DROP TABLE IF EXISTS thc5_order_items;
CREATE TABLE thc5_order_items (order_item_id INT PRIMARY KEY, order_id INT, product VARCHAR(60), price DECIMAL(7,2), qty INT);
INSERT INTO thc5_order_items VALUES
(1,2001,'Notebook',4.99,2),(2,2001,'Mug',7.99,1),(3,2002,'Lamp',12.00,1),(4,2003,'Pen',2.50,3),(5,2004,'Mug',7.99,2);
```
Parts
A) Users with sessions but no orders (anti-join).
B) Revenue per user (users with no orders should be 0).
C) Top city by revenue, include ties.
D) Open-ended: Propose a join to map each order to the most recent prior session of the same user.

Solutions and trade-offs
```sql
-- A) Sessions but no orders
SELECT u.name
FROM thc5_users u
LEFT JOIN thc5_sessions s ON s.user_id = u.user_id
LEFT JOIN thc5_orders o ON o.user_id = u.user_id
WHERE s.session_id IS NOT NULL AND o.order_id IS NULL
GROUP BY u.name
ORDER BY u.name;

-- B) Revenue per user (include 0)
SELECT u.name, COALESCE(SUM(oi.qty * oi.price),0) AS revenue
FROM thc5_users u
LEFT JOIN thc5_orders o ON o.user_id = u.user_id
LEFT JOIN thc5_order_items oi ON oi.order_id = o.order_id
GROUP BY u.name
ORDER BY revenue DESC, u.name;

-- C) Top city by revenue (ties)
WITH city_rev AS (
  SELECT u.city, SUM(oi.qty * oi.price) AS revenue
  FROM thc5_users u
  JOIN thc5_orders o ON o.user_id = u.user_id
  JOIN thc5_order_items oi ON oi.order_id = o.order_id
  GROUP BY u.city
)
SELECT city, revenue
FROM city_rev
WHERE revenue = (SELECT MAX(revenue) FROM city_rev)
ORDER BY city;

-- D) Map order to most recent prior session (outline)
-- Option 1 (MySQL 8.0+): use LATERAL (CROSS APPLY) pattern via correlated subquery
-- Select s.session_id where s.user_id=o.user_id and s.started_at<=o.order_date
-- Order by started_at desc limit 1.
```
Trade-offs
- For D, a correlated subquery per order may be fine at small scale; for large data, pre-aggregate sessions per user or use window functions.

---

## Challenge 2: Staffing Coverage (Workforce) — 45–55 min
Scenario: Determine shift coverage vs. required staffing; identify gaps and overstaffing.

Schema and sample data
```sql
DROP TABLE IF EXISTS thc5_employees;
CREATE TABLE thc5_employees (emp_id INT PRIMARY KEY, name VARCHAR(60), dept VARCHAR(40));
INSERT INTO thc5_employees VALUES (1,'Alice','Front'),(2,'Bob','Front'),(3,'Cara','Kitchen'),(4,'Drew','Kitchen'),(5,'Evan','Front');

DROP TABLE IF EXISTS thc5_shifts;
CREATE TABLE thc5_shifts (shift_id INT PRIMARY KEY, dept VARCHAR(40), start_time TIME, end_time TIME);
INSERT INTO thc5_shifts VALUES
(10,'Front','09:00:00','13:00:00'),(11,'Front','13:00:00','17:00:00'),(12,'Kitchen','09:00:00','17:00:00');

DROP TABLE IF EXISTS thc5_assignments;
CREATE TABLE thc5_assignments (shift_id INT, emp_id INT);
INSERT INTO thc5_assignments VALUES (10,1),(10,2),(11,5),(12,3);

DROP TABLE IF EXISTS thc5_requirements;
CREATE TABLE thc5_requirements (dept VARCHAR(40), needed INT);
INSERT INTO thc5_requirements VALUES ('Front',3),('Kitchen',2);
```
Parts
A) For each shift, list assigned_count and whether it meets department requirement.
B) Departments with insufficient staffing overall (sum across shifts) vs needed.
C) Open-ended: Suggest a query to list employees not assigned to any shift (per day) for potential on-call.

Solutions and trade-offs
```sql
-- A) Shift coverage vs requirement
WITH shift_counts AS (
  SELECT s.shift_id, s.dept, COUNT(a.emp_id) AS assigned_count
  FROM thc5_shifts s
  LEFT JOIN thc5_assignments a ON a.shift_id = s.shift_id
  GROUP BY s.shift_id, s.dept
)
SELECT sc.shift_id, sc.dept, sc.assigned_count,
       r.needed,
       CASE WHEN sc.assigned_count >= r.needed THEN 'met' ELSE 'gap' END AS status
FROM shift_counts sc
JOIN thc5_requirements r ON r.dept = sc.dept
ORDER BY sc.shift_id;

-- B) Department total coverage vs needed
SELECT s.dept, COUNT(a.emp_id) AS total_assigned, r.needed
FROM thc5_shifts s
LEFT JOIN thc5_assignments a ON a.shift_id = s.shift_id
JOIN thc5_requirements r ON r.dept = s.dept
GROUP BY s.dept, r.needed
ORDER BY s.dept;

-- C) Employees not assigned to any shift
SELECT e.name
FROM thc5_employees e
LEFT JOIN thc5_assignments a ON a.emp_id = e.emp_id
WHERE a.emp_id IS NULL
ORDER BY e.name;
```
Trade-offs
- For A, pre-aggregating per shift avoids duplicate rows.
- For B, ensure grouping aligns with requirement granularity (dept-level here).

---

## Challenge 3: Library Loans and Returns (Education) — 50–60 min
Scenario: Analyze library usage; find overdue loans, top borrowers, and books never borrowed.

Schema and sample data
```sql
DROP TABLE IF EXISTS thc5_books;
CREATE TABLE thc5_books (book_id INT PRIMARY KEY, title VARCHAR(80), author VARCHAR(60));
INSERT INTO thc5_books VALUES (1,'SQL 101','Kim'),(2,'Data Patterns','Lee'),(3,'Joins Deep Dive','Park'),(4,'Window Magic','Chen');

DROP TABLE IF EXISTS thc5_members;
CREATE TABLE thc5_members (member_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO thc5_members VALUES (1,'Ava'),(2,'Noah'),(3,'Mia');

DROP TABLE IF EXISTS thc5_loans;
CREATE TABLE thc5_loans (loan_id INT PRIMARY KEY, book_id INT, member_id INT, loan_date DATE, due_date DATE, return_date DATE);
INSERT INTO thc5_loans VALUES
(100,1,1,'2025-02-01','2025-02-15','2025-02-10'),
(101,2,2,'2025-02-05','2025-02-19',NULL),
(102,3,1,'2025-02-20','2025-03-06','2025-03-10'),
(103,1,3,'2025-03-01','2025-03-15',NULL);
```
Parts
A) Overdue loans as of 2025-03-12 (return_date IS NULL and due_date < '2025-03-12'). Show member and title.
B) Top borrower(s) by number of loans (include ties).
C) Books never borrowed (anti-join).
D) Open-ended: Add a column for days_overdue and discuss handling NULL safely.

Solutions and trade-offs
```sql
-- A) Overdue loans
SELECT m.name AS member, b.title
FROM thc5_loans l
JOIN thc5_members m ON m.member_id = l.member_id
JOIN thc5_books b ON b.book_id = l.book_id
WHERE l.return_date IS NULL AND l.due_date < '2025-03-12'
ORDER BY member, title;

-- B) Top borrower(s)
WITH borrower AS (
  SELECT m.name, COUNT(*) AS loans,
         DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
  FROM thc5_loans l
  JOIN thc5_members m ON m.member_id = l.member_id
  GROUP BY m.name
)
SELECT name, loans
FROM borrower
WHERE rnk = 1
ORDER BY name;

-- C) Books never borrowed
SELECT b.title
FROM thc5_books b
LEFT JOIN thc5_loans l ON l.book_id = b.book_id
WHERE l.loan_id IS NULL
ORDER BY b.title;

-- D) Days overdue (outline)
-- CASE WHEN l.return_date IS NULL AND l.due_date < CURDATE() THEN DATEDIFF(CURDATE(), l.due_date) ELSE 0 END AS days_overdue
```
Trade-offs
- Using window functions simplifies ties in B; fallback: subquery for max count.
- For A/D, ensure date comparisons are sargable; avoid functions on due_date in WHERE.
