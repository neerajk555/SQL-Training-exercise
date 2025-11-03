# Module 08 · Window Functions

Window functions perform calculations across sets of rows related to the current row, without collapsing the result set like GROUP BY does. They're essential for analytics, ranking, and time-series analysis.

## Topics Covered

### 1. Introduction to Window Functions
- **Syntax**: `function_name() OVER (PARTITION BY ... ORDER BY ... ROWS/RANGE ...)`
- **Key Difference from GROUP BY**: Window functions preserve all rows while adding calculated columns
- **OVER Clause**: Defines the window (partition and order) for the calculation
- **Frame Specification**: ROWS or RANGE defines which rows to include in calculation

```sql
-- Basic window function
SELECT 
  employee_name,
  salary,
  AVG(salary) OVER () AS company_avg_salary
FROM employees;
-- Every row shows the same company average, but all rows are preserved
```

### 2. Ranking Functions
**ROW_NUMBER()**: Assigns unique sequential numbers (1, 2, 3, ...)
```sql
SELECT 
  product_name,
  sales,
  ROW_NUMBER() OVER (ORDER BY sales DESC) AS row_num
FROM products;
```

**RANK()**: Assigns ranks with gaps after ties (1, 2, 2, 4, ...)
```sql
SELECT 
  student_name,
  score,
  RANK() OVER (ORDER BY score DESC) AS rank
FROM exam_scores;
-- Two students with same score get rank 2, next gets rank 4 (gap)
```

**DENSE_RANK()**: Assigns ranks without gaps (1, 2, 2, 3, ...)
```sql
SELECT 
  student_name,
  score,
  DENSE_RANK() OVER (ORDER BY score DESC) AS dense_rank
FROM exam_scores;
-- Two students with same score get rank 2, next gets rank 3 (no gap)
```

**NTILE(n)**: Divides rows into n roughly equal buckets
```sql
SELECT 
  customer_name,
  total_purchases,
  NTILE(4) OVER (ORDER BY total_purchases DESC) AS quartile
FROM customers;
-- Quartile 1 = top 25%, 2 = next 25%, etc.
```

### 3. PARTITION BY (Grouping Within Windows)
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
```

### 4. Aggregate Window Functions
SUM(), AVG(), COUNT(), MIN(), MAX() can be used as window functions.

```sql
-- Running total
SELECT 
  order_date,
  amount,
  SUM(amount) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM orders;

-- Department average
SELECT 
  employee_name,
  department,
  salary,
  AVG(salary) OVER (PARTITION BY department) AS dept_avg
FROM employees;
```

### 5. LAG() and LEAD()
Access values from previous or following rows without self-joins.

**LAG(column, offset, default)**: Look backwards
```sql
SELECT 
  month,
  revenue,
  LAG(revenue, 1, 0) OVER (ORDER BY month) AS previous_month_revenue,
  revenue - LAG(revenue, 1, 0) OVER (ORDER BY month) AS month_over_month_change
FROM monthly_sales;
```

**LEAD(column, offset, default)**: Look forward
```sql
SELECT 
  order_id,
  order_date,
  LEAD(order_date, 1) OVER (ORDER BY order_date) AS next_order_date,
  DATEDIFF(LEAD(order_date, 1) OVER (ORDER BY order_date), order_date) AS days_until_next_order
FROM orders;
```

### 6. Frame Specifications (ROWS vs RANGE)
Control which rows are included in the window calculation.

**ROWS**: Physical row count
```sql
-- Moving average of last 3 rows
SELECT 
  date,
  value,
  AVG(value) OVER (ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3
FROM metrics;
```

**RANGE**: Logical value range
```sql
-- Sum of all rows with same date
SELECT 
  date,
  amount,
  SUM(amount) OVER (ORDER BY date RANGE BETWEEN CURRENT ROW AND CURRENT ROW) AS daily_total
FROM transactions;
```

**Frame Options:**
- `UNBOUNDED PRECEDING`: Start of partition
- `UNBOUNDED FOLLOWING`: End of partition
- `CURRENT ROW`: Current row
- `n PRECEDING`: n rows before current
- `n FOLLOWING`: n rows after current

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

### 8. Performance Considerations
- Window functions can be resource-intensive on large datasets
- ORDER BY within OVER() requires sorting
- Indexes on PARTITION BY and ORDER BY columns help
- Consider materialized views for frequently-used window calculations
- ROWS frame is generally faster than RANGE

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
