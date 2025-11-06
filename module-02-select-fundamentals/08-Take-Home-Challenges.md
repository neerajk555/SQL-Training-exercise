# Take-Home Challenges (Advanced, SELECT Fundamentals)

## 📋 Before You Start

### Learning Objectives
By completing these take-home challenges, you will:
- Apply SELECT fundamentals to complex, realistic scenarios
- Practice multi-part problem-solving with related queries
- Develop skills for handling ambiguous business requirements
- Build confidence with advanced filtering and sorting
- Learn to evaluate multiple valid solution approaches

### How to Approach
**Time Allocation (45-60 min per challenge):**
- 📖 **10 min**: Read all parts, understand business context
- 🎯 **5 min**: Plan approach, identify key columns/filters
- 💻 **30-35 min**: Complete parts in order, test each
- ✅ **5-10 min**: Review solutions, understand trade-offs

**Success Tips:**
- ✅ Complete parts in order (they build on each other)
- ✅ Test edge cases (NULL, empty results, duplicates)
- ✅ Handle open-ended requirements creatively
- ✅ Compare your approach with provided solutions
- ✅ Understand pros/cons of alternative approaches

**Beginner Tip:** Take-home challenges simulate real analyst work. They're meant to be challenging! If stuck, review hints or solutions—learning from them is part of the process.

---

## Take-Home Challenges

Three multi-part exercises. Use MySQL syntax. Each includes realistic data, 3–4 parts, an open-ended component, and detailed solutions with notes/trade-offs.

---

## Challenge 1: University Short Courses Directory (40–50 min)
Scenario: The Continuing Education office needs curated lists of short courses (<= 8 weeks) for a brochure and email campaign.

Schema and sample data
```sql
DROP TABLE IF EXISTS thc_courses;
CREATE TABLE thc_courses (
  course_id INT PRIMARY KEY,
  title VARCHAR(100),
  topic VARCHAR(40),
  duration_weeks INT,
  start_date DATE,
  instructor VARCHAR(60)
);
INSERT INTO thc_courses VALUES
(1,'Intro to Python','technology',6,'2025-04-01','A. Rivera'),
(2,'Excel for Analysts','business',4,'2025-05-05','T. Patel'),
(3,'Creative Writing','arts',10,'2025-06-10','J. Brooks'),
(4,'SQL Fundamentals','technology',5,'2025-04-15','M. Chen'),
(5,'Digital Marketing Basics','business',8,'2025-04-20','S. Khan'),
(6,'Photography 101','arts',6,'2025-04-25','L. Park'),
(7,'Advanced Excel','business',8,'2025-07-01','T. Patel'),
(8,'Web Design Essentials','technology',8,'2025-05-10','K. Kim'),
(9,'Public Speaking','business',3,'2025-04-05','R. Davis'),
(10,'Data Visualization','technology',6,'2025-05-15','A. Rivera');
```
Parts
A) List short courses (<= 8 weeks) starting in April 2025; show `title`, `topic`, `duration_weeks`, sort by `duration_weeks`, `title`.
B) Return courses taught by 'T. Patel' or 'A. Rivera' regardless of month; show `title`, `instructor`, `start_date` ordered by `start_date`.
C) Create a mailing list of `title` as `course_title` and `starts_in_may` column with 'yes'/'no' based on `start_date` in May 2025.
D) Open-ended: Propose and implement an additional filter to spotlight technology courses that start in Q2 2025 and last at most 6 weeks.

Solutions and notes
```sql
-- A
SELECT title, topic, duration_weeks
FROM thc_courses
WHERE duration_weeks <= 8
  AND start_date >= '2025-04-01'
  AND start_date <  '2025-05-01'
ORDER BY duration_weeks, title;

-- B
SELECT title, instructor, start_date
FROM thc_courses
WHERE instructor IN ('T. Patel','A. Rivera')
ORDER BY start_date;

-- C
SELECT 
  title AS course_title,
  CASE WHEN start_date >= '2025-05-01' AND start_date < '2025-06-01' THEN 'yes' ELSE 'no' END AS starts_in_may
FROM thc_courses
ORDER BY course_title;

-- D (one valid approach)
SELECT title, topic, duration_weeks, start_date
FROM thc_courses
WHERE topic = 'technology'
  AND start_date >= '2025-04-01' AND start_date < '2025-07-01'
  AND duration_weeks <= 6
ORDER BY start_date, title;
```
Trade-offs
- Using half-open date ranges is safer for month windows.
- CASE adds readability but can be replaced with boolean expressions if your consumer understands them.

---

## Challenge 2: Clinic Messaging Lists (45–55 min)
Scenario: A clinic wants separate lists for appointment reminders and lab result notifications.

