# Error Detective — Subqueries & CTEs (5 challenges)

Each challenge includes scenario, broken query, error or wrong result, sample data, expected output, guiding questions, and a fix explanation.

**Beginner Tip:** Subquery bugs often involve NULLs, wrong row counts, or scope issues. Test the inner query separately first. Watch out for NOT IN with NULLs—it's a classic trap! These challenges prepare you for real-world query debugging.

---

## ED1) NOT IN with NULL nukes your results
Scenario: Find products never ordered; subquery may return NULLs.

Sample data
```sql
DROP TABLE IF EXISTS ed6_1_products;
CREATE TABLE ed6_1_products (product_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO ed6_1_products VALUES (1,'Notebook'),(2,'Lamp'),(3,'Mug');

DROP TABLE IF EXISTS ed6_1_items;
CREATE TABLE ed6_1_items (order_item_id INT PRIMARY KEY, product_id INT);
INSERT INTO ed6_1_items VALUES (1,1),(2,NULL);
```
Broken query and symptom
```sql
SELECT name FROM ed6_1_products
WHERE product_id NOT IN (SELECT product_id FROM ed6_1_items);
-- Returns 0 rows because subquery yields NULL
```
Expected output
```
name
Lamp
Mug
```
Fix and explanation
```sql
SELECT p.name
FROM ed6_1_products p
WHERE NOT EXISTS (
  SELECT 1 FROM ed6_1_items i WHERE i.product_id = p.product_id
);
-- NOT EXISTS is NULL-safe; NOT IN is unsafe if the subquery can return NULLs.
```

**Why This Bug Is So Common:**
This is the #1 subquery trap in SQL! Here's what actually happens:

**The Broken NOT IN Logic:**
```sql
WHERE product_id NOT IN (1, NULL)
-- Expands to: WHERE product_id <> 1 AND product_id <> NULL
-- But "product_id <> NULL" is UNKNOWN (not TRUE or FALSE!)
-- In SQL, UNKNOWN in a WHERE clause means the row is filtered out
-- Result: NO ROWS RETURNED (even though Lamp and Mug should appear!)
```

**Visual Example:**
```
Checking Lamp (product_id=2):
  Is 2 NOT IN (1, NULL)?
  → Is 2 != 1? YES ✓
  → Is 2 != NULL? UNKNOWN ❓
  → YES AND UNKNOWN = UNKNOWN
  → Row filtered out! ✗

Checking Mug (product_id=3):
  Is 3 NOT IN (1, NULL)?
  → Is 3 != 1? YES ✓
  → Is 3 != NULL? UNKNOWN ❓
  → YES AND UNKNOWN = UNKNOWN
  → Row filtered out! ✗
```

**The NOT EXISTS Fix:**
```sql
WHERE NOT EXISTS (SELECT 1 FROM items WHERE product_id = p.product_id)
-- For each product, checks: "Does ANY item match this product_id?"
-- Lamp (ID=2): No match found → NOT EXISTS = TRUE → Include ✓
-- Mug (ID=3): No match found → NOT EXISTS = TRUE → Include ✓
-- The NULL row never matches (NULL != 2 and NULL != 3) → Ignored safely
```

**Golden Rules:**
🚨 **NEVER use NOT IN when the subquery can have NULLs**
✅ **ALWAYS use NOT EXISTS for "anti-join" patterns**
✅ **If you must use NOT IN, filter NULLs:** `NOT IN (SELECT col FROM ... WHERE col IS NOT NULL)`

---

## ED2) Uncorrelated "correlated" subquery
Scenario: Latest order date per customer, but the subquery forgot to correlate on customer_id.

