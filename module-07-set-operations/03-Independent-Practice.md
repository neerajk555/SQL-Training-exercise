# Independent Practice — Set Operations

Work through these exercises on your own. Each includes difficulty level, time estimate, scenario, schema with sample data, requirements, example output, success criteria, hints (3 levels), and detailed solution with alternatives.

## 📋 Before You Start

### Learning Objectives
Through independent practice, you will:
- Apply set operations without guidance
- Choose the right operation (UNION, UNION ALL, INTERSECT, EXCEPT)
- Combine data from multiple tables effectively
- Handle column alignment and type matching
- Solve real-world data merging problems

### Difficulty Progression
- 🟢 **Easy (1-3)**: Simple UNION/UNION ALL, 12-15 minutes
- 🟡 **Medium (4-6)**: INTERSECT/EXCEPT patterns, filtering, 18-22 minutes
- 🔴 **Challenge (7)**: Complex multi-operation queries, 25-30 minutes

### Problem-Solving Strategy
1. **READ** requirements—identify which operation is needed
2. **SETUP** sample data
3. **PLAN** your approach:
   - Combine data? → UNION or UNION ALL
   - Find common rows? → INTERSECT (or INNER JOIN DISTINCT)
   - Find differences? → EXCEPT (or LEFT JOIN ... IS NULL)
   - Need duplicates? → UNION ALL, else UNION
4. **VERIFY column compatibility** (count, types, order)
5. **TRY** solving independently
6. **TEST** and check row counts
7. **USE HINTS** if stuck
8. **REVIEW** solution for alternatives

**Common Pitfalls:**
- ❌ Column count mismatch between SELECTs
- ❌ Wrong column order causing type incompatibility
- ❌ ORDER BY in wrong place (must be at end)
- ❌ Using UNION when UNION ALL is faster and sufficient
- ❌ Expecting row deduplication when row content differs slightly
- ✅ Test each SELECT independently before combining!

**Quick Decision Guide:**
- Need ALL rows from multiple sources? → UNION ALL
- Need UNIQUE rows from multiple sources? → UNION
- Need rows in BOTH sources? → INTERSECT or INNER JOIN
- Need rows in A but NOT in B? → EXCEPT or LEFT JOIN ... IS NULL

**Beginner Tip:** Start with Easy exercises. Read the scenario carefully, set up the data, and try solving before looking at hints. Set operations let you combine and compare datasets elegantly!

---

## Exercise 1: Merge Regional Sales 🟢 Easy

**Time Estimate:** 12–15 min  
**Difficulty:** 🟢 Easy

### Scenario
Your company has sales data from two regions (North and South). Combine them into one report for management, keeping all records including duplicates.

### Schema and Sample Data
```sql
DROP TABLE IF EXISTS ip7_north_sales;
CREATE TABLE ip7_north_sales (
  sale_id INT PRIMARY KEY,
  product VARCHAR(40),
  amount DECIMAL(8,2),
  sale_date DATE
);
INSERT INTO ip7_north_sales VALUES
(1,'Laptop',1200.00,'2025-03-01'),
(2,'Mouse',25.00,'2025-03-02'),
(3,'Keyboard',75.00,'2025-03-03');

DROP TABLE IF EXISTS ip7_south_sales;
CREATE TABLE ip7_south_sales (
  sale_id INT PRIMARY KEY,
  product VARCHAR(40),
  amount DECIMAL(8,2),
  sale_date DATE
);
INSERT INTO ip7_south_sales VALUES
(4,'Laptop',1200.00,'2025-03-01'),
(5,'Monitor',350.00,'2025-03-02'),
(6,'Mouse',25.00,'2025-03-03');
```

### Requirements
1. Combine both tables into one result set
2. Keep all records including duplicates
3. Add a column showing region ('North' or 'South')
4. Order by sale_date, then sale_id

