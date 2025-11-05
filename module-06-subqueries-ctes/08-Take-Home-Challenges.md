# Take-Home Challenges — Subqueries & CTEs (Advanced)

Three multi-part exercises mixing subqueries, derived tables, and recursive CTEs. Includes open-ended prompts, detailed solutions, and trade-offs.

**Beginner Tip:** These are the most advanced exercises in this module! Build complexity gradually—start with the simplest part of each challenge. CTEs let you name intermediate steps, making debugging easier. Test each CTE separately before combining them. Persistence pays off!

---

## Challenge 1: E-commerce Cohort Health — 45–55 min
Scenario: Assess cohort conversion and repeat purchase behavior using subqueries and CTEs.

Schema and sample data
```sql
DROP TABLE IF EXISTS thc6_u;
CREATE TABLE thc6_u (user_id INT PRIMARY KEY, name VARCHAR(60), signup_date DATE);
INSERT INTO thc6_u VALUES
(1,'Ava','2025-01-05'),(2,'Noah','2025-01-20'),(3,'Mia','2025-02-10'),(4,'Leo','2025-02-15'),(5,'Zoe','2025-03-01');

DROP TABLE IF EXISTS thc6_o;
CREATE TABLE thc6_o (order_id INT PRIMARY KEY, user_id INT, order_date DATE);
INSERT INTO thc6_o VALUES
(1001,1,'2025-01-10'),(1002,1,'2025-03-02'),(1003,2,'2025-02-01'),(1004,3,'2025-03-01'),(1005,4,'2025-03-05');
```
Parts
A) First-order conversion by signup month: For each month, count signups and users with at least one order (EXISTS).
B) Repeat buyers: Users with 2+ orders (subquery in WHERE or HAVING on derived table).
C) Open-ended: Build a cohort retention grid (month since signup → whether ordered) outline using a calendar CTE.

**Approach Strategy:**
Before diving into solutions, here's how to tackle each part:

**Part A (First-order conversion):**
1. Extract signup month from signup_date using DATE_FORMAT
2. Count total signups per month (easy!)
3. Count users with at least one order (EXISTS pattern)
4. Join these counts together

**Part B (Repeat buyers):**
1. Count orders per user (subquery with COUNT)
2. Filter to users with 2+ orders (WHERE count >= 2)
3. Simple but effective!

**Part C (Cohort retention - Conceptual):**
This is complex! The idea:
- Generate a calendar (recursive CTE)
- For each signup cohort, track if they ordered in month 0, 1, 2, etc.
- Create a "retention matrix" showing % who ordered in each subsequent month
- This is advanced analytics - sketch the logic, don't need perfect code

---

Solutions and trade-offs
```sql
-- A) Conversion by signup month
WITH months AS (
  SELECT DATE_FORMAT(signup_date,'%Y-%m') AS ym, user_id FROM thc6_u
), converted AS (
  SELECT u.user_id FROM thc6_u u WHERE EXISTS (
    SELECT 1 FROM thc6_o o WHERE o.user_id = u.user_id
  )
)
SELECT m.ym,
       COUNT(*) AS signups,
       SUM(CASE WHEN m.user_id IN (SELECT user_id FROM converted) THEN 1 ELSE 0 END) AS converted_users
FROM months m
GROUP BY m.ym
ORDER BY m.ym;

-- B) Repeat buyers (2+ orders)
SELECT u.name
FROM thc6_u u
WHERE (
  SELECT COUNT(*) FROM thc6_o o WHERE o.user_id = u.user_id
) >= 2
ORDER BY u.name;

-- C) Cohort retention outline
-- 1) Build a calendar CTE per user for N months after signup
-- 2) Left join orders aggregated by order month
-- 3) Mark retained if exists order in that month offset
```
Trade-offs
- Using EXISTS for conversion avoids duplicates.
- For large ranges, pre-materialize a calendar table instead of recursive generation each query.

---

## Challenge 2: Supply Hierarchy and Cost Rollup — 50–60 min
Scenario: Compute a bill-of-materials (BOM) cost using a recursive CTE and subqueries.

**Real-World Context:**
A Bill of Materials (BOM) shows how products are assembled from components:
- Widget (final product) contains Body + 2 Axles
- Each Axle contains 2 Wheels + 4 Bolts
- To calculate total cost, we need to "explode" the BOM and multiply quantities down the tree

**Example Tree:**
```
Widget (part 1)
├─ Body (part 2) × 1
└─ Axle (part 5) × 2
   ├─ Wheel (part 3) × 2  → Total needed: 2 axles × 2 wheels = 4 wheels
   └─ Bolt (part 4) × 4   → Total needed: 2 axles × 4 bolts = 8 bolts
```

Schema and sample data
```sql
DROP TABLE IF EXISTS thc6_parts;
CREATE TABLE thc6_parts (part_id INT PRIMARY KEY, name VARCHAR(60), unit_cost DECIMAL(7,2));
INSERT INTO thc6_parts VALUES
(1,'Widget',NULL),(2,'Body',12.00),(3,'Wheel',5.00),(4,'Bolt',0.25),(5,'Axle',3.50);

DROP TABLE IF EXISTS thc6_bom;
CREATE TABLE thc6_bom (parent_part_id INT, child_part_id INT, qty INT);
INSERT INTO thc6_bom VALUES
(1,2,1),(1,5,2),(5,3,2),(5,4,4);
```
Parts
A) Flatten the BOM for part 1 to list each component with path and total quantity (recursive CTE).
B) Compute total material cost for part 1 using unit_cost at leaves and derived quantities.
C) Open-ended: Discuss handling cycles and max depth; propose guards in the recursive CTE.

