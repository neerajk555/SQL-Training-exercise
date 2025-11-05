# Independent Practice — Window Functions

## 📋 Before You Start

### Learning Objectives
Through independent practice, you will:
- Apply window functions without step-by-step guidance
- Choose appropriate ranking functions (ROW_NUMBER, RANK, DENSE_RANK)
- Calculate running totals and moving averages
- Use LAG/LEAD for row comparisons
- Solve top-N per group problems

### Difficulty Progression
- 🟢 **Easy (1-2)**: Basic rankings and running totals, 12-13 minutes
- 🟡 **Medium (3-5)**: Moving averages, LAG/LEAD, top-N patterns, 18-22 minutes
- 🔴 **Challenge (6-7)**: Complex window frames, multiple functions, 25-30 minutes

### Problem-Solving Strategy
1. **READ** requirements—identify if window function is needed
2. **SETUP** sample data
3. **PLAN** your window function:
   - What calculation? (ROW_NUMBER, SUM, AVG, LAG, etc.)
   - PARTITION BY? (group separately by category, etc.)
   - ORDER BY? (defines sequence)
   - Frame? (for moving averages: ROWS BETWEEN...)
4. **TRY** solving independently
5. **TEST** results
6. **REVIEW** solution

**Common Pitfalls:**
- ❌ Using GROUP BY when you need window function (GROUP BY reduces rows)
- ❌ Wrong ORDER BY in OVER clause (affects ranking/frame)
- ❌ Forgetting PARTITION BY when you need separate groups
- ✅ Test window functions on small datasets first!

---

## Exercise 1: Sales Ranking 🟢 Easy (12 min)

**🎯 Business Problem:** Your sales manager wants to see how each salesperson ranks within their own region (North vs South regions compete separately).

**💡 What You Need:** 
- Rank function (RANK or ROW_NUMBER)
- Separate rankings per region (PARTITION BY)
- Highest sales = rank 1

**🤔 Before You Look at the Solution:**
1. Do you need PARTITION BY? (Hint: "within each region" = yes!)
2. What should ORDER BY be? (Hint: highest sales first)
3. RANK() or ROW_NUMBER()? (Either works since no ties)

Schema:
```sql
DROP TABLE IF EXISTS ip8_sales;
CREATE TABLE ip8_sales (salesperson VARCHAR(60), region VARCHAR(30), total_sales DECIMAL(10,2));
INSERT INTO ip8_sales VALUES ('Alice','North',50000),('Bob','South',45000),('Carol','North',55000),('Dave','South',60000);
```

**Task:** Rank salespeople within each region by total sales.

**Expected Output:**
```
salesperson | region | total_sales | region_rank
Carol       | North  | 55000       | 1          ← Best in North
Alice       | North  | 50000       | 2          ← Second in North
Dave        | South  | 60000       | 1          ← Best in South
Bob         | South  | 45000       | 2          ← Second in South
```

<details>
<summary>💡 Hint (click to expand)</summary>

You need:
- `PARTITION BY region` to create separate rankings
- `ORDER BY total_sales DESC` to rank highest first
- Choose RANK() or ROW_NUMBER() (both work here)
</details>

<details>
<summary>✅ Solution (try first before looking!)</summary>

```sql
SELECT 
  salesperson, 
  region, 
  total_sales,
  RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS region_rank
FROM ip8_sales
ORDER BY region, region_rank;
```

**Why this works:**
- `PARTITION BY region`: Separate rankings for North and South
- `ORDER BY total_sales DESC`: Highest sales = rank 1
- Rankings restart at 1 for each region
</details>

## Exercise 2: Running Total 🟢 Easy (13 min)

**🎯 Business Problem:** Show cumulative (running) sales total over time to track progress toward monthly goals.

**💡 What You Need:** 
- Aggregate function (SUM)
- ORDER BY date (chronological)
- Running total (not grouped)

**🤔 Before You Look at the Solution:**
1. Do you need PARTITION BY? (Hint: No - we want ONE running total across all days)
2. What goes in ORDER BY? (Hint: dates, chronological order)
3. Need a frame specification? (Hint: Optional - MySQL defaults to running total)

**Create your own test data:**
```sql
DROP TABLE IF EXISTS ip8_daily_sales;
CREATE TABLE ip8_daily_sales (sale_date DATE, amount DECIMAL(10,2));
INSERT INTO ip8_daily_sales VALUES 
  ('2025-03-01', 100),
  ('2025-03-02', 250),
  ('2025-03-03', 180),
  ('2025-03-04', 300);
```

**Task:** Calculate cumulative sales total by date.