### Example Output
```
sale_id | product  | amount  | sale_date  | region
1       | Laptop   | 1200.00 | 2025-03-01 | North
4       | Laptop   | 1200.00 | 2025-03-01 | South
2       | Mouse    | 25.00   | 2025-03-02 | North
5       | Monitor  | 350.00  | 2025-03-02 | South
3       | Keyboard | 75.00   | 2025-03-03 | North
6       | Mouse    | 25.00   | 2025-03-03 | South
```

### Success Criteria
- ✅ All 6 rows appear
- ✅ Region column correctly labeled
- ✅ Sorted by sale_date, then sale_id
- ✅ Used UNION ALL (not UNION)

### Hints

**Level 1 (Gentle Nudge):** 
Think about combining the two tables. Do you want to remove duplicates or keep all records? Look at the requirements: "keeping all records including duplicates" → which operation keeps everything?

**Level 2 (More Direct):** 
Use UNION ALL to combine both tables. Add a literal string column for the region: `'North' AS region` in the first SELECT and `'South' AS region` in the second. Remember to match all columns (sale_id, product, amount, sale_date, region) in both SELECTs.

**Level 3 (Almost There):** 
```sql
SELECT sale_id, product, amount, sale_date, 'North' AS region FROM ip7_north_sales
UNION ALL
SELECT sale_id, product, amount, sale_date, 'South' AS region FROM ip7_south_sales
ORDER BY sale_date, sale_id  -- Sort by date first, then ID
```

**Stuck? Common Issues:**
- Forgetting to include all 5 columns in both SELECTs
- Using UNION instead of UNION ALL (removes duplicates you want to keep)
- ORDER BY in wrong place (must be at the very end)

### Solution
```sql
-- Combine regional sales with region labels
SELECT 
  sale_id,
  product,
  amount,
  sale_date,
  'North' AS region  -- Add literal label to identify source
FROM ip7_north_sales

UNION ALL  -- Keep all rows including duplicates (faster, no deduplication)

SELECT 
  sale_id,
  product,
  amount,
  sale_date,
  'South' AS region  -- Add literal label to identify source
FROM ip7_south_sales

ORDER BY sale_date, sale_id;  -- Sort combined result by date, then ID
-- Returns 6 rows (3 from North + 3 from South) with region labels
```

**Why This Solution Works:**
- ✅ Both SELECTs have 5 columns (sale_id, product, amount, sale_date, region)
- ✅ All column types match (INT, VARCHAR, DECIMAL, DATE, VARCHAR)
- ✅ UNION ALL keeps all 6 records without checking for duplicates (faster)
- ✅ ORDER BY at end sorts the final combined result

**Alternative Approaches:**
- **Use UNION** if you wanted to eliminate exact duplicates (unlikely here since each sale_id is unique, but if same product/amount/date appeared in both regions, UNION would keep only one)
- **Filter before combining**: Add WHERE clauses to pre-filter data
  ```sql
  SELECT ... FROM ip7_north_sales WHERE sale_date >= '2025-03-01'
  UNION ALL
  SELECT ... FROM ip7_south_sales WHERE sale_date >= '2025-03-01'
  ```
- **Aggregate after combining**: Wrap in subquery and analyze
  ```sql
  SELECT region, SUM(amount) AS total_sales
  FROM (
    SELECT ... FROM ip7_north_sales UNION ALL SELECT ... FROM ip7_south_sales
  ) AS combined
  GROUP BY region;
  ```

---

## Exercise 2: Common Customers Across Stores 🟢 Easy

**Time Estimate:** 13–16 min  
**Difficulty:** 🟢 Easy

### Scenario
Find customers who've shopped at BOTH your downtown and suburban stores to offer them a loyalty program.

### Schema and Sample Data
```sql
DROP TABLE IF EXISTS ip7_downtown_customers;
CREATE TABLE ip7_downtown_customers (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(60)
);
INSERT INTO ip7_downtown_customers VALUES
(101,'Alice Johnson'),
(102,'Bob Smith'),
(103,'Carol White'),
(104,'Dave Brown'),
(105,'Eve Davis');

DROP TABLE IF EXISTS ip7_suburban_customers;
CREATE TABLE ip7_suburban_customers (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(60)
);
INSERT INTO ip7_suburban_customers VALUES
(102,'Bob Smith'),
(103,'Carol White'),
(106,'Frank Miller'),
(107,'Grace Lee');
```