Sample data
```sql
DROP TABLE IF EXISTS ed6_2_customers;
CREATE TABLE ed6_2_customers (customer_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO ed6_2_customers VALUES (1,'Ava'),(2,'Noah');

DROP TABLE IF EXISTS ed6_2_orders;
CREATE TABLE ed6_2_orders (order_id INT PRIMARY KEY, customer_id INT, order_date DATE);
INSERT INTO ed6_2_orders VALUES (10,1,'2025-03-01'),(11,2,'2025-03-02');
```
Broken query
```sql
SELECT c.name,
  (SELECT MAX(order_date) FROM ed6_2_orders) AS latest -- same value for all
FROM ed6_2_customers c;
```
Expected output
```
name | latest
Ava  | 2025-03-01
Noah | 2025-03-02
```
Fix and explanation
```sql
SELECT c.name,
  (SELECT MAX(o.order_date) FROM ed6_2_orders o WHERE o.customer_id = c.customer_id) AS latest
FROM ed6_2_customers c;
-- Add correlation predicate to compute per-customer values.
```

**What Went Wrong:**
The subquery is **not correlated** - it doesn't reference the outer query's customer!

**Broken Query Analysis:**
```sql
SELECT c.name,
  (SELECT MAX(order_date) FROM ed6_2_orders) AS latest  ← Same for EVERYONE!
FROM ed6_2_customers c;
```

**What This Returns:**
```
name | latest
Ava  | 2025-03-02  ← WRONG! Should be 2025-03-01
Noah | 2025-03-02  ← Correct, but only by luck
```

The subquery runs ONCE and returns the global max date (2025-03-02), then uses that same value for ALL customers!

**The Fixed Version:**
```sql
(SELECT MAX(o.order_date) 
 FROM ed6_2_orders o 
 WHERE o.customer_id = c.customer_id)  ← Correlation predicate!
```

**Now It Works Correctly:**
```
For Ava (customer_id=1):
  → Find MAX(order_date) WHERE customer_id=1
  → Returns 2025-03-01 ✓

For Noah (customer_id=2):
  → Find MAX(order_date) WHERE customer_id=2
  → Returns 2025-03-02 ✓
```

**How to Spot This Bug:**
- If all rows show the same value from a "correlated" subquery → missing correlation!
- **Always check**: Does the subquery reference the outer table? (e.g., `WHERE ... = c.customer_id`)

**Testing Tip:**
Add a customer with a very different date to make the bug obvious:
```sql
INSERT INTO ed6_2_orders VALUES (12, 1, '2020-01-01');
-- If Ava still shows 2025-03-02, you know the correlation is broken!
```

---

## ED3) Aggregate in WHERE instead of HAVING (over derived)
Scenario: We want products with revenue > 20 but put SUM in WHERE.

Sample data
```sql
DROP TABLE IF EXISTS ed6_3_products;
CREATE TABLE ed6_3_products (product_id INT PRIMARY KEY, name VARCHAR(60), price DECIMAL(7,2));
INSERT INTO ed6_3_products VALUES (1,'Notebook',4.99),(2,'Lamp',12.00),(3,'Mug',7.99);

DROP TABLE IF EXISTS ed6_3_items;
CREATE TABLE ed6_3_items (order_item_id INT PRIMARY KEY, product_id INT, qty INT);
INSERT INTO ed6_3_items VALUES (1,1,2),(2,2,1),(3,3,2),(4,2,1);
```
Broken query
```sql
SELECT p.name, SUM(i.qty * p.price) AS revenue
FROM ed6_3_items i JOIN ed6_3_products p ON p.product_id = i.product_id
WHERE SUM(i.qty * p.price) > 20 -- invalid
GROUP BY p.name;
```
Expected output
```
name   | revenue
Lamp   | 24.00
Mug    | 15.98 -- should be excluded
Notebook | 9.98 -- should be excluded
```
Fix and explanation
```sql
SELECT p.name, SUM(i.qty * p.price) AS revenue
FROM ed6_3_items i JOIN ed6_3_products p ON p.product_id = i.product_id
GROUP BY p.name
HAVING SUM(i.qty * p.price) > 20;
-- Aggregates belong in HAVING (or filter in an outer query/derived table).
```

