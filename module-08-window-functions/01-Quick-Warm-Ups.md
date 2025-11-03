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
Sample data:
```sql
DROP TABLE IF EXISTS wu8_products;
CREATE TABLE wu8_products (product_id INT PRIMARY KEY, product_name VARCHAR(60), price DECIMAL(8,2));
INSERT INTO wu8_products VALUES (1,'Laptop',1200),(2,'Mouse',25),(3,'Keyboard',75);
```
Task: Add row numbers ordered by price DESC.

Expected output:
```
product_name | price   | row_num
Laptop       | 1200.00 | 1
Keyboard     | 75.00   | 2
Mouse        | 25.00   | 3
```

Solution:
```sql
SELECT product_name, price, ROW_NUMBER() OVER (ORDER BY price DESC) AS row_num
FROM wu8_products;
```

---

## 2) Rank Students by Score — 6 min
Sample data:
```sql
DROP TABLE IF EXISTS wu8_scores;
CREATE TABLE wu8_scores (student_name VARCHAR(60), score INT);
INSERT INTO wu8_scores VALUES ('Alice',95),('Bob',90),('Carol',95),('Dave',85);
```
Task: Rank students (handle ties).

Expected output:
```
student_name | score | rank
Alice        | 95    | 1
Carol        | 95    | 1
Bob          | 90    | 3
Dave         | 85    | 4
```

Solution:
```sql
SELECT student_name, score, RANK() OVER (ORDER BY score DESC) AS rank
FROM wu8_scores;
```

---

## 3) Department Salary Ranking — 8 min
Sample data:
```sql
DROP TABLE IF EXISTS wu8_employees;
CREATE TABLE wu8_employees (emp_id INT, name VARCHAR(60), dept VARCHAR(30), salary DECIMAL(10,2));
INSERT INTO wu8_employees VALUES (1,'Alice','Sales',70000),(2,'Bob','IT',80000),(3,'Carol','Sales',75000),(4,'Dave','IT',85000);
```
Task: Rank employees within each department by salary.

Expected output:
```
name  | dept  | salary  | dept_rank
Dave  | IT    | 85000   | 1
Bob   | IT    | 80000   | 2
Carol | Sales | 75000   | 1
Alice | Sales | 70000   | 2
```

Solution:
```sql
SELECT name, dept, salary, RANK() OVER (PARTITION BY dept ORDER BY salary DESC) AS dept_rank
FROM wu8_employees
ORDER BY dept, dept_rank;
```

---

## 4) Running Total of Sales — 8 min
Sample data:
```sql
DROP TABLE IF EXISTS wu8_sales;
CREATE TABLE wu8_sales (sale_date DATE, amount DECIMAL(8,2));
INSERT INTO wu8_sales VALUES ('2025-03-01',100),('2025-03-02',150),('2025-03-03',200);
```
Task: Calculate running total.

Expected output:
```
sale_date  | amount | running_total
2025-03-01 | 100    | 100
2025-03-02 | 150    | 250
2025-03-03 | 200    | 450
```

Solution:
```sql
SELECT sale_date, amount, 
  SUM(amount) OVER (ORDER BY sale_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM wu8_sales;
```

---

## 5) Previous Month Comparison (LAG) — 9 min
Sample data:
```sql
DROP TABLE IF EXISTS wu8_monthly_revenue;
CREATE TABLE wu8_monthly_revenue (month DATE, revenue DECIMAL(10,2));
INSERT INTO wu8_monthly_revenue VALUES ('2025-01-01',10000),('2025-02-01',12000),('2025-03-01',11500);
```
Task: Show month, revenue, previous month revenue, and change.

Expected output:
```
month      | revenue | prev_revenue | change
2025-01-01 | 10000   | NULL         | NULL
2025-02-01 | 12000   | 10000        | 2000
2025-03-01 | 11500   | 12000        | -500
```

Solution:
```sql
SELECT month, revenue,
  LAG(revenue, 1) OVER (ORDER BY month) AS prev_revenue,
  revenue - LAG(revenue, 1) OVER (ORDER BY month) AS change
FROM wu8_monthly_revenue;
```

---

**Next Step:** Move to `02-Guided-Step-by-Step.md` for structured scenarios.