### Requirements
1. Find customers who appear in BOTH stores
2. Show customer_id and customer_name
3. Order by customer_id
4. Use INNER JOIN or INTERSECT (MySQL 8.0.31+)

### Example Output
```
customer_id | customer_name
102         | Bob Smith
103         | Carol White
```

### Success Criteria
- ✅ Only 2 customers (102, 103) appear
- ✅ Names match correctly
- ✅ No duplicates
- ✅ Used appropriate method (JOIN or INTERSECT)

### Hints

**Level 1 (Gentle Nudge):** 
You need customers in BOTH stores—that's an intersection problem. Think: What operation shows you the overlap? (Hint: INTERSECT or INNER JOIN)

**Level 2 (More Direct):** 
INNER JOIN keeps only rows that have matches in BOTH tables. Join the two customer tables on customer_id. Alternatively, if you have MySQL 8.0.31+, use INTERSECT to get matching customer records.

**Level 3 (Almost There):**
```sql
SELECT DISTINCT d.customer_id, d.customer_name
FROM ip7_downtown_customers d
INNER JOIN ip7_suburban_customers s ON d.customer_id = s.customer_id
ORDER BY d.customer_id;
```

**Debugging Tips:**
- Test each table separately first: `SELECT * FROM ip7_downtown_customers` and `SELECT * FROM ip7_suburban_customers`
- Look for customer_ids that appear in both: 102 and 103
- INNER JOIN will keep ONLY those two matching records

### Solution
```sql
-- Find customers who shop at both locations (the intersection)
SELECT DISTINCT 
  d.customer_id,
  d.customer_name
FROM ip7_downtown_customers d
INNER JOIN ip7_suburban_customers s ON d.customer_id = s.customer_id
-- INNER JOIN keeps only rows where customer_id exists in BOTH tables
ORDER BY d.customer_id;
-- Returns 2 customers: Bob (102) and Carol (103)

/* Why this works:
   Downtown has: 101, 102, 103, 104, 105
   Suburban has: 102, 103, 106, 107
   Overlap (in BOTH): 102, 103 ← These are our loyalty program candidates!
*/

-- Alternative with INTERSECT (MySQL 8.0.31+)
-- SELECT customer_id, customer_name FROM ip7_downtown_customers
-- INTERSECT
-- SELECT customer_id, customer_name FROM ip7_suburban_customers
-- ORDER BY customer_id;
```

**Why DISTINCT?** Even though customer_id is a PRIMARY KEY (no duplicates within tables), it's good practice when using INNER JOIN for set operations to ensure no unexpected duplicates.

**Performance Note:** 
- With indexes on customer_id, INNER JOIN is very fast
- INTERSECT is syntactically cleaner but may be slightly slower on large datasets
- For most real-world uses, the difference is negligible—choose based on readability and MySQL version

---

## Exercise 3: Exclusive Downtown Shoppers 🟢 Easy

**Time Estimate:** 14–17 min  
**Difficulty:** 🟢 Easy

### Scenario
Identify customers who shop ONLY at the downtown store (not suburban) to target with suburban store promotions.

### Schema and Sample Data
```sql
-- Use same tables from Exercise 2
-- ip7_downtown_customers: 101,102,103,104,105
-- ip7_suburban_customers: 102,103,106,107
```

### Requirements
1. Find customers in downtown but NOT in suburban
2. Show customer_id and customer_name
3. Order by customer_id
4. Use LEFT JOIN ... IS NULL or EXCEPT

### Example Output
```
customer_id | customer_name
101         | Alice Johnson
104         | Dave Brown
105         | Eve Davis
```

