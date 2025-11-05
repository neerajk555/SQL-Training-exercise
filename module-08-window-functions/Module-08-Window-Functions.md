# Module 08 · Window Functions

## 🎯 What Are Window Functions?

**Simple Explanation:** Think of window functions like looking through a window at your data. Unlike GROUP BY (which collapses rows), window functions let you "peek" at other rows while keeping all your original rows intact. It's like adding a column that says "here's what I calculated by looking at related rows."

**Real-World Analogy:** Imagine you're in a classroom taking a test. A window function is like:
- Looking at your own score (current row)
- While also seeing the class average (aggregate across all rows)
- Or seeing who ranked above you (comparing to other rows)
- All while everyone keeps their seat (no rows disappear!)

Window functions perform calculations across sets of rows related to the current row, **without collapsing the result set** like GROUP BY does. They're essential for analytics, ranking, and time-series analysis.

## Topics Covered

### 1. Introduction to Window Functions
- **Syntax**: `function_name() OVER (PARTITION BY ... ORDER BY ... ROWS/RANGE ...)`
- **Key Difference from GROUP BY**: Window functions preserve all rows while adding calculated columns
- **OVER Clause**: Defines the window (partition and order) for the calculation
- **Frame Specification**: ROWS or RANGE defines which rows to include in calculation

**🔑 Key Concept:** The `OVER()` clause is what makes a function a "window function". Without it, functions like SUM() or AVG() would collapse your rows (like GROUP BY). With it, you get calculated values added to every row!

```sql
-- Basic window function example
SELECT 
  employee_name,
  salary,
  AVG(salary) OVER () AS company_avg_salary
FROM employees;
-- Every row shows the same company average, but all rows are preserved
-- The empty OVER() means "calculate across ALL rows"
```

**💡 Beginner Tip:** When you see `OVER ()`, read it as "looking OVER all the rows". The parentheses can be empty (all rows) or contain instructions about which rows to look at.

### 2. Ranking Functions

**Think of ranking like a race:** Each function handles "ties" differently!

**ROW_NUMBER()**: Assigns unique sequential numbers (1, 2, 3, ...)
- **Analogy:** Like giving everyone a unique bib number in a race, even if they finish at the same time
- **Use when:** You need every row to have a different number (breaking ties arbitrarily)
```sql
SELECT 
  product_name,
  sales,
  ROW_NUMBER() OVER (ORDER BY sales DESC) AS row_num
FROM products;
```

**RANK()**: Assigns ranks with gaps after ties (1, 2, 2, 4, ...)
- **Analogy:** Olympic medals - if two people tie for silver, the next person gets bronze (position 4), not another silver
- **Use when:** Ties matter, and you want to show how many people ranked higher
```sql
SELECT 
  student_name,
  score,
  RANK() OVER (ORDER BY score DESC) AS rank
FROM exam_scores;
-- Two students with same score get rank 2, next gets rank 4 (gap for tie)
```

**DENSE_RANK()**: Assigns ranks without gaps (1, 2, 2, 3, ...)
- **Analogy:** Video game leaderboard - if two players tie for 2nd place, the next player is 3rd (no gap)
- **Use when:** You want consecutive rank numbers even with ties
```sql
SELECT 
  student_name,
  score,
  DENSE_RANK() OVER (ORDER BY score DESC) AS dense_rank
FROM exam_scores;
-- Two students with same score get rank 2, next gets rank 3 (no gap)
```

**NTILE(n)**: Divides rows into n roughly equal buckets
- **Analogy:** Dividing a class into 4 equal study groups (quartiles)
- **Use when:** You want to split data into percentiles or quartiles
```sql
SELECT 
  customer_name,
  total_purchases,
  NTILE(4) OVER (ORDER BY total_purchases DESC) AS quartile
FROM customers;
-- Quartile 1 = top 25%, 2 = next 25%, etc.
```

### 3. PARTITION BY (Grouping Within Windows)

**Simple Explanation:** `PARTITION BY` is like creating separate "mini-windows" within your data. Each group gets its own calculation, but all rows stay visible!

**Analogy:** Think of a school with multiple classrooms:
- Without PARTITION BY: You rank ALL students in the entire school
- With PARTITION BY grade: You rank students separately within each grade (1st graders compete with 1st graders, 2nd with 2nd, etc.)

Divides the result set into partitions, and the window function is applied separately to each partition.

```sql
-- Rank employees within each department
SELECT 
  department,
  employee_name,
  salary,
  RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank
FROM employees;
-- Rankings restart at 1 for each department
-- So you get "best in Sales", "best in IT", etc.
```

**💡 Beginner Tip:** `PARTITION BY` is optional. If you leave it out, the function looks at ALL rows. If you include it, the function "resets" for each group.

