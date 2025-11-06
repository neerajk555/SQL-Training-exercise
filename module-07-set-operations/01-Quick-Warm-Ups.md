# Quick Warm-Ups — Set Operations (5–10 min each)

Each exercise includes a tiny setup, a task, expected output, and an answer. Run each in its own session.

##  Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Use UNION to combine and deduplicate result sets
- Apply UNION ALL to keep all rows including duplicates
- Implement INTERSECT to find common rows
- Use EXCEPT to find differences between datasets
- Understand column matching requirements

### Key Set Operation Concepts
**UNION vs UNION ALL:**
- `UNION`: Combines results and removes duplicate rows (slower)
- `UNION ALL`: Combines results and keeps all rows (faster)
- Use UNION when you need unique combined results
- Use UNION ALL when duplicates are acceptable or don't exist

**INTERSECT and EXCEPT (MySQL 8.0.31+):**
- `INTERSECT`: Returns only rows in BOTH result sets
- `EXCEPT`: Returns rows in first set NOT in second set
- For older MySQL, use JOIN patterns as alternatives

**Critical Rules:**
- All SELECT statements must have same number of columns
- Corresponding columns must have compatible data types
- Column names come from first SELECT
- ORDER BY goes at the very end (applies to combined result)

### Execution Tips
1. **Verify column counts match** across all SELECTs
2. **Use same aliases** in all queries for clarity
3. **Test each SELECT separately** before combining
4. **Add ORDER BY last** after all set operations

**Beginner Tip:** Set operations combine results from multiple queries. UNION removes duplicates, UNION ALL keeps them all. INTERSECT finds common rows, EXCEPT finds differences. Always match column count and types!

---

## 1) Combine Active and Inactive Users (UNION) — 7 min

**Scenario:** Merge two user lists and remove duplicates.

**What You're Learning:** How UNION automatically removes duplicate rows when combining data from multiple tables.

**Real-World Context:** You have users in both an "active" and "inactive" table. Some users might exist in both (like Carol, who was active but is now inactive). You want a single list of all unique users.

Sample data
```sql
DROP TABLE IF EXISTS wu7_active_users;
CREATE TABLE wu7_active_users (user_id INT PRIMARY KEY, username VARCHAR(60));
INSERT INTO wu7_active_users VALUES (1,'alice'),(2,'bob'),(3,'carol');

DROP TABLE IF EXISTS wu7_inactive_users;
CREATE TABLE wu7_inactive_users (user_id INT PRIMARY KEY, username VARCHAR(60));
INSERT INTO wu7_inactive_users VALUES (3,'carol'),(4,'dave'),(5,'eve');
```

**Notice:** Carol (user_id 3) appears in BOTH tables!

Task: Return all unique user_id and username from both tables.

Expected output
```
user_id | username
1       | alice
2       | bob
3       | carol  ← Carol appears only ONCE despite being in both tables
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

**Why This Works:**
- UNION compares every row from both queries
- When it finds identical rows (same user_id AND username), it keeps only one copy
- The result is 5 unique users, not 6 rows (even though we had 3 + 3 = 6 total rows)

**Try This:** Change UNION to UNION ALL and run again—you'll see Carol twice!

---

## 2) All Orders Including Duplicates (UNION ALL) — 6 min

**Scenario:** Combine current and archived orders, keeping all rows.

**What You're Learning:** How UNION ALL keeps ALL rows, including duplicates—useful when you need accurate counts or when you know duplicates are meaningful.

**Real-World Context:** You're generating a financial report that needs to show EVERY order record, even if the same order appears in both current and archived systems. Each appearance represents a separate database entry that matters for auditing.

Sample data
```sql
DROP TABLE IF EXISTS wu7_current_orders;
CREATE TABLE wu7_current_orders (order_id INT, amount DECIMAL(8,2));
INSERT INTO wu7_current_orders VALUES (101,50.00),(102,75.50);

DROP TABLE IF EXISTS wu7_archived_orders;
CREATE TABLE wu7_archived_orders (order_id INT, amount DECIMAL(8,2));
INSERT INTO wu7_archived_orders VALUES (102,75.50),(103,120.00);
```

**Notice:** Order 102 for $75.50 exists in BOTH tables—maybe it was archived but also still showing in current for some reason.

Task: Return all orders from both tables (including duplicates).

Expected output
```
order_id | amount
101      | 50.00
102      | 75.50  ← Order 102 appears TWICE
102      | 75.50  ← Once from current, once from archived
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

**Why This Works:**
- UNION ALL just stacks the results together without checking for duplicates
- We get 4 rows total (2 from current + 2 from archived)
- Order 102 appears twice because it's in both tables
- Much faster than UNION because no duplicate checking is needed

**When to Use UNION ALL:**
- When you need to count total records (each record matters)
- When you know there are no duplicates (or duplicates are meaningful)
- When performance matters and you don't need deduplication

---

## 3) Common Products (INTERSECT Alternative) — 8 min

**Scenario:** Find products available in both warehouses.

**What You're Learning:** How to find the intersection—items that exist in BOTH datasets. This is crucial for finding overlaps or commonalities.

