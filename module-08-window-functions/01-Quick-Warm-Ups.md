# Quick Warm-Ups — Window Functions (5–10 min each)

## 📋 Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Use ROW_NUMBER() to assign sequential numbers
- Apply RANK() and DENSE_RANK() for rankings with ties
- Calculate running totals with SUM() OVER
- Access previous/next rows with LAG() and LEAD()
- Partition data with PARTITION BY

### Key Window Function Concepts
**What are Window Functions?**
- Perform calculations across rows related to the current row
- DON'T reduce the number of rows (unlike GROUP BY)
- Add calculated columns to existing rows
- Use OVER clause to define the "window"

**Common Window Functions:**
- `ROW_NUMBER()`: Sequential numbers (1,2,3...) no matter what
- `RANK()`: Rankings with gaps for ties (1,1,3,4...)
- `DENSE_RANK()`: Rankings without gaps (1,1,2,3...)
- `LAG()`: Access previous row value
- `LEAD()`: Access next row value
- `SUM/AVG/COUNT() OVER`: Running aggregates

**PARTITION BY vs ORDER BY:**
- `PARTITION BY`: Divides data into groups (like GROUP BY but doesn't collapse)
- `ORDER BY`: Defines the order within each partition
- Example: `OVER (PARTITION BY category ORDER BY price DESC)`
  - Creates separate rankings within each category

### Execution Tips
1. **Start simple**: Try window functions on small datasets
2. **Verify partitions**: Check that PARTITION BY groups make sense
3. **Understand ORDER BY**: It affects which rows are included in calculations
4. **Test incrementally**: Add window functions one at a time

**Beginner Tip:** Window functions add calculated columns without reducing rows. ROW_NUMBER() assigns unique numbers, RANK() handles ties, LAG() looks backward. Practice with small datasets first!

---

## 1) Row Numbers for Products — 7 min

**🎯 What You're Learning:** How to assign sequential numbers to rows in a specific order.

**💡 Real-World Use:** Think of this like numbering items in a sorted list - "most expensive product is #1, second most expensive is #2", etc.

Sample data:
```sql
DROP TABLE IF EXISTS wu8_products;
CREATE TABLE wu8_products (product_id INT PRIMARY KEY, product_name VARCHAR(60), price DECIMAL(8,2));
INSERT INTO wu8_products VALUES (1,'Laptop',1200),(2,'Mouse',25),(3,'Keyboard',75);
```

**Task:** Add row numbers ordered by price DESC (highest price gets #1).

**🤔 Think About It:** 
- We want to number products from most expensive to least expensive
- ROW_NUMBER() gives each row a unique sequential number
- ORDER BY price DESC sorts from highest to lowest price

Expected output:
```
product_name | price   | row_num
Laptop       | 1200.00 | 1        ← Most expensive
Keyboard     | 75.00   | 2        ← Second
Mouse        | 25.00   | 3        ← Least expensive
```

**Solution Explained:**
```sql
SELECT 
  product_name, 
  price, 
  ROW_NUMBER() OVER (ORDER BY price DESC) AS row_num  -- Number from highest to lowest price
FROM wu8_products;
```

**🔍 Breaking It Down:**
- `ROW_NUMBER()`: The function that assigns numbers (1, 2, 3...)
- `OVER (...)`: Makes it a window function (keeps all rows)
- `ORDER BY price DESC`: Defines the sorting order (highest price first)
- Result: Each product gets a unique position number based on its price

---

## 2) Rank Students by Score — 6 min

**🎯 What You're Learning:** How RANK() handles tied values (same scores get same rank).

**💡 Real-World Use:** Like Olympic medals - if two people tie for gold, there's no silver medal, next person gets bronze!

Sample data:
```sql
DROP TABLE IF EXISTS wu8_scores;
CREATE TABLE wu8_scores (student_name VARCHAR(60), score INT);
INSERT INTO wu8_scores VALUES ('Alice',95),('Bob',90),('Carol',95),('Dave',85);
```

**Task:** Rank students by score (highest score = rank 1). Notice that Alice and Carol have the same score!

**🤔 Think About It:** 
- Alice and Carol both scored 95 - they should tie for 1st place
- Bob scored 90 - he comes after the tie, so he's 3rd (not 2nd!)
- RANK() leaves gaps after ties (1, 1, 3, 4 instead of 1, 1, 2, 3)

Expected output:
```
student_name | score | rank
Alice        | 95    | 1     ← Tied for first
Carol        | 95    | 1     ← Also tied for first
Bob          | 90    | 3     ← Note the gap! (rank 2 is skipped)
Dave         | 85    | 4
```

**Solution Explained:**
```sql
SELECT 
  student_name, 
  score, 
  RANK() OVER (ORDER BY score DESC) AS rank  -- Assigns ranks with gaps for ties
FROM wu8_scores;
```

**🔍 Breaking It Down:**
- `RANK()`: Gives same rank to tied values, then skips ranks
- Why rank 3 instead of 2? Because TWO people ranked higher (both got rank 1)
- Alternative: Use `DENSE_RANK()` if you want 1, 1, 2, 3 (no gaps)

**⚡ Quick Comparison:**
- `ROW_NUMBER()` would give: 1, 2, 3, 4 (breaks ties arbitrarily)
- `RANK()` gives: 1, 1, 3, 4 (ties get same rank, then gap)
- `DENSE_RANK()` would give: 1, 1, 2, 3 (ties get same rank, no gap)

---

## 3) Department Salary Ranking — 8 min

**🎯 What You're Learning:** Using PARTITION BY to create separate rankings for each group.

**💡 Real-World Use:** Like finding the top salesperson in EACH region separately (not just overall). Each department gets its own "competition"!

Sample data:
```sql
DROP TABLE IF EXISTS wu8_employees;
CREATE TABLE wu8_employees (emp_id INT, name VARCHAR(60), dept VARCHAR(30), salary DECIMAL(10,2));
INSERT INTO wu8_employees VALUES (1,'Alice','Sales',70000),(2,'Bob','IT',80000),(3,'Carol','Sales',75000),(4,'Dave','IT',85000);
```

**Task:** Rank employees within each department by salary (separate rankings for IT and Sales).

**🤔 Think About It:** 
- Without PARTITION BY: Dave would be #1 overall (highest salary across all)
- With PARTITION BY dept: Dave is #1 in IT, Carol is #1 in Sales (separate competitions!)
- Rankings restart at 1 for each department

Expected output:
```
name  | dept  | salary  | dept_rank
Dave  | IT    | 85000   | 1          ← #1 in IT department
Bob   | IT    | 80000   | 2          ← #2 in IT department
Carol | Sales | 75000   | 1          ← #1 in Sales (ranking restarted!)
Alice | Sales | 70000   | 2          ← #2 in Sales
```

**Solution Explained:**
```sql
SELECT 
  name, 
  dept, 
  salary, 
  RANK() OVER (
    PARTITION BY dept         -- Separate ranking for each department
    ORDER BY salary DESC      -- Within each department, highest salary = rank 1
  ) AS dept_rank
FROM wu8_employees
ORDER BY dept, dept_rank;     -- Sort output by department, then rank
```

**🔍 Breaking It Down:**
- `PARTITION BY dept`: Creates separate "windows" for each department
- Think of it as: "Reset the ranking to 1 every time the department changes"
- Carol earns less than Bob ($75k vs $80k), but she's still #1 in her department!

**💡 Beginner Tip:** 
- No PARTITION BY = one ranking across ALL rows
- PARTITION BY = separate rankings for each group
- It's like having multiple "top 10" lists instead of one master list

---

## 4) Running Total of Sales — 8 min

**🎯 What You're Learning:** Creating a cumulative sum that grows with each row.

**💡 Real-World Use:** Like your bank account balance - each transaction adds to the total, and you see "how much have I spent so far?"

Sample data:
```sql
DROP TABLE IF EXISTS wu8_sales;
CREATE TABLE wu8_sales (sale_date DATE, amount DECIMAL(8,2));
INSERT INTO wu8_sales VALUES ('2025-03-01',100),('2025-03-02',150),('2025-03-03',200);
```

**Task:** Calculate a running total (cumulative sum) of sales over time.

**🤔 Think About It:** 
- Day 1: $100 total
- Day 2: $100 + $150 = $250 total
- Day 3: $250 + $200 = $450 total
- Each row shows "total so far" (not just that day's amount)

Expected output:
```
sale_date  | amount | running_total
2025-03-01 | 100    | 100           ← Just first day
2025-03-02 | 150    | 250           ← First + Second day
2025-03-03 | 200    | 450           ← All three days combined
```

**Solution Explained:**
```sql
SELECT 
  sale_date, 
  amount, 
  SUM(amount) OVER (
    ORDER BY sale_date                              -- Process rows in date order
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  -- Sum from start to current row
  ) AS running_total
FROM wu8_sales;
```

**🔍 Breaking It Down:**
- `SUM(amount)`: Add up the amounts
- `OVER (ORDER BY sale_date)`: Process in chronological order
- `UNBOUNDED PRECEDING`: Start from the very first row
- `CURRENT ROW`: Go up to (and include) the current row
- Result: Each row shows the cumulative total up to that point

**💡 MySQL Shortcut:** You can simplify this!
```sql
-- This does the same thing (MySQL assumes UNBOUNDED PRECEDING to CURRENT ROW)
SELECT sale_date, amount, 
  SUM(amount) OVER (ORDER BY sale_date) AS running_total
FROM wu8_sales;
```

**🎓 Advanced Insight:** If you remove ORDER BY, you'd get the SAME total (450) on every row - that would be the grand total, not a running total!

---

## 5) Previous Month Comparison (LAG) — 9 min

**🎯 What You're Learning:** Using LAG() to access data from previous rows (time-series comparison).

**💡 Real-World Use:** Like comparing this month's sales to last month's - "Are we up or down from last month?"

Sample data:
```sql
DROP TABLE IF EXISTS wu8_monthly_revenue;
CREATE TABLE wu8_monthly_revenue (month DATE, revenue DECIMAL(10,2));
INSERT INTO wu8_monthly_revenue VALUES ('2025-01-01',10000),('2025-02-01',12000),('2025-03-01',11500);
```

**Task:** Show each month's revenue alongside the previous month's revenue, and calculate the change.

**🤔 Think About It:** 
- January has no "previous month" in our data (should show NULL)
- February: compare to January ($12,000 - $10,000 = +$2,000 growth!)
- March: compare to February ($11,500 - $12,000 = -$500 decline)
- LAG() "looks backwards" one row at a time

Expected output:
```
month      | revenue | prev_revenue | change
2025-01-01 | 10000   | NULL         | NULL    ← First month, no previous data
2025-02-01 | 12000   | 10000        | 2000    ← +$2,000 from previous month
2025-03-01 | 11500   | 12000        | -500    ← -$500 from previous month
```

**Solution Explained:**
```sql
SELECT 
  month, 
  revenue,
  LAG(revenue, 1) OVER (ORDER BY month) AS prev_revenue,  -- Get previous month's revenue
  revenue - LAG(revenue, 1) OVER (ORDER BY month) AS change  -- Calculate difference
FROM wu8_monthly_revenue;
```

**🔍 Breaking It Down:**
- `LAG(revenue, 1)`: "Look back 1 row and get the revenue value"
- `OVER (ORDER BY month)`: "Look back in chronological order"
- First row has no previous row, so LAG returns NULL
- `revenue - LAG(...)`: Subtracts previous from current (positive = growth, negative = decline)

**💡 Better Version with Default Value:**
```sql
-- Use 0 as default instead of NULL (prevents NULL in calculations)
SELECT 
  month, 
  revenue,
  LAG(revenue, 1, 0) OVER (ORDER BY month) AS prev_revenue,  -- Default to 0 if no previous
  revenue - LAG(revenue, 1, 0) OVER (ORDER BY month) AS change
FROM wu8_monthly_revenue;
```

**🎓 Advanced Insight:** 
- `LAG(revenue, 1)` = look back 1 month
- `LAG(revenue, 3)` = look back 3 months (for quarterly comparison!)
- `LEAD(revenue, 1)` = look FORWARD to next month (opposite of LAG)

---

**✅ Congratulations!** You've completed the warm-ups and learned:
- ROW_NUMBER() for sequential numbering
- RANK() for handling ties
- PARTITION BY for separate group rankings  
- Running totals with SUM() OVER
- LAG() for period-over-period comparisons

**Next Step:** Move to `02-Guided-Step-by-Step.md` for more complex scenarios with detailed guidance.