Schema and sample data
```sql
DROP TABLE IF EXISTS thc_patients;
CREATE TABLE thc_patients (
  pid INT PRIMARY KEY,
  full_name VARCHAR(60),
  phone VARCHAR(20),
  email VARCHAR(80)
);
INSERT INTO thc_patients VALUES
(1,'Ana Ruiz','555-1001','ana@clinic.org'),
(2,'Ben King',NULL,'ben@clinic.org'),
(3,'Cora Lee','555-1002',NULL),
(4,'Dan Wu','555-1003','dan@clinic.org'),
(5,'Eli Park',NULL,NULL);

DROP TABLE IF EXISTS thc_appointments;
CREATE TABLE thc_appointments (
  appt_id INT PRIMARY KEY,
  pid INT,
  appt_date DATE,
  appt_time TIME,
  status VARCHAR(20)
);
INSERT INTO thc_appointments VALUES
(101,1,'2025-05-01','09:00:00','scheduled'),
(102,2,'2025-05-01','10:00:00','cancelled'),
(103,3,'2025-05-02','11:00:00','scheduled'),
(104,4,'2025-05-03','09:30:00','scheduled'),
(105,5,'2025-05-03','13:00:00','scheduled');

DROP TABLE IF EXISTS thc_lab_results;
CREATE TABLE thc_lab_results (
  rid INT PRIMARY KEY,
  pid INT,
  test_name VARCHAR(50),
  status VARCHAR(20)
);
INSERT INTO thc_lab_results VALUES
(201,1,'CBC','ready'),
(202,2,'A1C','pending'),
(203,3,'Lipid Panel','ready'),
(204,4,'CBC','ready'),
(205,5,'A1C','pending');
```
Parts
A) Reminder list for 2025-05-01: from `thc_appointments`, show `appt_id`, `pid`, `appt_time`, and a `contact` column preferring phone then email from `thc_patients` (no joins allowed—write two separate queries, phone-first then email-first, to illustrate limitation).
B) Lab-ready list: from `thc_lab_results`, show all `ready` tests with `pid` and `test_name`, sort by `pid`.
C) De-dup cities (if present) or distinct PIDs from appointments on/after 2025-05-02 as a simple export candidate.
D) Open-ended: Propose a better schema or query approach to combine patient contact info with appointments without joins in this module; write two separate exports (phone-only and email-only) and explain trade-offs.

Solutions and notes
```sql
-- A1: Phone-first list (no join; query appointments, then separately look up phone)
SELECT appt_id, pid, appt_time
FROM thc_appointments
WHERE appt_date = '2025-05-01' AND status = 'scheduled'
ORDER BY appt_time;
-- Then separately (manual step) query patient phones:
SELECT pid, phone FROM thc_patients WHERE pid IN (1,2,3,4,5);
-- Combine outside SQL since joins are out-of-scope here.

-- A2: Email-first list
SELECT appt_id, pid, appt_time
FROM thc_appointments
WHERE appt_date = '2025-05-01' AND status = 'scheduled'
ORDER BY appt_time;
-- Then separately:
SELECT pid, email FROM thc_patients WHERE pid IN (1,2,3,4,5);

-- B
SELECT pid, test_name
FROM thc_lab_results
WHERE status = 'ready'
ORDER BY pid, test_name;

-- C: Distinct PIDs from appointments on/after 2025-05-02
SELECT DISTINCT pid
FROM thc_appointments
WHERE appt_date >= '2025-05-02'
ORDER BY pid;
```
Trade-offs
- Without joins, you’ll run multiple queries and merge outside SQL.
- DISTINCT ensures unique IDs for downstream systems.

---

## Challenge 3: Catalog Curation Rules (50–60 min)
Scenario: Merchandising sets rules to build a curated collection.

Schema and sample data
```sql
DROP TABLE IF EXISTS thc_catalog;
CREATE TABLE thc_catalog (
  sku VARCHAR(10) PRIMARY KEY,
  name VARCHAR(80),
  category VARCHAR(30),
  price DECIMAL(7,2),
  active TINYINT(1)
);
INSERT INTO thc_catalog VALUES
('A1','Notebook','stationery',4.99,1),
('A2','Pen Set','stationery',3.50,1),
('B1','Desk Lamp','home',12.00,1),
('B2','Candle','home',9.99,1),
('C1','Yoga Mat','fitness',24.50,1),
('C2','Water Bottle','fitness',15.00,0),
('D1','Laptop Stand','electronics',29.99,1),
('D2','Cable Organizer','accessories',3.49,1),
('D3','Screen Cleaner','accessories',5.49,1),
('E1','Bluetooth Speaker','electronics',35.00,0);
```
Parts
A) Core collection: active items priced between 3 and 12 inclusive; show `sku`, `name`, `price` sorted by `price` then `sku`.
B) Exclusions: list SKUs to exclude—either inactive OR category `electronics` over $30.
C) Spotlight: items whose names contain 'desk' or 'note' (case-insensitive); show distinct `name` lowercased.
D) Open-ended: Write one more rule you’d add (e.g., prefer 'home' or 'stationery' categories) and provide the query.

Solutions and notes
```sql
-- A
SELECT sku, name, price
FROM thc_catalog
WHERE active = 1 AND price BETWEEN 3 AND 12
ORDER BY price, sku;

-- B
SELECT sku
FROM thc_catalog
WHERE active = 0
   OR (category = 'electronics' AND price > 30);

-- C (case-insensitive search)
SELECT DISTINCT LOWER(name) AS name_lc
FROM thc_catalog
WHERE LOWER(name) LIKE '%desk%'
   OR LOWER(name) LIKE '%note%'
ORDER BY name_lc;

-- D (example policy: prefer home or stationery at or under $10)
SELECT sku, name, category, price
FROM thc_catalog
WHERE category IN ('home','stationery')
  AND price <= 10
  AND active = 1
ORDER BY category, price, sku;
```
Trade-offs
- LOWER() in WHERE disables index use on the expression; consider a computed lowercase column for large datasets.
- DISTINCT on lowercased names helps de-dupe variants.
