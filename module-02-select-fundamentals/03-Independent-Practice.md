# Independent Practice: SELECT Fundamentals

Seven exercises: 3 Easy 🟢, 3 Medium 🟡, 1 Challenge 🔴. Each has schema+data, requirements, example output, hints, and solutions. Time estimates are guides—take what you need.

## 📋 Before You Start

### Learning Objectives
Through independent practice, you will:
- Apply SELECT fundamentals without step-by-step guidance
- Progress from basic filtering to complex multi-condition queries
- Master data cleaning with string functions
- Handle edge cases (NULLs, duplicates, case sensitivity)
- Build confidence solving problems independently

### Difficulty Progression
- 🟢 **Easy (1-3)**: Single concepts, clear requirements, 8-12 minutes
- 🟡 **Medium (4-6)**: Multiple concepts combined, 15-20 minutes
- 🔴 **Challenge (7)**: Complex logic, requires planning, 25-30 minutes

### Strategic Problem-Solving Process
1. **READ** the scenario and requirements carefully
2. **SETUP** the data (copy/run CREATE and INSERT statements)
3. **PLAN** your query:
   - Which columns? → SELECT clause
   - Which rows? → WHERE clause
   - What order? → ORDER BY clause
   - Any transformations? → Functions
4. **TRY** solving yourself (resist hints initially!)
5. **TEST** and compare with expected output
6. **USE HINTS** strategically if needed (Level 1 → Level 2 → Level 3)
7. **REVIEW** the solution even if you succeed

**Learning from Hints:**
- Level 1: Directional guidance
- Level 2: More specific approach
- Level 3: Near-complete solution (last resort)
- After using hints, try writing the query from memory

---

## Easy 🟢 (1): Simple Filtering in E‑commerce (10–12 min)
Scenario: An e-commerce team wants cheap accessories.

Schema and sample data (copy-paste)
```sql
DROP TABLE IF EXISTS ip_products;
CREATE TABLE ip_products (
  id INT PRIMARY KEY,
  name VARCHAR(60),
  category VARCHAR(30),
  price DECIMAL(7,2)
);
INSERT INTO ip_products VALUES
(1, 'USB Cable', 'accessories', 6.99),
(2, 'Phone Case', 'accessories', 12.50),
(3, 'Power Bank', 'electronics', 24.00),
(4, 'Mouse Pad', 'accessories', 4.00),
(5, 'HDMI Adapter', 'accessories', 9.99),
(6, 'Bluetooth Speaker', 'electronics', 35.00),
(7, 'Laptop Sleeve', 'accessories', 19.00),
(8, 'Screen Protector', 'accessories', 7.50),
(9, 'Earbuds', 'electronics', 14.99),
(10,'Cable Organizer', 'accessories', 3.49);
```
Requirements
- Return `name`, `price` of `accessories` priced under 10.
- Sort by `price` ascending then `name`.

Example output
```
name            | price
----------------+------
Cable Organizer | 3.49
Mouse Pad       | 4.00
USB Cable       | 6.99
Screen Protector| 7.50
HDMI Adapter    | 9.99
```
Success criteria
- Exactly 5 rows, correct order.

Hints
1) Use WHERE with two conditions.
2) ORDER BY two columns.
3) Aliases not required.

Solution
```sql
SELECT name, price
FROM ip_products
WHERE category = 'accessories'
  AND price < 10
ORDER BY price, name;
```

---

## Easy 🟢 (2): DISTINCT Cities (8–10 min)
Scenario: Analytics wants unique ship cities, ignoring case duplicates.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip_orders;
CREATE TABLE ip_orders (
  order_id INT PRIMARY KEY,
  ship_city VARCHAR(50)
);
INSERT INTO ip_orders VALUES
(1,'New York'), (2,'new york'), (3,'Dallas'), (4,'DALLaS'),
(5,'Seattle'), (6,NULL), (7,'Seattle'), (8,'Miami'), (9,NULL), (10,'Austin');
```
Requirements
- Return distinct normalized cities using `LOWER(ship_city)` as `city`.
- Exclude NULLs.
- Sort alphabetically.

Example output
```
city
------
austin
dallas
miami
new york
seattle
```
Success criteria
- 5 rows, all lowercase, no NULLs.

Hints
1) Use COALESCE or filter NULL with `IS NOT NULL`.
2) DISTINCT applies after expression (LOWER).

Solution
```sql
SELECT DISTINCT LOWER(ship_city) AS city
FROM ip_orders
WHERE ship_city IS NOT NULL
ORDER BY city;
```

---

## Easy 🟢 (3): LIKE Patterns (10–12 min)
Scenario: Find courses that start with "Intro" and end with a digit.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip_courses;
CREATE TABLE ip_courses (
  code VARCHAR(10) PRIMARY KEY,
  title VARCHAR(80)
);
INSERT INTO ip_courses VALUES
('C101','Intro to C Programming 1'),
('C102','Intro to C Programming 2'),
('DS10','Intro to Data Science A'),
('ML01','Machine Learning 1'),
('WD01','Intro to Web Dev 3');
```
Requirements
- Return `code`, `title` where title starts with `Intro` and ends with a number.
- Sort by `code`.