Solutions and trade-offs
```sql
-- A) Flatten with multiplicative qty
WITH RECURSIVE bom AS (
  SELECT parent_part_id, child_part_id, qty, CAST(CONCAT(parent_part_id,'>',child_part_id) AS CHAR(200)) AS path,
         child_part_id AS leaf, qty AS total_qty
  FROM thc6_bom WHERE parent_part_id = 1
  UNION ALL
  SELECT b.parent_part_id, c.child_part_id,
         b.qty * c.qty AS qty,
         CONCAT(b.path,'>',c.child_part_id),
         c.child_part_id AS leaf,
         b.total_qty * c.qty AS total_qty
  FROM bom b
  JOIN thc6_bom c ON c.parent_part_id = b.child_part_id
)
SELECT leaf AS part_id, path, total_qty
FROM bom
ORDER BY part_id;

-- B) Cost rollup (sum leaf qty * unit_cost)
WITH RECURSIVE bom AS (
  SELECT parent_part_id, child_part_id, qty, child_part_id AS leaf, qty AS total_qty
  FROM thc6_bom WHERE parent_part_id = 1
  UNION ALL
  SELECT b.parent_part_id, c.child_part_id, b.qty * c.qty, c.child_part_id, b.total_qty * c.qty
  FROM bom b
  JOIN thc6_bom c ON c.parent_part_id = b.child_part_id
), leaves AS (
  SELECT leaf AS part_id, SUM(total_qty) AS qty_needed
  FROM bom
  LEFT JOIN thc6_bom next ON next.parent_part_id = bom.leaf
  WHERE next.parent_part_id IS NULL
  GROUP BY leaf
)
SELECT SUM(l.qty_needed * p.unit_cost) AS total_cost
FROM leaves l
JOIN thc6_parts p ON p.part_id = l.part_id;

-- C) Guards outline
-- Add a visited set via path and stop when encountering a previously seen node; cap recursion depth with a level column.
```
Trade-offs
- Recursive CTE is readable; for very deep BOMs, consider materialized transitive closure.

---

## Challenge 3: Hospital Follow-up Compliance — 50–60 min
Scenario: Track whether discharged patients had a follow-up within 14 days using subqueries and a calendar CTE.

**Healthcare Context:**
After discharge, patients should have a follow-up visit within 14 days to ensure recovery is on track. This is a key quality metric for hospitals!

**What You're Building:**
- For each discharge, check if follow-up happened in time
- Track rolling 7-day follow-up counts (helps identify capacity issues)
- Use calendar CTE to ensure every day appears (even with 0 follow-ups)

Schema and sample data
```sql
DROP TABLE IF EXISTS thc6_patients;
CREATE TABLE thc6_patients (patient_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO thc6_patients VALUES (1,'Ana'),(2,'Ben'),(3,'Cara');

DROP TABLE IF EXISTS thc6_visits;
CREATE TABLE thc6_visits (visit_id INT PRIMARY KEY, patient_id INT, type VARCHAR(20), visit_date DATE);
INSERT INTO thc6_visits VALUES
(100,1,'discharge','2025-03-01'),(101,1,'followup','2025-03-10'),
(102,2,'discharge','2025-03-02'),(103,2,'followup','2025-03-25'),
(104,3,'discharge','2025-03-05');
```
Parts
A) For each discharge, find if a follow-up exists within 14 days (EXISTS with correlated date range).
B) Compute 7-day rolling count of follow-ups per day in March using a calendar CTE.
C) Open-ended: Discuss pros/cons of precomputing a dates table vs generating via recursion.

Solutions and trade-offs
```sql
-- A) Follow-up within 14 days
SELECT d.patient_id, d.visit_date AS discharge_date,
       EXISTS (
         SELECT 1 FROM thc6_visits f
         WHERE f.patient_id = d.patient_id AND f.type = 'followup'
           AND f.visit_date > d.visit_date AND f.visit_date <= DATE_ADD(d.visit_date, INTERVAL 14 DAY)
       ) AS has_followup
FROM thc6_visits d
WHERE d.type = 'discharge'
ORDER BY d.patient_id;

-- B) 7-day rolling follow-ups
WITH RECURSIVE cal AS (
  SELECT DATE('2025-03-01') AS d
  UNION ALL
  SELECT DATE_ADD(d, INTERVAL 1 DAY) FROM cal WHERE d < '2025-03-31'
), daily AS (
  SELECT visit_date AS d, COUNT(*) AS cnt
  FROM thc6_visits
  WHERE type = 'followup' AND visit_date BETWEEN '2025-03-01' AND '2025-03-31'
  GROUP BY visit_date
)
SELECT c.d,
  (
    SELECT COALESCE(SUM(cnt),0)
    FROM daily d2
    WHERE d2.d > DATE_SUB(c.d, INTERVAL 7 DAY) AND d2.d <= c.d
  ) AS followups_7d
FROM cal c
ORDER BY c.d;

-- C) Dates table vs recursion
-- Dates table offers better performance and reuse; recursion is flexible but can be slower at scale.
```
Trade-offs
- Correlated EXISTS simplifies conditional time windows.
- Rolling windows via subquery are simple; windows functions can be used if available for performance.
