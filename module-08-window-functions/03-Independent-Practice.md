# Independent Practice — Window Functions

## Exercise 1: Sales Ranking 🟢 Easy (12 min)
Schema:
```sql
DROP TABLE IF EXISTS ip8_sales;
CREATE TABLE ip8_sales (salesperson VARCHAR(60), region VARCHAR(30), total_sales DECIMAL(10,2));
INSERT INTO ip8_sales VALUES ('Alice','North',50000),('Bob','South',45000),('Carol','North',55000),('Dave','South',60000);
```
Task: Rank salespeople within each region.
Solution:
```sql
SELECT salesperson, region, total_sales,
  RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS region_rank
FROM ip8_sales;
```

## Exercise 2: Running Total 🟢 Easy (13 min)
Calculate cumulative sales by date.
Solution:
```sql
SELECT sale_date, amount,
  SUM(amount) OVER (ORDER BY sale_date) AS cumulative_total
FROM sales;
```

## Exercise 3: Month-over-Month Growth 🟡 Medium (18 min)
Use LAG() to calculate percentage change.
Solution:
```sql
SELECT month, revenue,
  LAG(revenue) OVER (ORDER BY month) AS prev_month,
  ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) * 100, 2) AS pct_change
FROM monthly_revenue;
```

## Exercise 4: Top 3 Per Department 🟡 Medium (20 min)
Find highest-paid employees per department.
Solution:
```sql
WITH ranked AS (
  SELECT emp_name, dept, salary,
    ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary DESC) AS rn
  FROM employees
)
SELECT * FROM ranked WHERE rn <= 3;
```

## Exercise 5: Moving Average 🟡 Medium (22 min)
Calculate 7-day moving average of website visits.
Solution:
```sql
SELECT visit_date, visits,
  AVG(visits) OVER (ORDER BY visit_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7day
FROM daily_visits;
```

## Exercise 6: Quartile Analysis 🟡 Medium (24 min)
Divide customers into quartiles by purchase amount.
Solution:
```sql
SELECT customer_id, total_purchases,
  NTILE(4) OVER (ORDER BY total_purchases DESC) AS quartile
FROM customers;
```

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
