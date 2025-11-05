# Error Detective — Window Functions (5 challenges)

**🎯 Learning Goal:** Understand common window function mistakes and how to fix them. Each challenge shows broken code, explains WHY it's wrong, and provides the fix.

---

## Challenge 1: Missing ORDER BY in Window

**❌ Broken Code:**
```sql
SELECT emp_name, salary, ROW_NUMBER() OVER () AS rn 
FROM employees;
```

**🐛 The Error:**
```
ERROR 3587 (HY000): Window function 'ROW_NUMBER' requires ORDER BY in window specification
```

**🤔 Why This Fails:**
- ROW_NUMBER() needs to know WHICH ORDER to assign numbers
- Without ORDER BY, it doesn't know if row #1 should be highest salary, lowest, or random
- Think about it: How can you number items if you don't know the order?

**💡 Key Concept:** 
Some window functions REQUIRE ORDER BY:
- ✅ ROW_NUMBER(), RANK(), DENSE_RANK() - must have ORDER BY
- ✅ LAG(), LEAD() - must have ORDER BY  
- ⚠️ SUM(), AVG(), COUNT() - ORDER BY optional (but affects result with frames!)

**✅ Fixed Code:**
```sql
SELECT 
  emp_name, 
  salary, 
  ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn 
FROM employees;
-- Now it knows: highest salary = row 1, next highest = row 2, etc.
```

**🎓 Beginner Tip:** If you get this error, ask yourself "What order should the rows be in?" and add that to ORDER BY.

---

## Challenge 2: Wrong Frame Specification

**❌ Broken Code:**
```sql
SELECT date, value, 
  SUM(value) OVER (ORDER BY date ROWS 3) AS moving_sum 
FROM metrics;
```

**🐛 The Error:**
```
ERROR 1064 (42000): You have an error in your SQL syntax near 'ROWS 3'
```

**🤔 Why This Fails:**
- `ROWS 3` is incomplete - 3 rows from WHERE?
- MySQL needs you to specify: PRECEDING (before), FOLLOWING (after), or both
- It's like saying "give me 3 items" without saying "before or after what?"

**💡 Key Concept - Frame Specification Syntax:**
```sql
ROWS BETWEEN <start> AND <end>

Valid values for <start> and <end>:
- UNBOUNDED PRECEDING  (from the very first row)
- n PRECEDING          (n rows before current)
- CURRENT ROW          (the current row)
- n FOLLOWING          (n rows after current)
- UNBOUNDED FOLLOWING  (to the very last row)
```

**✅ Fixed Code Options:**

```sql
-- Option 1: 3-row moving sum (current + 2 before)
SELECT date, value, 
  SUM(value) OVER (
    ORDER BY date 
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) AS moving_sum_3
FROM metrics;

-- Option 2: Centered 3-row window (1 before + current + 1 after)
SELECT date, value, 
  SUM(value) OVER (
    ORDER BY date 
    ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
  ) AS centered_sum_3
FROM metrics;

-- Option 3: Running total (from start to current)
SELECT date, value, 
  SUM(value) OVER (
    ORDER BY date 
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_total
FROM metrics;
```

**🎓 Beginner Tip:** For a moving average of N rows, use `(N-1) PRECEDING AND CURRENT ROW`
- 3-day average = `2 PRECEDING AND CURRENT ROW` (2 + 1 = 3 days)
- 7-day average = `6 PRECEDING AND CURRENT ROW` (6 + 1 = 7 days)

---

## Challenge 3: LAG() Without Default Value

**❌ Problematic Code:**
```sql
SELECT 
  month, 
  revenue, 
  LAG(revenue, 1) OVER (ORDER BY month) AS prev_month,
  revenue - LAG(revenue, 1) OVER (ORDER BY month) AS growth
FROM sales;
```

**🐛 The Problem:**
```
month      | revenue | prev_month | growth
2024-01-01 | 10000   | NULL       | NULL    ← Problem: Can't calculate growth!
2024-02-01 | 12000   | 10000      | 2000
```