**The Error:**
```
ERROR: Invalid use of group function (aggregate in WHERE clause)
```

**Why This Fails:**
SQL processes clauses in this order:
1. **FROM** - Get tables
2. **WHERE** - Filter individual rows (BEFORE grouping!)
3. **GROUP BY** - Group rows
4. **HAVING** - Filter groups (AFTER grouping!)
5. **SELECT** - Choose columns
6. **ORDER BY** - Sort results

You can't use `SUM()` in WHERE because aggregation hasn't happened yet!

**Visual Explanation:**
```sql
-- WRONG: WHERE happens BEFORE grouping
FROM items JOIN products
WHERE SUM(qty * price) > 20  ← ERROR! SUM doesn't exist yet
GROUP BY name
```

```sql
-- CORRECT: HAVING happens AFTER grouping
FROM items JOIN products
GROUP BY name                 ← Groups created
HAVING SUM(qty * price) > 20  ← Now we can filter groups ✓
```

**Rule of Thumb:**
- **WHERE**: Filters individual rows (before GROUP BY)
  - Example: `WHERE price > 10` (filter products)
- **HAVING**: Filters aggregated groups (after GROUP BY)
  - Example: `HAVING SUM(qty) > 100` (filter totals)

**Alternative Using Derived Table:**
```sql
SELECT name, revenue
FROM (
  SELECT p.name, SUM(i.qty * p.price) AS revenue
  FROM ed6_3_items i 
  JOIN ed6_3_products p ON p.product_id = i.product_id
  GROUP BY p.name
) t
WHERE revenue > 20;  ← Can use WHERE here because revenue already exists!
```

**Memory Trick:**
"**WHERE** filters **WHAT** goes into groups"
"**HAVING** filters **HOW MANY** survived grouping"

---

## ED4) CTE column list mismatch
Scenario: CTE defines two columns but SELECT returns three.

Broken query
```sql
WITH bad(cte_col1, cte_col2) AS (
  SELECT 1 AS a, 2 AS b, 3 AS c
)
SELECT * FROM bad;
-- Error: Number of columns in result set of a CTE does not match column list
```
Fix and explanation
```sql
WITH good(cte_col1, cte_col2, cte_col3) AS (
  SELECT 1, 2, 3
)
SELECT * FROM good;
-- CTE column list must match the number of columns returned.
```

**The Error:**
```
ERROR: The number of columns in the CTE definition does not match 
the number of columns returned by the query
```

**What Went Wrong:**
```sql
WITH bad(cte_col1, cte_col2) AS (  ← Declares 2 column names
  SELECT 1, 2, 3                   ← Returns 3 columns!
)
```

This is like trying to fit 3 apples into 2 baskets - it doesn't match!

**The Fix - Option 1: Match Column Count**
```sql
WITH good(cte_col1, cte_col2, cte_col3) AS (  ← 3 names
  SELECT 1, 2, 3                               ← 3 columns ✓
)
```

**The Fix - Option 2: Skip Column List (Let SQL Auto-Name)**
```sql
WITH good AS (
  SELECT 1 AS col1, 2 AS col2, 3 AS col3  ← Name columns in SELECT
)
SELECT * FROM good;
```

**When to Use Explicit Column List:**
```sql
-- Useful when SELECT doesn't have clear names:
WITH summary(category, total, avg_price) AS (
  SELECT category, SUM(price), AVG(price)  ← Without AS aliases
  FROM products
  GROUP BY category
)
```

**When to Skip It:**
```sql
-- Not needed when SELECT has clear names:
WITH summary AS (
  SELECT category, 
         SUM(price) AS total, 
         AVG(price) AS avg_price  ← Already named!
  FROM products
  GROUP BY category
)
```

**Common Mistakes:**
```sql
-- ❌ Forgot one column
WITH bad(name, total) AS (
  SELECT name, price, quantity FROM products  ← 3 columns!
)

-- ❌ Too many names
WITH bad(a, b, c, d) AS (
  SELECT 1, 2, 3  ← Only 3 columns!
)

-- ✅ Perfect match
WITH good(a, b, c) AS (
  SELECT 1, 2, 3  ← Exactly 3 columns ✓
)
```