**Expected Output:**
```
sale_date  | amount | cumulative_total
2025-03-01 | 100    | 100              ← Day 1 total
2025-03-02 | 250    | 350              ← Day 1 + Day 2
2025-03-03 | 180    | 530              ← Sum of first 3 days
2025-03-04 | 300    | 830              ← Sum of all 4 days
```

<details>
<summary>💡 Hint (click to expand)</summary>

Use SUM() with OVER():
- ORDER BY sale_date (process in order)
- No PARTITION BY needed (one running total)
- MySQL automatically does RANGE UNBOUNDED PRECEDING to CURRENT ROW
</details>

<details>
<summary>✅ Solution (try first before looking!)</summary>

```sql
-- Simple version (MySQL default behavior)
SELECT 
  sale_date, 
  amount,
  SUM(amount) OVER (ORDER BY sale_date) AS cumulative_total
FROM ip8_daily_sales;

-- Explicit version (same result, more verbose)
SELECT 
  sale_date, 
  amount,
  SUM(amount) OVER (
    ORDER BY sale_date 
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cumulative_total
FROM ip8_daily_sales;
```

**Why this works:**
- `SUM(amount)`: Adds up the amounts
- `OVER (ORDER BY sale_date)`: Process rows chronologically
- Each row shows total from start to current row
- No PARTITION BY = one continuous total
</details>

## Exercise 3: Month-over-Month Growth 🟡 Medium (18 min)

**🎯 Business Problem:** Calculate month-over-month revenue growth percentage to identify trends (growth or decline).

**💡 What You Need:** 
- LAG() to get previous month's revenue
- Math: (current - previous) / previous * 100
- Handle NULL for first month

**🤔 Before You Look at the Solution:**
1. How do you access previous row? (Hint: LAG function)
2. What's the growth formula? (Hint: (new - old) / old * 100)
3. What about the first month? (Hint: LAG returns NULL, handle it!)

**Create your own test data:**
```sql
DROP TABLE IF EXISTS ip8_monthly_revenue;
CREATE TABLE ip8_monthly_revenue (month DATE, revenue DECIMAL(10,2));
INSERT INTO ip8_monthly_revenue VALUES 
  ('2025-01-01', 10000),
  ('2025-02-01', 12000),  -- +20% growth
  ('2025-03-01', 11000),  -- -8.33% decline
  ('2025-04-01', 13000);  -- +18.18% growth
```

**Task:** Calculate month-over-month growth percentage.

**Expected Output:**
```
month      | revenue | prev_month | pct_change
2025-01-01 | 10000   | NULL       | NULL        ← No previous month
2025-02-01 | 12000   | 10000      | 20.00       ← +20% growth
2025-03-01 | 11000   | 12000      | -8.33       ← -8.33% decline
2025-04-01 | 13000   | 11000      | 18.18       ← +18.18% growth
```

<details>
<summary>💡 Hint (click to expand)</summary>

Growth formula: ((current - previous) / previous) * 100
- Use LAG(revenue, 1) to get previous month
- ORDER BY month (chronological)
- Use ROUND() for clean percentages
- First month will show NULL (no previous data)
</details>

<details>
<summary>✅ Solution (try first before looking!)</summary>

```sql
SELECT 
  month, 
  revenue,
  LAG(revenue, 1) OVER (ORDER BY month) AS prev_month,
  ROUND(
    (revenue - LAG(revenue, 1) OVER (ORDER BY month)) / 
    LAG(revenue, 1) OVER (ORDER BY month) * 100, 
    2
  ) AS pct_change
FROM ip8_monthly_revenue;
```

**Why this works:**
- `LAG(revenue, 1)`: Gets previous month's revenue
- `OVER (ORDER BY month)`: Looks back in chronological order
- Division by previous month gives ratio
- Multiply by 100 for percentage
- ROUND(..., 2) gives 2 decimal places

**💡 Pro Tip:** To avoid dividing by NULL:
```sql
ROUND(
  (revenue - LAG(revenue, 1, 0) OVER (ORDER BY month)) / 
  NULLIF(LAG(revenue, 1, 0) OVER (ORDER BY month), 0) * 100, 
  2
) AS pct_change
```
</details>

## Exercise 4: Top 3 Per Department 🟡 Medium (20 min)

**🎯 Business Problem:** HR wants to identify the top 3 highest-paid employees in each department for a compensation review.

**💡 What You Need:** 
- Ranking per department (PARTITION BY)
- Filter to top 3 (subquery or CTE)
- ROW_NUMBER() or RANK()

**🤔 Before You Look at the Solution:**
1. Can you filter window functions directly in WHERE? (Hint: NO! Need subquery or CTE)
2. Do you need PARTITION BY? (Hint: YES - separate rankings per department)
3. How to keep only top 3? (Hint: WHERE rn <= 3 in outer query)

