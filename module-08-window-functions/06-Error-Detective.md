# Error Detective — Window Functions (5 challenges)

## Challenge 1: Missing ORDER BY in Window
**Broken:**
```sql
SELECT emp_name, salary, ROW_NUMBER() OVER () AS rn FROM employees;
```
**Error:** ROW_NUMBER() requires ORDER BY in OVER() clause.
**Fix:**
```sql
SELECT emp_name, salary, ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn FROM employees;
```

## Challenge 2: Wrong Frame Specification
**Broken:**
```sql
SELECT date, value, SUM(value) OVER (ORDER BY date ROWS 3) AS moving_sum FROM metrics;
```
**Error:** Incomplete frame specification.
**Fix:**
```sql
SELECT date, value, 
  SUM(value) OVER (ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_sum_3
FROM metrics;
```

## Challenge 3: LAG() Without Default
**Broken:**
```sql
SELECT month, revenue, LAG(revenue, 1) OVER (ORDER BY month) AS prev_month FROM sales;
```
**Issue:** First row shows NULL, may cause issues in calculations.
**Fix:**
```sql
SELECT month, revenue, 
  LAG(revenue, 1, 0) OVER (ORDER BY month) AS prev_month,
  revenue - LAG(revenue, 1, 0) OVER (ORDER BY month) AS growth
FROM sales;
```

## Challenge 4: Partition and Group By Confusion
**Broken:**
```sql
SELECT dept, AVG(salary) OVER (PARTITION BY dept) AS avg_sal
FROM employees
GROUP BY dept;
```
**Error:** Can't GROUP BY when using window functions on individual rows.
**Fix:**
```sql
-- If you want individual rows with dept average:
SELECT emp_name, dept, salary,
  AVG(salary) OVER (PARTITION BY dept) AS dept_avg
FROM employees;

-- If you want one row per dept:
SELECT dept, AVG(salary) AS avg_sal
FROM employees
GROUP BY dept;
```

## Challenge 5: Incorrect QUALIFY Usage
**Broken (MySQL < 8.0.31):**
```sql
SELECT product, sales, ROW_NUMBER() OVER (ORDER BY sales DESC) AS rn
FROM products
QUALIFY rn <= 5;
```
**Error:** QUALIFY not supported in MySQL < 8.0.31.
**Fix:**
```sql
SELECT * FROM (
  SELECT product, sales, ROW_NUMBER() OVER (ORDER BY sales DESC) AS rn
  FROM products
) ranked
WHERE rn <= 5;
```

**Next:** Move to `07-Speed-Drills.md`