**🤔 Why This Is Problematic:**
- First row has no "previous" row, so LAG() returns NULL
- NULL in math operations makes the entire result NULL
- `10000 - NULL = NULL` (not 10000!)
- This wastes your first data point in analysis

**💡 Key Concept - LAG/LEAD Parameters:**
```sql
LAG(column, offset, default_value)
     ↑        ↑          ↑
     |        |          └─ What to return when no previous row exists
     |        └─ How many rows back (1 = previous row, 2 = two back, etc.)
     └─ Which column to retrieve
```

**✅ Fixed Code:**

```sql
-- Fix 1: Use 0 as default (treats first month as "baseline")
SELECT 
  month, 
  revenue, 
  LAG(revenue, 1, 0) OVER (ORDER BY month) AS prev_month,
  revenue - LAG(revenue, 1, 0) OVER (ORDER BY month) AS growth
FROM sales;
-- Result: First month shows prev_month = 0, growth = 10000

-- Fix 2: Filter out first row if it's not meaningful
SELECT 
  month, 
  revenue, 
  LAG(revenue, 1) OVER (ORDER BY month) AS prev_month,
  revenue - LAG(revenue, 1) OVER (ORDER BY month) AS growth
FROM sales
HAVING prev_month IS NOT NULL;
-- Result: Only shows rows where we have previous data

-- Fix 3: Use the value itself as default (0% growth)
SELECT 
  month, 
  revenue, 
  LAG(revenue, 1, revenue) OVER (ORDER BY month) AS prev_month,
  revenue - LAG(revenue, 1, revenue) OVER (ORDER BY month) AS growth
FROM sales;
-- Result: First month shows 0 growth (comparing to itself)
```

**🎓 Beginner Tip:** Always use the default parameter in LAG/LEAD to avoid NULL headaches!
- Numbers: Use 0 as default
- Text: Use '' (empty string) as default  
- Or filter out NULLs afterward if first row isn't meaningful

---

## Challenge 4: Mixing GROUP BY with Window Functions

**❌ Broken Code:**
```sql
SELECT dept, AVG(salary) OVER (PARTITION BY dept) AS avg_sal
FROM employees
GROUP BY dept;
```

**🐛 The Error:**
```
ERROR 1140 (42000): In aggregated query without GROUP BY, expression #1 of SELECT list contains 
nonaggregated column; this is incompatible with sql_mode=only_full_group_by
```

**🤔 Why This Fails:**
- **GROUP BY**: Collapses rows (many employees → one row per department)
- **Window Functions**: Preserve all rows (keeps every employee)
- **You can't do both at once!** They have opposite goals!

**💡 Key Concept - When to Use Each:**

| Want This | Use This | Result |
|-----------|----------|--------|
| One row per group | GROUP BY with aggregate | Collapsed rows |
| All rows with group calculation | Window function (PARTITION BY) | All rows preserved |

**✅ Fixed Code Options:**

```sql
-- Fix 1: Want ONE row per department? Use GROUP BY (not window function)
SELECT 
  dept, 
  AVG(salary) AS avg_sal,
  COUNT(*) AS emp_count
FROM employees
GROUP BY dept;
-- Result: One row per dept
-- Sales   | 65000 | 2
-- IT      | 80000 | 3

-- Fix 2: Want EVERY employee with their dept average? Use window function (no GROUP BY)
SELECT 
  emp_name, 
  dept, 
  salary,
  AVG(salary) OVER (PARTITION BY dept) AS dept_avg,
  salary - AVG(salary) OVER (PARTITION BY dept) AS vs_avg
FROM employees;
-- Result: Every employee shown with dept context
-- Alice | Sales | 60000 | 65000 | -5000
-- Bob   | Sales | 70000 | 65000 | 5000
-- Carol | IT    | 80000 | 80000 | 0

-- Fix 3: Want grouped data THEN window functions? Use subquery!
SELECT 
  dept,
  emp_count,
  avg_sal,
  SUM(emp_count) OVER (ORDER BY avg_sal DESC) AS running_total_employees
FROM (
  SELECT dept, COUNT(*) AS emp_count, AVG(salary) AS avg_sal
  FROM employees
  GROUP BY dept
) dept_summary;
-- First GROUP BY (inner query), then window function (outer query)
```