**Create your own test data:**
```sql
DROP TABLE IF EXISTS ip8_employees;
CREATE TABLE ip8_employees (emp_name VARCHAR(60), dept VARCHAR(30), salary DECIMAL(10,2));
INSERT INTO ip8_employees VALUES 
  ('Alice', 'Sales', 60000),
  ('Bob', 'Sales', 70000),
  ('Carol', 'Sales', 65000),
  ('Dave', 'IT', 85000),
  ('Eve', 'IT', 90000),
  ('Frank', 'IT', 80000),
  ('Grace', 'IT', 88000);
```

**Task:** Find the top 3 highest-paid employees in each department.

**Expected Output:**
```
emp_name | dept  | salary | rn
Eve      | IT    | 90000  | 1  ← Top 3 in IT
Grace    | IT    | 88000  | 2
Dave     | IT    | 85000  | 3
Bob      | Sales | 70000  | 1  ← Top 3 in Sales
Carol    | Sales | 65000  | 2
Alice    | Sales | 60000  | 3
```

<details>
<summary>💡 Hint (click to expand)</summary>

The "Top N per Group" pattern:
1. Calculate rankings with PARTITION BY in a subquery/CTE
2. Filter WHERE rn <= 3 in outer query
3. Can't filter window functions in WHERE directly!
</details>

<details>
<summary>✅ Solution (try first before looking!)</summary>

**Method 1: Using CTE (Common Table Expression - cleaner)**
```sql
WITH ranked AS (
  SELECT 
    emp_name, 
    dept, 
    salary,
    ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary DESC) AS rn
  FROM ip8_employees
)
SELECT emp_name, dept, salary, rn 
FROM ranked 
WHERE rn <= 3
ORDER BY dept, rn;
```

**Method 2: Using Subquery (same result)**
```sql
SELECT * FROM (
  SELECT 
    emp_name, 
    dept, 
    salary,
    ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary DESC) AS rn
  FROM ip8_employees
) ranked
WHERE rn <= 3
ORDER BY dept, rn;
```

**Method 3: MySQL 8.0.31+ with QUALIFY (newest syntax)**
```sql
SELECT 
  emp_name, 
  dept, 
  salary,
  ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary DESC) AS rn
FROM ip8_employees
QUALIFY rn <= 3  -- Filters window function directly (newer MySQL only)
ORDER BY dept, rn;
```

**Why this works:**
- `PARTITION BY dept`: Separate rankings for each department
- `ORDER BY salary DESC`: Highest salary = rank 1
- Window functions calculated FIRST, THEN filtered in outer query
- Each department gets its own top 3

**🎓 Key Lesson:** You CANNOT do this:
```sql
-- ❌ THIS DOESN'T WORK - can't filter window function in WHERE
SELECT emp_name, dept, salary,
  ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary DESC) AS rn
FROM ip8_employees
WHERE rn <= 3;  -- ERROR! Window functions not allowed in WHERE
```
</details>

## Exercise 5: Moving Average 🟡 Medium (22 min)

**🎯 Business Problem:** Calculate a 7-day moving average of website visits to identify trends without daily volatility.

**💡 What You Need:** 
- AVG() with window frame
- ROWS BETWEEN ... (7 days = current + 6 preceding)
- ORDER BY date

**🤔 Before You Look at the Solution:**
1. How many rows in a 7-day window? (Hint: Current + 6 preceding = 7 total)
2. What's the frame specification? (Hint: ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
3. What happens for the first 6 days? (Hint: Fewer than 7 days available)

**Create your own test data:**
```sql
DROP TABLE IF EXISTS ip8_daily_visits;
CREATE TABLE ip8_daily_visits (visit_date DATE, visits INT);
INSERT INTO ip8_daily_visits VALUES 
  ('2025-03-01', 100), ('2025-03-02', 150), ('2025-03-03', 120),
  ('2025-03-04', 180), ('2025-03-05', 160), ('2025-03-06', 140),
  ('2025-03-07', 200), ('2025-03-08', 190), ('2025-03-09', 170);
```

**Task:** Calculate 7-day moving average of visits.

<details>
<summary>💡 Hint (click to expand)</summary>

For 7-day average:
- Use `6 PRECEDING` (not 7!) because it includes current row
- 6 preceding + current = 7 days total
- Early days will use fewer days (not enough data yet)
</details>

<details>
<summary>✅ Solution (try first before looking!)</summary>

