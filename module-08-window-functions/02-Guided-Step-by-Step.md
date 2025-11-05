# Guided Step-by-Step — Window Functions (15–20 min each)

## 📋 Before You Start

### Learning Objectives
Through these guided activities, you will:
- Use ROW_NUMBER() and RANK() for top-N per group
- Calculate moving averages with window frames
- Compare values across rows with LAG() and LEAD()
- Understand PARTITION BY for grouped calculations
- Master window frame specifications (ROWS/RANGE)

### Critical Window Function Concepts
**Window Frame Specifications:**
- `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`: Last 3 rows physically
- `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`: Running total
- Frame defines which rows are included in aggregate calculation

**Top-N Per Group Pattern:**
1. Use ROW_NUMBER() or RANK() with PARTITION BY
2. Wrap in subquery or CTE
3. Filter WHERE row_number <= N

**Execution Process:**
1. **Run complete setup**
2. **Follow steps** building query incrementally
3. **Verify results** at each checkpoint
4. **Study complete solution**

---

## Activity 1: Top Products Per Category (15 min)

**🎯 Business Context:** Your manager wants to see the top 3 best-selling products in EACH category for a sales report. Not just the top 3 overall - the top 3 per category!

**💡 Real-World Use:** E-commerce sites showing "Top Sellers in Electronics", "Top Sellers in Books", etc.

**🧩 The Challenge:** We need to:
1. Rank products within each category (not across all categories)
2. Keep only the top 3 from each category
3. Make sure rankings restart for each new category

Setup:
```sql
DROP TABLE IF EXISTS gs8_products;
CREATE TABLE gs8_products (product_id INT, product_name VARCHAR(60), category VARCHAR(40), monthly_sales DECIMAL(10,2));
INSERT INTO gs8_products VALUES 
(1,'Laptop','Electronics',15000),(2,'Mouse','Electronics',2000),(3,'Keyboard','Electronics',3000),
(4,'Desk','Furniture',5000),(5,'Chair','Furniture',8000),(6,'Lamp','Furniture',1500),
(7,'Notebook','Stationery',500),(8,'Pen','Stationery',200);
```

**📝 Step-by-Step Approach:**

**Step 1:** First, let's see ALL products with their category ranks
```sql
-- Run this first to understand the ranking
SELECT 
  category, 
  product_name, 
  monthly_sales, 
  ROW_NUMBER() OVER (PARTITION BY category ORDER BY monthly_sales DESC) AS rank_in_category
FROM gs8_products
ORDER BY category, rank_in_category;
```
**What you'll see:** Each category has its own ranking (1, 2, 3...) starting from the highest sales.

**Step 2:** Now filter to keep only top 3 per category

**For MySQL 8.0.31+** (if you have the QUALIFY clause):
```sql
SELECT category, product_name, monthly_sales, 
  ROW_NUMBER() OVER (PARTITION BY category ORDER BY monthly_sales DESC) AS rank_in_category
FROM gs8_products
QUALIFY rank_in_category <= 3  -- Filters based on window function result
ORDER BY category, rank_in_category;
```

**For MySQL 8.0 to 8.0.30** (most common - use subquery):
```sql
SELECT * FROM (
  SELECT 
    category, 
    product_name, 
    monthly_sales, 
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY monthly_sales DESC) AS rank_in_category
  FROM gs8_products
) ranked
WHERE rank_in_category <= 3  -- Filter in outer query
ORDER BY category, rank_in_category;
```

**Expected Results:**
```
category     | product_name | monthly_sales | rank_in_category
Electronics  | Laptop       | 15000         | 1
Electronics  | Keyboard     | 3000          | 2
Electronics  | Mouse        | 2000          | 3
Furniture    | Chair        | 8000          | 1
Furniture    | Desk         | 5000          | 2
Furniture    | Lamp         | 1500          | 3
Stationery   | Notebook     | 500           | 1
Stationery   | Pen          | 200           | 2
```