**Real-World Context:** You manage inventory for two warehouses. You want to know which products are stocked in BOTH locations (the overlap), so you can transfer stock strategically or ensure backup availability.

Sample data
```sql
DROP TABLE IF EXISTS wu7_warehouse_a;
CREATE TABLE wu7_warehouse_a (product_id INT PRIMARY KEY, product_name VARCHAR(60));
INSERT INTO wu7_warehouse_a VALUES (1,'Laptop'),(2,'Mouse'),(3,'Keyboard');

DROP TABLE IF EXISTS wu7_warehouse_b;
CREATE TABLE wu7_warehouse_b (product_id INT PRIMARY KEY, product_name VARCHAR(60));
INSERT INTO wu7_warehouse_b VALUES (2,'Mouse'),(3,'Keyboard'),(4,'Monitor');
```

**Notice:** 
- Warehouse A has: Laptop, Mouse, Keyboard
- Warehouse B has: Mouse, Keyboard, Monitor
- Common to BOTH: Mouse and Keyboard

Task: Return products that exist in BOTH warehouses (use INNER JOIN or INTERSECT if MySQL 8.0.31+).

Expected output
```
product_id | product_name
2          | Mouse      ← In both warehouses
3          | Keyboard   ← In both warehouses
```

**Note:** Laptop (only in A) and Monitor (only in B) are NOT returned because they're not in BOTH.

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

**Why This Works:**
- INNER JOIN only keeps rows where there's a match in BOTH tables
- We match on product_id, so only products with the same ID in both tables survive
- DISTINCT handles any potential duplicates within individual tables
- Result: Only the 2 products that exist in both warehouses

**Think of it as:** "Show me the overlap in the Venn diagram"

---

## 4) Products Only in Warehouse A (EXCEPT Alternative) — 8 min

**Scenario:** Find products in warehouse A but NOT in warehouse B.

**What You're Learning:** How to find the difference—items unique to one set. This is like subtraction: "Give me A minus B".

**Real-World Context:** You need to know which products are ONLY in warehouse A (not in B). Maybe you want to transfer them to B, or these are exclusive items that B doesn't carry.

Sample data
```sql
DROP TABLE IF EXISTS wu7_wh_a;
CREATE TABLE wu7_wh_a (product_id INT PRIMARY KEY);
INSERT INTO wu7_wh_a VALUES (10),(11),(12);

DROP TABLE IF EXISTS wu7_wh_b;
CREATE TABLE wu7_wh_b (product_id INT PRIMARY KEY);
INSERT INTO wu7_wh_b VALUES (11),(13);
```

**Notice:**
- Warehouse A has: 10, 11, 12
- Warehouse B has: 11, 13
- Product 11 is in BOTH (so we DON'T want it)
- Products 10 and 12 are ONLY in A (these are what we want!)

Task: Return product_id from A that's NOT in B (use LEFT JOIN ... IS NULL or EXCEPT).

Expected output
```
product_id
10  ← Only in A
12  ← Only in A
```

**Note:** Product 11 is NOT returned because it exists in B too!

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

**Why This Works:**
- LEFT JOIN keeps ALL rows from warehouse A (the left table)
- For products that DON'T have a match in B, the B columns are NULL
- WHERE b.product_id IS NULL filters to ONLY the non-matching rows
- Result: Products in A but not in B

**Think of it as:** "Show me what's in the first circle but not in the second circle of the Venn diagram"

**Common Mistake:** Using INNER JOIN would only show matches (the opposite of what we want!)

---

## 5) Three-Way Union with Labels — 9 min

**Scenario:** Combine three employee lists with source labels.

**What You're Learning:** How to combine MORE than two tables, and how to add a label column to identify where each row came from.

**Real-World Context:** Your company has full-time employees, part-time employees, and contractors in separate tables. You need a unified employee roster that shows everyone along with their employment type for a company directory.

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

**Notice:** Each table has only emp_id and name, but we want to ADD a "source" column to track employment type.

Task: Combine all employees with a source column ('FT', 'PT', 'Contractor').

Expected output
```
emp_id | name  | source
1      | Alice | FT         ← From full_time table
2      | Bob   | FT         ← From full_time table
3      | Carol | PT         ← From part_time table
4      | Dave  | Contractor ← From contractors table
5      | Eve   | Contractor ← From contractors table
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

**Why This Works:**
- Each SELECT adds a literal string ('FT', 'PT', or 'Contractor') as the third column
- All three SELECTs have the same structure: emp_id (INT), name (VARCHAR), source (VARCHAR)
- UNION ALL combines them all without checking for duplicates
- We chain multiple UNION ALLs—you can combine as many queries as needed!
- ORDER BY at the end sorts the entire combined result

**Key Technique:** Adding literal values (like 'FT') as columns is a powerful way to label where data came from when combining multiple sources.

**Why UNION ALL here?** Since each employee has a unique ID and is only in one table, we know there are no duplicates—UNION ALL is faster and appropriate.

---

**Time Estimate Check:** Each warm-up should take 5–10 minutes. If you're taking longer, focus on understanding the set operation syntax. If faster, great—you're ready for guided activities!

**Next Step:** Move to `02-Guided-Step-by-Step.md` for structured scenarios with checkpoints.