**🎓 Beginner Tip:** 
- **GROUP BY** = "Collapse rows, give me summaries"
- **PARTITION BY** = "Keep all rows, but calculate within groups"
- Can't mix them in the same SELECT! Choose one or use subqueries.

---

## Challenge 5: Using QUALIFY (Version Compatibility Issue)

**❌ Broken Code (MySQL < 8.0.31):**
```sql
SELECT 
  product, 
  sales, 
  ROW_NUMBER() OVER (ORDER BY sales DESC) AS rn
FROM products
QUALIFY rn <= 5;  -- Top 5 products
```

**🐛 The Error:**
```
ERROR 1064 (42000): You have an error in your SQL syntax near 'QUALIFY rn <= 5'
```

**🤔 Why This Fails:**
- `QUALIFY` clause is NEW (MySQL 8.0.31+, released 2022)
- Most MySQL installations are older versions (8.0.30 or earlier)
- QUALIFY lets you filter window function results directly (like WHERE for aggregates)
- Older MySQL doesn't recognize this keyword

**💡 Key Concept - Filtering Window Functions:**

Window functions are calculated AFTER WHERE clause, so this doesn't work:
```sql
-- ❌ WRONG - Window functions not allowed in WHERE
SELECT product, ROW_NUMBER() OVER (ORDER BY sales DESC) AS rn
FROM products
WHERE rn <= 5;  -- ERROR!
```

**Three Ways to Filter Window Functions:**

**✅ Fix 1: Subquery (Works in ALL MySQL 8.0+)**
```sql
SELECT * FROM (
  SELECT 
    product, 
    sales, 
    ROW_NUMBER() OVER (ORDER BY sales DESC) AS rn
  FROM products
) ranked
WHERE rn <= 5;  -- Filter in outer query
-- This is the most compatible approach!
```

**✅ Fix 2: CTE - Common Table Expression (MySQL 8.0+, cleaner)**
```sql
WITH ranked AS (
  SELECT 
    product, 
    sales, 
    ROW_NUMBER() OVER (ORDER BY sales DESC) AS rn
  FROM products
)
SELECT * FROM ranked WHERE rn <= 5;
-- Same as subquery but more readable
```

**✅ Fix 3: QUALIFY (MySQL 8.0.31+ only, newest syntax)**
```sql
SELECT 
  product, 
  sales, 
  ROW_NUMBER() OVER (ORDER BY sales DESC) AS rn
FROM products
QUALIFY rn <= 5;  -- Only works in newest MySQL!
```

**🎓 How to Check Your MySQL Version:**
```sql
SELECT VERSION();
-- If 8.0.31 or higher → QUALIFY works
-- If 8.0.0 to 8.0.30 → Use subquery or CTE
-- If 5.7 or lower → No window functions at all!
```

**💡 Beginner Tip:** 
- **Always use subquery method** for maximum compatibility
- Learn QUALIFY for modern code, but know it won't work everywhere
- Remember: Window functions calculated AFTER WHERE, so need subquery to filter

---

## 🎯 Error Detective Summary

You've learned to fix these common mistakes:

1. **Missing ORDER BY** → Add ORDER BY to ranking/LAG/LEAD functions
2. **Wrong Frame Spec** → Use `ROWS BETWEEN X PRECEDING AND CURRENT ROW`
3. **LAG NULL Issues** → Use default parameter: `LAG(col, 1, 0)`
4. **GROUP BY Confusion** → Don't mix GROUP BY with window functions in same SELECT
5. **QUALIFY Compatibility** → Use subquery for older MySQL versions

**🔑 Key Takeaway:** Most window function errors come from:
- Forgetting required clauses (ORDER BY)
- Mixing concepts (GROUP BY + window functions)
- Version compatibility (QUALIFY)

**Next:** Move to `07-Speed-Drills.md` to test your knowledge!