### 4. Aggregate Window Functions

**Simple Explanation:** You already know SUM(), AVG(), COUNT(), MIN(), MAX(). Add `OVER()` to make them window functions that keep all your rows!

**Analogy:** 
- Regular SUM(): Like getting ONE total for your entire shopping cart
- Window SUM(): Like seeing a running total as you add each item (all items still visible!)

SUM(), AVG(), COUNT(), MIN(), MAX() can be used as window functions.

```sql
-- Running total (cumulative sum)
-- Think: "What's my total spent so far?" after each purchase
SELECT 
  order_date,
  amount,
  SUM(amount) OVER (ORDER BY order_date 
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM orders;
-- UNBOUNDED PRECEDING = "from the very first row"
-- CURRENT ROW = "up to this row"

-- Department average
-- Think: "How does my salary compare to my department's average?"
SELECT 
  employee_name,
  department,
  salary,
  AVG(salary) OVER (PARTITION BY department) AS dept_avg,
  salary - AVG(salary) OVER (PARTITION BY department) AS difference_from_avg
FROM employees;
```

**💡 MySQL Note:** Running totals can also be written more simply as:
```sql
SUM(amount) OVER (ORDER BY order_date) AS running_total
-- MySQL assumes RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
```

### 5. LAG() and LEAD() - Time Travel for Your Data!

**Simple Explanation:** LAG() looks backward at previous rows, LEAD() looks forward at upcoming rows. No complex self-joins needed!

**Analogy:** 
- **LAG()**: Like looking at yesterday's temperature to compare with today
- **LEAD()**: Like checking tomorrow's forecast to plan ahead

**LAG(column, offset, default)**: Look backwards
- **column**: What value do you want to retrieve?
- **offset**: How many rows back? (1 = previous row, 2 = two rows back)
- **default**: What to show if there's no previous row? (like the first row)

```sql
-- Month-over-month comparison
SELECT 
  month,
  revenue,
  LAG(revenue, 1, 0) OVER (ORDER BY month) AS previous_month_revenue,
  revenue - LAG(revenue, 1, 0) OVER (ORDER BY month) AS month_over_month_change
FROM monthly_sales;
-- First month has no previous, so LAG returns 0 (our default)
```

**LEAD(column, offset, default)**: Look forward
- Same parameters, but looks AHEAD instead of behind
- Useful for "gap analysis" - how long until the next event?

```sql
-- When will the next order arrive?
SELECT 
  order_id,
  order_date,
  LEAD(order_date, 1) OVER (ORDER BY order_date) AS next_order_date,
  DATEDIFF(LEAD(order_date, 1) OVER (ORDER BY order_date), order_date) AS days_until_next_order
FROM orders;
-- Last order has no "next", so LEAD returns NULL
```

**💡 Beginner Tip:** Always use the default parameter (3rd argument) to avoid NULL errors in calculations. Common defaults: 0 for numbers, empty string for text.

### 6. Frame Specifications (ROWS vs RANGE) - Defining Your Window Size

**Simple Explanation:** Frame specifications tell the window function "which rows should I include in my calculation?" Think of it like adjusting the size of your viewing window.

**Analogy:** Imagine a sliding window on a train:
- **ROWS**: Count by physical seats (3 seats = 3 people, regardless of who they are)
- **RANGE**: Count by ticket type (all business class passengers together, even if 5 of them)

**ROWS**: Physical row count (most common for moving averages)
```sql
-- Moving average of last 3 rows (including current row)
-- Think: "Average of today + previous 2 days"
SELECT 
  date,
  value,
  AVG(value) OVER (ORDER BY date 
                   ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3
FROM metrics;
-- Always looks at exactly 3 rows (or less if at start of data)
```

**RANGE**: Logical value range (handles ties together)
```sql
-- Sum of all rows with same date (handles multiple transactions per day)
SELECT 
  date,
  amount,
  SUM(amount) OVER (ORDER BY date 
                    RANGE BETWEEN CURRENT ROW AND CURRENT ROW) AS daily_total
FROM transactions;
-- Groups all rows with same date value together
```

**Frame Options Explained:**
- `UNBOUNDED PRECEDING`: Start from the very first row (beginning of data)
- `UNBOUNDED FOLLOWING`: Go to the very last row (end of data)
- `CURRENT ROW`: The row you're currently on
- `n PRECEDING`: Go back n rows (e.g., 2 PRECEDING = 2 rows before)
- `n FOLLOWING`: Go forward n rows (e.g., 1 FOLLOWING = next row)

**Common Patterns:**
```sql
-- Running total (from start to current)
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

-- Moving average (last 7 days)
ROWS BETWEEN 6 PRECEDING AND CURRENT ROW  -- 6 + current = 7 total

-- Centered moving average (3 days: before, current, after)
ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
```