### Success Criteria
- ✅ Exactly 3 customers (101, 104, 105)
- ✅ Bob (102) and Carol (103) excluded (they're in both)
- ✅ Correct names displayed
- ✅ Used appropriate exclusion pattern

### Hints

**Level 1 (Gentle Nudge):** LEFT JOIN keeps all downtown customers; filter where suburban side is NULL.

**Level 2 (More Direct):** LEFT JOIN downtown TO suburban, then WHERE s.customer_id IS NULL.

**Level 3 (Almost There):**
```sql
SELECT d.customer_id, d.customer_name
FROM ip7_downtown_customers d
LEFT JOIN ip7_suburban_customers s ON d.customer_id = s.customer_id
WHERE s.customer_id IS NULL
```

### Solution
```sql
-- Customers only in downtown (not in suburban)
SELECT 
  d.customer_id,
  d.customer_name
FROM ip7_downtown_customers d
LEFT JOIN ip7_suburban_customers s ON d.customer_id = s.customer_id
WHERE s.customer_id IS NULL  -- Filter out matches
ORDER BY d.customer_id;
-- Returns 3 customers: Alice (101), Dave (104), Eve (105)

-- Alternative with EXCEPT (MySQL 8.0.31+)
-- SELECT customer_id, customer_name FROM ip7_downtown_customers
-- EXCEPT
-- SELECT customer_id, customer_name FROM ip7_suburban_customers
-- ORDER BY customer_id;
```

**Trade-offs:** LEFT JOIN ... IS NULL is very common and portable. EXCEPT is cleaner but requires MySQL 8.0.31+.

---

## Exercise 4: All-Stores Customer List 🟡 Medium

**Time Estimate:** 18–22 min  
**Difficulty:** 🟡 Medium

### Scenario
Create a master customer list from three stores (downtown, suburban, online) with store location tags. Some customers shop at multiple locations.

### Schema and Sample Data
```sql
DROP TABLE IF EXISTS ip7_downtown;
CREATE TABLE ip7_downtown (customer_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO ip7_downtown VALUES (1,'Alice'),(2,'Bob'),(3,'Carol');

DROP TABLE IF EXISTS ip7_suburban;
CREATE TABLE ip7_suburban (customer_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO ip7_suburban VALUES (2,'Bob'),(4,'Dave'),(5,'Eve');

DROP TABLE IF EXISTS ip7_online;
CREATE TABLE ip7_online (customer_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO ip7_online VALUES (1,'Alice'),(3,'Carol'),(5,'Eve'),(6,'Frank');
```

### Requirements
1. Combine all three stores into one list
2. Show customer_id, name, and store location
3. Keep all occurrences (customers may appear multiple times)
4. Order by customer_id, then store location
5. Store locations: 'Downtown', 'Suburban', 'Online'

### Example Output
```
customer_id | name  | location
1           | Alice | Downtown
1           | Alice | Online
2           | Bob   | Downtown
2           | Bob   | Suburban
3           | Carol | Downtown
3           | Carol | Online
4           | Dave  | Suburban
5           | Eve   | Suburban
5           | Eve   | Online
6           | Frank | Online
```

### Success Criteria
- ✅ All 10 rows present (customers with multiple stores appear multiple times)
- ✅ Location labels correct
- ✅ Sorted by customer_id, then location
- ✅ Used UNION ALL

### Hints

**Level 1 (Gentle Nudge):** Use three SELECT statements combined with UNION ALL, each adding a different location label.

**Level 2 (More Direct):** 
```sql
SELECT customer_id, name, 'Downtown' AS location FROM ip7_downtown
UNION ALL
SELECT customer_id, name, 'Suburban' AS location FROM ip7_suburban
UNION ALL
...
```

**Level 3 (Almost There):** Add the third SELECT for online, then ORDER BY customer_id, location.

### Solution
```sql
-- Master customer list from all stores
SELECT 
  customer_id,
  name,
  'Downtown' AS location
FROM ip7_downtown

UNION ALL

SELECT 
  customer_id,
  name,
  'Suburban' AS location
FROM ip7_suburban

UNION ALL

SELECT 
  customer_id,
  name,
  'Online' AS location
FROM ip7_online

ORDER BY customer_id, location;
-- Returns 10 rows showing all customer-location combinations
```

**Business Value:** This multi-store view helps identify cross-channel shoppers for targeted marketing.

---

## Exercise 5: Product Availability Gap Analysis 🟡 Medium

**Time Estimate:** 20–25 min  
**Difficulty:** 🟡 Medium

### Scenario
Your catalog has 10 products, but not all are in stock. Find which products are missing from inventory to prioritize restocking.

### Schema and Sample Data
```sql
DROP TABLE IF EXISTS ip7_catalog;
CREATE TABLE ip7_catalog (
  product_code VARCHAR(10) PRIMARY KEY,
  product_name VARCHAR(60),
  category VARCHAR(30)
);
INSERT INTO ip7_catalog VALUES
('P001','Laptop','Electronics'),
('P002','Mouse','Electronics'),
('P003','Desk','Furniture'),
('P004','Chair','Furniture'),
('P005','Notebook','Stationery'),
('P006','Pen','Stationery'),
('P007','Monitor','Electronics'),
('P008','Lamp','Furniture'),
('P009','Stapler','Stationery'),
('P010','Keyboard','Electronics');

DROP TABLE IF EXISTS ip7_inventory;
CREATE TABLE ip7_inventory (
  product_code VARCHAR(10) PRIMARY KEY,
  quantity INT
);
INSERT INTO ip7_inventory VALUES
('P001',15),
('P002',50),
('P004',8),
('P005',100),
('P007',12),
('P009',30);
```

### Requirements
1. Find products in catalog but NOT in inventory
2. Show product_code, product_name, category
3. Group by category and show count
4. Also list individual missing products
5. Use EXCEPT or LEFT JOIN ... IS NULL

### Example Output (Individual Missing Products)
```
product_code | product_name | category
P003         | Desk         | Furniture
P006         | Pen          | Stationery
P008         | Lamp         | Furniture
P010         | Keyboard     | Electronics
```

### Example Output (Summary by Category)
```
category     | missing_count
Electronics  | 2
Furniture    | 2
Stationery   | 1
```

### Success Criteria
- ✅ 4 missing products identified
- ✅ Correct product details shown
- ✅ Summary by category provided
- ✅ Used appropriate exclusion method

### Hints

**Level 1 (Gentle Nudge):** LEFT JOIN catalog to inventory, filter WHERE inventory side IS NULL.

**Level 2 (More Direct):** 
```sql
SELECT c.product_code, c.product_name, c.category
FROM ip7_catalog c
LEFT JOIN ip7_inventory i ON c.product_code = i.product_code
WHERE i.product_code IS NULL
```

**Level 3 (Almost There):** For summary, wrap the above in a subquery and GROUP BY category with COUNT(*).

### Solution
```sql
-- Missing products (in catalog but not in inventory)
SELECT 
  c.product_code,
  c.product_name,
  c.category
FROM ip7_catalog c
LEFT JOIN ip7_inventory i ON c.product_code = i.product_code
WHERE i.product_code IS NULL
ORDER BY c.category, c.product_code;
-- Returns 4 products: P003, P006, P008, P010

-- Summary by category
SELECT 
  category,
  COUNT(*) AS missing_count
FROM (
  SELECT c.category
  FROM ip7_catalog c
  LEFT JOIN ip7_inventory i ON c.product_code = i.product_code
  WHERE i.product_code IS NULL
) AS missing
GROUP BY category
ORDER BY missing_count DESC, category;
-- Electronics: 2, Furniture: 2, Stationery: 1

-- Alternative with EXCEPT (MySQL 8.0.31+) - codes only
-- SELECT product_code FROM ip7_catalog
-- EXCEPT
-- SELECT product_code FROM ip7_inventory;
```

**Business Impact:** Identifying out-of-stock items prevents lost sales and improves customer satisfaction.

---

## Exercise 6: Multi-Source Data Validation 🟡 Medium

**Time Estimate:** 22–27 min  
**Difficulty:** 🟡 Medium

### Scenario
You're migrating data from legacy system to new system. Validate that all employee IDs exist in both systems and identify any discrepancies.

### Schema and Sample Data
```sql
DROP TABLE IF EXISTS ip7_legacy_employees;
CREATE TABLE ip7_legacy_employees (
  emp_id INT PRIMARY KEY,
  full_name VARCHAR(60),
  dept VARCHAR(30)
);
INSERT INTO ip7_legacy_employees VALUES
(1001,'Alice Johnson','Sales'),
(1002,'Bob Smith','IT'),
(1003,'Carol White','HR'),
(1004,'Dave Brown','Sales'),
(1005,'Eve Davis','IT');

DROP TABLE IF EXISTS ip7_new_employees;
CREATE TABLE ip7_new_employees (
  emp_id INT PRIMARY KEY,
  full_name VARCHAR(60),
  dept VARCHAR(30)
);
INSERT INTO ip7_new_employees VALUES
(1001,'Alice Johnson','Sales'),
(1002,'Bob Smith','IT'),
(1003,'Carol White','Marketing'),  -- Dept changed
(1006,'Frank Miller','HR');  -- New employee
-- Note: 1004 and 1005 missing from new system
```

### Requirements
1. Find employees in legacy but NOT in new (migration pending)
2. Find employees in new but NOT in legacy (new hires)
3. Find employees in BOTH systems
4. Identify employees with different department values

### Example Output (Migration Pending)
```
emp_id | full_name  | dept
1004   | Dave Brown | Sales
1005   | Eve Davis  | IT
```

### Example Output (New Hires)
```
emp_id | full_name    | dept
1006   | Frank Miller | HR
```

### Example Output (Department Mismatches)
```
emp_id | full_name   | legacy_dept | new_dept
1003   | Carol White | HR          | Marketing
```

### Success Criteria
- ✅ All three queries provided
- ✅ Correct employees identified in each category
- ✅ Department mismatches detected
- ✅ Used appropriate set operations or JOINs

### Hints

**Level 1 (Gentle Nudge):** Use LEFT JOIN ... IS NULL for "in A not in B" pattern. Use INNER JOIN to find both. Compare dept columns.

**Level 2 (More Direct):** 
- Migration pending: LEFT JOIN legacy TO new WHERE new.emp_id IS NULL
- New hires: LEFT JOIN new TO legacy WHERE legacy.emp_id IS NULL
- Mismatches: INNER JOIN WHERE legacy.dept <> new.dept

**Level 3 (Almost There):** Combine all three queries with clear labels using UNION ALL for a complete report.

### Solution
```sql
-- 1. Employees in legacy but not in new (migration pending)
SELECT 
  l.emp_id,
  l.full_name,
  l.dept
FROM ip7_legacy_employees l
LEFT JOIN ip7_new_employees n ON l.emp_id = n.emp_id
WHERE n.emp_id IS NULL
ORDER BY l.emp_id;
-- Returns: 1004 (Dave), 1005 (Eve)

-- 2. Employees in new but not in legacy (new hires)
SELECT 
  n.emp_id,
  n.full_name,
  n.dept
FROM ip7_new_employees n
LEFT JOIN ip7_legacy_employees l ON n.emp_id = l.emp_id
WHERE l.emp_id IS NULL
ORDER BY n.emp_id;
-- Returns: 1006 (Frank)

-- 3. Employees in both systems
SELECT 
  l.emp_id,
  l.full_name
FROM ip7_legacy_employees l
INNER JOIN ip7_new_employees n ON l.emp_id = n.emp_id
ORDER BY l.emp_id;
-- Returns: 1001, 1002, 1003

-- 4. Department mismatches
SELECT 
  l.emp_id,
  l.full_name,
  l.dept AS legacy_dept,
  n.dept AS new_dept
FROM ip7_legacy_employees l
INNER JOIN ip7_new_employees n ON l.emp_id = n.emp_id
WHERE l.dept <> n.dept
ORDER BY l.emp_id;
-- Returns: 1003 (Carol) HR→Marketing

-- Combined validation report
SELECT 'Migration Pending' AS status, emp_id, full_name FROM (
  SELECT l.emp_id, l.full_name
  FROM ip7_legacy_employees l
  LEFT JOIN ip7_new_employees n ON l.emp_id = n.emp_id
  WHERE n.emp_id IS NULL
) AS pending
UNION ALL
SELECT 'New Hire' AS status, emp_id, full_name FROM (
  SELECT n.emp_id, n.full_name
  FROM ip7_new_employees n
  LEFT JOIN ip7_legacy_employees l ON n.emp_id = l.emp_id
  WHERE l.emp_id IS NULL
) AS new_hires
UNION ALL
SELECT 'Dept Mismatch' AS status, emp_id, full_name FROM (
  SELECT l.emp_id, l.full_name
  FROM ip7_legacy_employees l
  INNER JOIN ip7_new_employees n ON l.emp_id = n.emp_id
  WHERE l.dept <> n.dept
) AS mismatches
ORDER BY status, emp_id;
```

**Migration Checklist:**
1. Migrate pending employees (1004, 1005)
2. Validate new hire (1006) is intentional
3. Resolve department discrepancy for 1003

---

## Exercise 7: Customer Lifetime Value Segments 🔴 Challenge

**Time Estimate:** 30–40 min  
**Difficulty:** 🔴 Challenge

### Scenario
Segment customers into tiers based on purchase history: VIP (3+ purchases), Regular (1-2 purchases), and Inactive (no purchases in last year). Use historical purchases, recent purchases, and customer master data.

### Schema and Sample Data
```sql
DROP TABLE IF EXISTS ip7_customers;
CREATE TABLE ip7_customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(60),
  signup_date DATE
);
INSERT INTO ip7_customers VALUES
(1,'Alice',DATE_SUB(CURDATE(), INTERVAL 500 DAY)),
(2,'Bob',DATE_SUB(CURDATE(), INTERVAL 400 DAY)),
(3,'Carol',DATE_SUB(CURDATE(), INTERVAL 300 DAY)),
(4,'Dave',DATE_SUB(CURDATE(), INTERVAL 200 DAY)),
(5,'Eve',DATE_SUB(CURDATE(), INTERVAL 100 DAY)),
(6,'Frank',DATE_SUB(CURDATE(), INTERVAL 50 DAY));

DROP TABLE IF EXISTS ip7_purchases;
CREATE TABLE ip7_purchases (
  purchase_id INT PRIMARY KEY,
  customer_id INT,
  amount DECIMAL(10,2),
  purchase_date DATE
);
INSERT INTO ip7_purchases VALUES
(1,1,100,DATE_SUB(CURDATE(), INTERVAL 10 DAY)),
(2,1,150,DATE_SUB(CURDATE(), INTERVAL 30 DAY)),
(3,1,200,DATE_SUB(CURDATE(), INTERVAL 60 DAY)),
(4,1,120,DATE_SUB(CURDATE(), INTERVAL 90 DAY)),
(5,2,80,DATE_SUB(CURDATE(), INTERVAL 20 DAY)),
(6,2,90,DATE_SUB(CURDATE(), INTERVAL 40 DAY)),
(7,3,200,DATE_SUB(CURDATE(), INTERVAL 15 DAY)),
(8,4,50,DATE_SUB(CURDATE(), INTERVAL 400 DAY)),
(9,5,300,DATE_SUB(CURDATE(), INTERVAL 5 DAY));
-- Frank (6) has no purchases
```

### Requirements
1. Calculate purchases per customer
2. Classify into tiers: VIP (3+), Regular (1-2), Inactive (0 in last year)
3. Show customer_id, name, purchase_count, total_spent, tier
4. Order by tier (VIP first), then total_spent DESC
5. Handle customers with no purchases

### Example Output
```
customer_id | name  | purchase_count | total_spent | tier
1           | Alice | 4              | 570.00      | VIP
2           | Bob   | 2              | 170.00      | Regular
3           | Carol | 1              | 200.00      | Regular
5           | Eve   | 1              | 300.00      | Regular
4           | Dave  | 0              | 0.00        | Inactive
6           | Frank | 0              | 0.00        | Inactive
```
(Note: Dave's purchase was >365 days ago so counts as inactive)

### Success Criteria
- ✅ All 6 customers appear
- ✅ Purchase counts accurate (recent purchases only)
- ✅ Tiers correctly assigned
- ✅ Sorted by tier priority, then total_spent
- ✅ Customers with no purchases handled

### Hints

**Level 1 (Gentle Nudge):** Use LEFT JOIN to keep all customers. Filter purchases by date. Use CASE for tier classification.

**Level 2 (More Direct):** 
```sql
LEFT JOIN customers TO purchases WHERE purchase_date >= DATE_SUB(CURDATE(), INTERVAL 365 DAY)
GROUP BY customer_id
CASE WHEN COUNT(purchase_id) >= 3 THEN 'VIP' ...
```

**Level 3 (Almost There):** Use COALESCE or IFNULL for customers with no purchases. Order by CASE expression for tier priority.

### Solution
```sql
-- Customer segmentation by purchase activity
SELECT 
  c.customer_id,
  c.name,
  COUNT(p.purchase_id) AS purchase_count,
  COALESCE(SUM(p.amount), 0) AS total_spent,
  CASE 
    WHEN COUNT(p.purchase_id) >= 3 THEN 'VIP'
    WHEN COUNT(p.purchase_id) BETWEEN 1 AND 2 THEN 'Regular'
    ELSE 'Inactive'
  END AS tier
FROM ip7_customers c
LEFT JOIN ip7_purchases p 
  ON c.customer_id = p.customer_id 
  AND p.purchase_date >= DATE_SUB(CURDATE(), INTERVAL 365 DAY)
GROUP BY c.customer_id, c.name
ORDER BY 
  CASE 
    WHEN COUNT(p.purchase_id) >= 3 THEN 1
    WHEN COUNT(p.purchase_id) BETWEEN 1 AND 2 THEN 2
    ELSE 3
  END,
  total_spent DESC;

-- Result breakdown:
-- VIP: Alice (4 purchases, $570)
-- Regular: Eve ($300), Carol ($200), Bob ($170)
-- Inactive: Dave (old purchase), Frank (no purchases)
```

**Alternative with CTE for readability:**
```sql
WITH customer_stats AS (
  SELECT 
    c.customer_id,
    c.name,
    COUNT(p.purchase_id) AS purchase_count,
    COALESCE(SUM(p.amount), 0) AS total_spent
  FROM ip7_customers c
  LEFT JOIN ip7_purchases p 
    ON c.customer_id = p.customer_id 
    AND p.purchase_date >= DATE_SUB(CURDATE(), INTERVAL 365 DAY)
  GROUP BY c.customer_id, c.name
)
SELECT 
  customer_id,
  name,
  purchase_count,
  total_spent,
  CASE 
    WHEN purchase_count >= 3 THEN 'VIP'
    WHEN purchase_count BETWEEN 1 AND 2 THEN 'Regular'
    ELSE 'Inactive'
  END AS tier
FROM customer_stats
ORDER BY 
  CASE 
    WHEN purchase_count >= 3 THEN 1
    WHEN purchase_count BETWEEN 1 AND 2 THEN 2
    ELSE 3
  END,
  total_spent DESC;
```

**Business Applications:**
- **VIP tier**: Offer exclusive rewards, early access to sales
- **Regular tier**: Send re-engagement campaigns to encourage repeat purchases
- **Inactive tier**: Win-back campaigns with special discounts

**Performance Notes:**
- Index on (customer_id, purchase_date) for efficient filtering
- For large datasets, consider materialized views for tier calculations

---

**Completion Check:** You've mastered set operations from simple UNION to complex multi-source analysis. Ready for collaborative work!

**Next Step:** Move to `04-Paired-Programming.md` for a team activity.