Example output
```
code | title
-----+----------------------------
C101 | Intro to C Programming 1
C102 | Intro to C Programming 2
WD01 | Intro to Web Dev 3
```
Success criteria
- 3 rows; correct pattern.

Hints
1) Use `LIKE 'Intro%'` and a second `LIKE '%[0-9]'` is not supported—use `%` and SUBSTRING/REGEXP or a range check.
2) MySQL supports `REGEXP_LIKE(title, '[0-9]$')` (8.0+) or `title REGEXP '[0-9]$'`.

Solution (MySQL 8.0+)
```sql
SELECT code, title
FROM ip_courses
WHERE title LIKE 'Intro%'
  AND title REGEXP '[0-9]$'
ORDER BY code;
```
Alternative (no REGEXP): assumes last char is numeric if `RIGHT(title,1)` between '0' and '9'
```sql
SELECT code, title
FROM ip_courses
WHERE title LIKE 'Intro%'
  AND RIGHT(title,1) BETWEEN '0' AND '9'
ORDER BY code;
```

---

## Medium 🟡 (1): Case-Insensitive Search With Safe Output (12–15 min)
Scenario: Customer support searches people by partial last name.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip_people;
CREATE TABLE ip_people (
  person_id INT PRIMARY KEY,
  first_name VARCHAR(40),
  last_name VARCHAR(40),
  email VARCHAR(80)
);
INSERT INTO ip_people VALUES
(1,'Amir','Khan','amir.k@example.com'),
(2,'Sofia','Lopez',NULL),
(3,'Grace','LOPEZ','grace.l@example.com'),
(4,'Noah','Kim','noah.k@example.com'),
(5,'Olivia','Li',NULL),
(6,'Leo','Lopez','leo.l@example.com');
```
Requirements
- Parameter: search term 'lopez'. Return rows where last_name contains it, ignoring case.
- Output columns: `full_name` ("Last, First") and `email_or_na` (email or 'N/A').
- Sort by `last_name`, then `first_name`.

Example output
```
full_name       | email_or_na
----------------+---------------------
Lopez, Grace    | grace.l@example.com
Lopez, Leo      | leo.l@example.com
Lopez, Sofia    | N/A
```
Success criteria
- 3 matching rows; correct order and replacements.

Hints
1) Normalize both sides with LOWER.
2) COALESCE handles NULLs.

Solution
```sql
SELECT 
  CONCAT(last_name, ', ', first_name) AS full_name,
  COALESCE(email, 'N/A') AS email_or_na
FROM ip_people
WHERE LOWER(last_name) LIKE '%lopez%'
ORDER BY last_name, first_name;
```

---

## Medium 🟡 (2): BETWEEN and Edge Cases (12–15 min)
Scenario: Filter orders in a date window; include boundary dates.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip_order_dates;
CREATE TABLE ip_order_dates (
  order_id INT PRIMARY KEY,
  order_date DATE,
  total DECIMAL(8,2)
);
INSERT INTO ip_order_dates VALUES
(101,'2025-01-01',50.00),
(102,'2025-01-15',75.00),
(103,'2025-01-31',20.00),
(104,'2025-02-01',99.00),
(105,'2025-02-14',35.00),
(106,'2025-02-28',42.00),
(107,'2025-03-01',10.00);
```
Requirements
- Return orders between '2025-01-15' and '2025-02-28' inclusive.
- Show `order_id`, `order_date`, `total` sorted by date.

Example output
```
order_id | order_date  | total
---------+-------------+------
102      | 2025-01-15  | 75.00
103      | 2025-01-31  | 20.00
104      | 2025-02-01  | 99.00
105      | 2025-02-14  | 35.00
106      | 2025-02-28  | 42.00
```
Success criteria
- 5 rows including boundary dates.

Hints
1) Use `BETWEEN '2025-01-15' AND '2025-02-28'`.
2) Alternatively, use `>=` and `<=`.