```sql
SELECT 
  visit_date, 
  visits,
  AVG(visits) OVER (
    ORDER BY visit_date 
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) AS moving_avg_7day,
  ROUND(AVG(visits) OVER (
    ORDER BY visit_date 
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ), 1) AS moving_avg_rounded
FROM ip8_daily_visits;
```

**Why this works:**
- `6 PRECEDING + CURRENT ROW` = 7 days
- Window "slides" forward each day
- First 6 days use fewer than 7 days (not enough history)
- From day 7 onward, always uses exactly 7 days

**Visual explanation:**
```
Day 1: [100]                               → Avg = 100
Day 2: [100, 150]                          → Avg = 125
Day 7: [100,150,120,180,160,140,200]       → Avg = 150 (first full 7-day window)
Day 8: [150,120,180,160,140,200,190]       → Window slides (drops Day 1, adds Day 8)
```
</details>

---

## Exercise 6: Quartile Analysis 🟡 Medium (24 min)

**🎯 Business Problem:** Divide customers into 4 equal groups (quartiles) based on purchase amounts for targeted marketing.

**💡 What You Need:** 
- NTILE(4) function (divides into 4 groups)
- ORDER BY purchase amount (highest to lowest)

**🤔 Before You Look at the Solution:**
1. What does NTILE(4) do? (Hint: Divides rows into 4 roughly equal buckets)
2. Quartile 1 = top 25% or bottom 25%? (Hint: Depends on ORDER BY direction!)
3. What if rows don't divide evenly? (Hint: MySQL distributes remainder)

**Create your own test data:**
```sql
DROP TABLE IF EXISTS ip8_customers;
CREATE TABLE ip8_customers (customer_id INT, total_purchases DECIMAL(10,2));
INSERT INTO ip8_customers VALUES 
  (1, 5000), (2, 8000), (3, 3000), (4, 12000),
  (5, 6000), (6, 9000), (7, 4000), (8, 10000);
```

**Task:** Divide customers into quartiles (Q1 = top 25% spenders, Q4 = bottom 25%).

**Expected Output:**
```
customer_id | total_purchases | quartile
4           | 12000           | 1        ← Top 25% (highest spenders)
8           | 10000           | 1
6           | 9000            | 2        ← Second quartile
2           | 8000            | 2
5           | 6000            | 3        ← Third quartile
1           | 5000            | 3
7           | 4000            | 4        ← Bottom 25% (lowest spenders)
3           | 3000            | 4
```

<details>
<summary>💡 Hint (click to expand)</summary>

- NTILE(4) divides into 4 groups
- ORDER BY DESC: Quartile 1 = highest values
- ORDER BY ASC: Quartile 1 = lowest values
- With 8 rows: 2 per quartile (perfect split!)
</details>

<details>
<summary>✅ Solution (try first before looking!)</summary>

```sql
SELECT 
  customer_id, 
  total_purchases,
  NTILE(4) OVER (ORDER BY total_purchases DESC) AS quartile
FROM ip8_customers
ORDER BY quartile, total_purchases DESC;
```

**Why this works:**
- `NTILE(4)`: Divides rows into 4 equal (or nearly equal) groups
- `ORDER BY total_purchases DESC`: Highest purchases get Q1
- 8 rows ÷ 4 = 2 customers per quartile

**What if uneven?** (e.g., 10 customers)
```
10 rows ÷ 4 = 2 remainder 2
Result: Q1 gets 3, Q2 gets 3, Q3 gets 2, Q4 gets 2
(extra rows distributed to first quartiles)
```

**🎓 Business Use Cases:**
- Q1 (top 25%): VIP treatment, premium offers
- Q2-Q3 (middle 50%): Standard marketing
- Q4 (bottom 25%): Re-engagement campaigns
</details>

---

**✅ Congratulations!** You've completed independent practice exercises covering:
- Regional rankings (PARTITION BY)
- Running totals (cumulative sums)
- Growth calculations (LAG)
- Top N per group (subquery pattern)
- Moving averages (frame specifications)
- Quartile analysis (NTILE)

**Next:** Move to `04-Paired-Programming.md` for collaborative practice!

## Exercise 7: Complex Time Series 🔴 Challenge (35 min)
Combine multiple window functions for comprehensive analysis.
Solution:
```sql
SELECT date, metric_value,
  AVG(metric_value) OVER (ORDER BY date ROWS 6 PRECEDING) AS moving_avg,
  LAG(metric_value, 1) OVER (ORDER BY date) AS prev_value,
  LEAD(metric_value, 1) OVER (ORDER BY date) AS next_value,
  RANK() OVER (ORDER BY metric_value DESC) AS overall_rank
FROM metrics;
```

**Next:** Move to `04-Paired-Programming.md`