**🔍 What Just Happened?**
- `PARTITION BY category`: Creates separate rankings for Electronics, Furniture, and Stationery
- `ORDER BY monthly_sales DESC`: Within each category, highest sales = rank 1
- Subquery: We calculate ranks first, THEN filter (can't filter window functions directly in WHERE without subquery)

**💡 Beginner Tip:** The "Top N per Group" pattern is SUPER common in business reports. Master this subquery technique!

## Activity 2: Running Average (17 min)

**🎯 Business Context:** Your CFO wants to smooth out monthly revenue fluctuations by looking at 3-month moving averages. This helps identify trends without being distracted by single-month spikes or dips.

**💡 Real-World Use:** Stock market charts, sales trend analysis, weather forecasts - anywhere you want to "smooth out" spiky data!

**🧩 The Challenge:** For each month, calculate the average revenue of:
- The current month
- The previous month
- The month before that
This "window" slides forward one month at a time.

Setup:
```sql
DROP TABLE IF EXISTS gs8_monthly_sales;
CREATE TABLE gs8_monthly_sales (month DATE, revenue DECIMAL(12,2));
INSERT INTO gs8_monthly_sales VALUES 
('2025-01-01',10000),('2025-02-01',12000),('2025-03-01',11000),
('2025-04-01',13000),('2025-05-01',14500),('2025-06-01',15000);
```

**📝 Step-by-Step Approach:**

**Step 1:** Let's understand the frame specification
```
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW means:
- 2 PRECEDING: Go back 2 rows
- CURRENT ROW: Include the current row
- Total: Current + 2 before = 3 rows (a 3-month window!)
```

**Step 2:** Let's visualize what happens for each row:
```
January:   Only 1 row available → Average of (10000) = 10,000
February:  Only 2 rows available → Average of (10000, 12000) = 11,000
March:     3 rows available → Average of (10000, 12000, 11000) = 11,000
April:     3 rows → Average of (12000, 11000, 13000) = 12,000
May:       3 rows → Average of (11000, 13000, 14500) = 12,833
June:      3 rows → Average of (13000, 14500, 15000) = 14,167
```

**Step 3:** Run the complete solution
```sql
SELECT 
  month, 
  revenue,
  AVG(revenue) OVER (
    ORDER BY month                           -- Process in chronological order
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW -- Include current + 2 previous months
  ) AS moving_avg_3mo
FROM gs8_monthly_sales;
```

**Expected Results:**
```
month      | revenue  | moving_avg_3mo
2025-01-01 | 10000.00 | 10000.00      ← Only 1 month available
2025-02-01 | 12000.00 | 11000.00      ← Average of 2 months
2025-03-01 | 11000.00 | 11000.00      ← First full 3-month average
2025-04-01 | 13000.00 | 12000.00      ← Window slides: Feb, Mar, Apr
2025-05-01 | 14500.00 | 12833.33      ← Window slides: Mar, Apr, May
2025-06-01 | 15000.00 | 14166.67      ← Window slides: Apr, May, Jun
```

**🔍 What Just Happened?**
- The "window" is always 3 months (current + 2 before)
- The window "slides" forward each row
- Early months use fewer than 3 months (not enough data yet)
- This smooths out spikes - notice how the moving average is more stable than individual months!

**💡 Beginner Tip:** 
- 3-month average = `2 PRECEDING` (not 3!) because it includes current row
- 7-day average = `6 PRECEDING` (6 + current = 7 days)
- The frame always includes the current row!

## Activity 3: Department Comparison (18 min)

**🎯 Business Context:** HR wants to show each employee how their salary compares to their department's average. This helps ensure fair compensation within teams.

**💡 Real-World Use:** Performance reviews, salary benchmarking, identifying pay gaps within departments.

**🧩 The Challenge:** For each employee, show:
- Their salary
- Their department's average salary
- How much above/below average they are

Setup:
```sql
DROP TABLE IF EXISTS gs8_employees;
CREATE TABLE gs8_employees (emp_name VARCHAR(60), dept VARCHAR(30), salary DECIMAL(10,2));
INSERT INTO gs8_employees VALUES 
('Alice','Sales',60000),('Bob','Sales',70000),('Carol','IT',80000),('Dave','IT',85000),('Eve','IT',75000);
```

**📝 Step-by-Step Approach:**

**Step 1:** Calculate department averages (see the pattern)
```sql
-- First, let's see what we're working with
SELECT 
  emp_name, 
  dept, 
  salary
FROM gs8_employees
ORDER BY dept, salary DESC;
```

**Mental Calculation:**
- Sales average: (60,000 + 70,000) / 2 = 65,000
- IT average: (80,000 + 85,000 + 75,000) / 3 = 80,000

**Step 2:** Add department averages using window function
```sql
SELECT 
  emp_name, 
  dept, 
  salary,
  AVG(salary) OVER (PARTITION BY dept) AS dept_avg  -- Calculate average per department
FROM gs8_employees
ORDER BY dept, salary DESC;
```

**What's happening:** 
- `PARTITION BY dept` creates separate calculations for Sales and IT
- No `ORDER BY` in OVER() because we want the average across ALL rows in each partition
- Every employee in Sales sees $65,000, every employee in IT sees $80,000

**Step 3:** Calculate difference from average
```sql
SELECT 
  emp_name, 
  dept, 
  salary,
  AVG(salary) OVER (PARTITION BY dept) AS dept_avg,
  salary - AVG(salary) OVER (PARTITION BY dept) AS diff_from_avg,
  ROUND((salary - AVG(salary) OVER (PARTITION BY dept)) / AVG(salary) OVER (PARTITION BY dept) * 100, 1) AS pct_diff
FROM gs8_employees
ORDER BY dept, salary DESC;
```

**Expected Results:**
```
emp_name | dept  | salary  | dept_avg | diff_from_avg | pct_diff
Bob      | Sales | 70000   | 65000    | 5000          | 7.7%     ← Above average
Alice    | Sales | 60000   | 65000    | -5000         | -7.7%    ← Below average
Dave     | IT    | 85000   | 80000    | 5000          | 6.3%     ← Above average
Carol    | IT    | 80000   | 80000    | 0             | 0.0%     ← Exactly average
Eve      | IT    | 75000   | 80000    | -5000         | -6.3%    ← Below average
```

**🔍 What Just Happened?**
- Window function calculates department average WITHOUT collapsing rows
- Every employee can see their department's average on their own row
- We can then do math: their salary minus the average
- Positive = above average, Negative = below average

**💡 Beginner Tip:** 
- Notice we use the SAME window function `AVG(salary) OVER (PARTITION BY dept)` multiple times
- MySQL is smart - it calculates it once and reuses the result
- Each Sales employee sees 65000, each IT employee sees 80000

**🎓 Advanced Insight:** Compare this to GROUP BY:
```sql
-- This would give you ONE row per department (not what we want!)
SELECT dept, AVG(salary) AS dept_avg
FROM gs8_employees
GROUP BY dept;

-- Window functions preserve individual employee rows (exactly what we want!)
```

**✅ Checkpoint:** You now understand:
- Top N per group (Activity 1)
- Moving averages (Activity 2)
- Department comparisons (Activity 3)

**Next:** Move to `03-Independent-Practice.md` to practice these patterns without step-by-step guidance!