Solution
```sql
SELECT order_id, order_date, total
FROM ip_order_dates
WHERE order_date BETWEEN '2025-01-15' AND '2025-02-28'
ORDER BY order_date;
```

---

## Medium 🟡 (3): Multi-Condition Logic With OR/AND (15–18 min)
Scenario: HR wants employees either in 'Engineering' making >= 90000 or in 'Support' making < 50000.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip_employees;
CREATE TABLE ip_employees (
  emp_id INT PRIMARY KEY,
  full_name VARCHAR(60),
  dept VARCHAR(30),
  salary INT
);
INSERT INTO ip_employees VALUES
(1,'Aria Ray','Engineering',95000),
(2,'Ben Yu','Support',48000),
(3,'Cara Om','Engineering',88000),
(4,'Dae Jin','Support',52000),
(5,'Eve Lin','Marketing',70000),
(6,'Finn Jo','Engineering',120000),
(7,'Gia Hu','Support',49000);
```
Requirements
- Return `full_name`, `dept`, `salary` for employees matching the criteria.
- Sort by `dept`, then salary desc.

Example output
```
full_name | dept        | salary
----------+-------------+-------
Finn Jo   | Engineering | 120000
Aria Ray  | Engineering | 95000
Ben Yu    | Support     | 48000
Gia Hu    | Support     | 49000
```
Success criteria
- 4 rows; correct logic grouping.

Hints
1) Use parentheses to group OR vs AND.
2) Double-check Support predicate uses < 50000.

Solution
```sql
SELECT full_name, dept, salary
FROM ip_employees
WHERE (dept = 'Engineering' AND salary >= 90000)
   OR (dept = 'Support' AND salary < 50000)
ORDER BY dept, salary DESC;
```

---

## Challenge 🔴: Comprehensive Filter, Null Handling, and Aliases (20–25 min)
Scenario: Healthcare lab tests report—some values missing, multiple predicates.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip_lab_tests;
CREATE TABLE ip_lab_tests (
  test_id INT PRIMARY KEY,
  patient VARCHAR(60),
  test_name VARCHAR(50),
  status VARCHAR(20),
  result_value DECIMAL(6,2),
  unit VARCHAR(10)
);
INSERT INTO ip_lab_tests VALUES
(1,'Ami Tae','CBC','completed', 13.50,'g/dL'),
(2,'Bo Li','CBC','completed', NULL,'g/dL'),
(3,'Cal Rae','Lipid Panel','pending', NULL,NULL),
(4,'Dia Wu','Lipid Panel','completed', 199.00,'mg/dL'),
(5,'Eon Xu','A1C','completed', 6.20,'percent'),
(6,'Fae Jo','A1C','cancelled', NULL,NULL),
(7,'Gio Ng','CBC','completed', 11.90,'g/dL'),
(8,'Hal Go','A1C','completed', 5.10,'percent'),
(9,'Ian Mo','Lipid Panel','completed', 220.00,'mg/dL'),
(10,'Jae Qi','CBC','completed', 14.10,'g/dL'),
(11,'Kai Ry','CBC','pending', NULL,'g/dL'),
(12,'Lou Sa','A1C','completed', NULL,'percent');
```
Requirements
- Return only `completed` tests of type `CBC` or `A1C`.
- Exclude rows with NULL `result_value`.
- Output columns: `patient`, `test_name`, `result_value` as `value`, `unit` (fallback to 'n/a').
- Sort by `test_name`, then `value` descending.

Example output
```
patient | test_name | value | unit
--------+-----------+-------+-------
Jae Qi  | CBC       | 14.10 | g/dL
Ami Tae | CBC       | 13.50 | g/dL
Gio Ng  | CBC       | 11.90 | g/dL
Eon Xu  | A1C       | 6.20  | percent
Hal Go  | A1C       | 5.10  | percent
```
Success criteria
- 5 rows; correct filtering and ordering; unit never NULL.

Hints
1) Combine status and test_name predicates with AND plus IN for names.
2) Use `IS NOT NULL` for result_value.
3) Use COALESCE for unit.

Solution
```sql
SELECT 
  patient,
  test_name,
  result_value AS value,
  COALESCE(unit, 'n/a') AS unit
FROM ip_lab_tests
WHERE status = 'completed'
  AND test_name IN ('CBC','A1C')
  AND result_value IS NOT NULL
ORDER BY test_name, value DESC;
```

Performance note: On large datasets, add composite indexes like `(status, test_name, result_value)` to support this query. Avoid wrapping filtered columns in functions.