---

## ED5) Recursive CTE without termination
Scenario: Calendar CTE forgets to stop; leads to infinite recursion or max recursion reached.

Broken query
```sql
WITH RECURSIVE badcal AS (
  SELECT DATE('2025-03-01') AS d
  UNION ALL
  SELECT DATE_ADD(d, INTERVAL 1 DAY)
  FROM badcal
  -- missing WHERE to stop at '2025-03-31'
)
SELECT * FROM badcal;
```
Fix and explanation
```sql
WITH RECURSIVE goodcal AS (
  SELECT DATE('2025-03-01') AS d
  UNION ALL
  SELECT DATE_ADD(d, INTERVAL 1 DAY)
  FROM goodcal
  WHERE d < '2025-03-31'  ← CRITICAL: Stop condition!
)
SELECT * FROM goodcal;
-- Always include a termination predicate in the recursive branch.
```

**The Error:**
```
ERROR: Recursive query aborted after 1001 iterations
(or runs forever until you kill it!)
```

**What Went Wrong:**
```sql
WITH RECURSIVE badcal AS (
  SELECT DATE('2025-03-01') AS d  ← Start: March 1
  UNION ALL
  SELECT DATE_ADD(d, INTERVAL 1 DAY)  ← Add 1 day
  FROM badcal  ← Use previous result... FOREVER! 🔄
  -- Missing WHERE to stop!
)
```

**What Actually Happens:**
```
Iteration 1: 2025-03-01
Iteration 2: 2025-03-02
Iteration 3: 2025-03-03
...
Iteration 1000: 2027-11-26
Iteration 1001: ERROR! MySQL gives up
```

It keeps adding days FOREVER because there's no condition to stop!

**The Fix:**
```sql
WHERE d < '2025-03-31'  ← Stop when we reach March 31
```

**How the Fix Works:**
```
Iteration 1: d = 2025-03-01, check: < 2025-03-31? YES → Continue
Iteration 2: d = 2025-03-02, check: < 2025-03-31? YES → Continue
...
Iteration 30: d = 2025-03-30, check: < 2025-03-31? YES → Continue
Iteration 31: d = 2025-03-31, check: < 2025-03-31? NO → STOP ✓
```

**Recursive CTE Pattern:**
Every recursive CTE needs THREE parts:

1. **Anchor (Base Case)**: Starting point
   ```sql
   SELECT DATE('2025-03-01') AS d
   ```

2. **UNION ALL**: Combines anchor with recursive results
   ```sql
   UNION ALL
   ```

3. **Recursive Case + TERMINATION**: Next step AND when to stop
   ```sql
   SELECT DATE_ADD(d, INTERVAL 1 DAY)
   FROM goodcal
   WHERE d < '2025-03-31'  ← MUST HAVE THIS!
   ```

**Common Termination Patterns:**
```sql
-- Date range
WHERE d < '2025-12-31'

-- Depth limit (org chart)
WHERE level < 10

-- Value threshold
WHERE balance > 0

-- Path tracking (prevent cycles)
WHERE NOT FIND_IN_SET(next_id, path)
```

**Safety Tip:**
Even with termination, add a depth limit for safety:
```sql
WITH RECURSIVE org AS (
  SELECT id, name, 0 AS level FROM employees WHERE manager_id IS NULL
  UNION ALL
  SELECT e.id, e.name, o.level + 1
  FROM employees e JOIN org o ON e.manager_id = o.id
  WHERE o.level < 100  ← Safety valve! Prevents infinite loops from bad data
)
```

**Remember:**
🚨 **Recursive CTEs without termination = Infinite loop!**
✅ **ALWAYS include a WHERE clause in the recursive part**
✅ **Test with LIMIT 10 first** to verify termination works