**💡 Beginner Tip:** Start with ROWS (easier to understand). Use RANGE only when you need to handle duplicate values in your ORDER BY column.

### 7. Common Use Cases
**1. Top N per Category:**
```sql
SELECT * FROM (
  SELECT 
    category,
    product_name,
    sales,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
  FROM products
) ranked
WHERE rn <= 3;
```

**2. Year-over-Year Comparison:**
```sql
SELECT 
  year,
  revenue,
  LAG(revenue, 1) OVER (ORDER BY year) AS prev_year,
  ROUND((revenue - LAG(revenue, 1) OVER (ORDER BY year)) / LAG(revenue, 1) OVER (ORDER BY year) * 100, 2) AS yoy_growth_pct
FROM annual_revenue;
```

**3. Cumulative Distribution:**
```sql
SELECT 
  salary,
  PERCENT_RANK() OVER (ORDER BY salary) AS percentile,
  CUME_DIST() OVER (ORDER BY salary) AS cumulative_dist
FROM employees;
```

**4. Gap Detection:**
```sql
SELECT 
  transaction_id,
  transaction_date,
  LAG(transaction_date) OVER (ORDER BY transaction_date) AS prev_date,
  DATEDIFF(transaction_date, LAG(transaction_date) OVER (ORDER BY transaction_date)) AS days_gap
FROM transactions
HAVING days_gap > 7;  -- Find gaps > 7 days
```

### 8. Performance Considerations (Important for Real-World Use!)

**Simple Explanation:** Window functions are powerful but can be slow on large datasets. Here's how to keep them fast:

**Performance Tips:**
1. **Index your partition/order columns**: If you use `PARTITION BY department ORDER BY salary`, create indexes on both columns
2. **ROWS is faster than RANGE**: When possible, use ROWS (it counts physically, no value comparison needed)
3. **Limit your data first**: Filter with WHERE before applying window functions
4. **Avoid multiple OVER clauses**: Reuse window definitions when possible

```sql
-- ❌ SLOWER: Multiple identical OVER clauses
SELECT 
  name,
  AVG(salary) OVER (PARTITION BY dept ORDER BY hire_date),
  SUM(salary) OVER (PARTITION BY dept ORDER BY hire_date)
FROM employees;

-- ✅ FASTER: Define window once (MySQL 8.0+)
SELECT 
  name,
  AVG(salary) OVER w,
  SUM(salary) OVER w
FROM employees
WINDOW w AS (PARTITION BY dept ORDER BY hire_date);
```

**💡 Beginner Tip:** For learning, don't worry about performance. Once your queries work correctly, THEN optimize if they're slow.

## MySQL Version Compatibility

**MySQL 8.0+** supports all window functions discussed in this module.

**Key Features by Version:**
- **MySQL 5.7 and earlier**: ❌ No window functions (must use subqueries/self-joins)
- **MySQL 8.0.0+**: ✅ All window functions (ROW_NUMBER, RANK, LAG, LEAD, etc.)
- **MySQL 8.0.11+**: ✅ Named window definitions (WINDOW clause)
- **MySQL 8.0.31+**: ✅ QUALIFY clause (filter window function results directly)

**For MySQL < 8.0.31 (most installations):**
```sql
-- ❌ QUALIFY not supported
SELECT product, sales, ROW_NUMBER() OVER (ORDER BY sales DESC) AS rn
FROM products
QUALIFY rn <= 5;

-- ✅ Use subquery instead
SELECT * FROM (
  SELECT product, sales, ROW_NUMBER() OVER (ORDER BY sales DESC) AS rn
  FROM products
) ranked
WHERE rn <= 5;
```

## Syntax Summary

```sql
-- Basic ranking
ROW_NUMBER() OVER (ORDER BY column)
RANK() OVER (ORDER BY column)
DENSE_RANK() OVER (ORDER BY column)

-- With partitioning
RANK() OVER (PARTITION BY category ORDER BY value DESC)

-- Aggregates with windows
SUM(amount) OVER (PARTITION BY dept ORDER BY date)
AVG(score) OVER ()

-- Lag/Lead
LAG(column, offset, default) OVER (ORDER BY date)
LEAD(column, offset, default) OVER (ORDER BY date)

-- Frame specification
SUM(value) OVER (ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
```

## Practice Strategy
1. Start with simple ROW_NUMBER() and RANK()
2. Practice PARTITION BY for grouped analytics
3. Master LAG/LEAD for time-series comparisons
4. Learn frame specifications for moving averages
5. Combine multiple window functions in one query

**Remember:** Window functions don't reduce rows—they augment them! This makes them perfect for analytics dashboards and reports.
