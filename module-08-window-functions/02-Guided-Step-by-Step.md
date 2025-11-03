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
Business context: Show top 3 products by sales in each category.

Setup:
```sql
DROP TABLE IF EXISTS gs8_products;
CREATE TABLE gs8_products (product_id INT, product_name VARCHAR(60), category VARCHAR(40), monthly_sales DECIMAL(10,2));
INSERT INTO gs8_products VALUES 
(1,'Laptop','Electronics',15000),(2,'Mouse','Electronics',2000),(3,'Keyboard','Electronics',3000),
(4,'Desk','Furniture',5000),(5,'Chair','Furniture',8000),(6,'Lamp','Furniture',1500),
(7,'Notebook','Stationery',500),(8,'Pen','Stationery',200);
```

Steps:
1. Add ROW_NUMBER() partitioned by category, ordered by sales DESC
2. Filter WHERE row_num <= 3
3. Verify each category shows top 3

Solution:
```sql
SELECT category, product_name, monthly_sales, 
  ROW_NUMBER() OVER (PARTITION BY category ORDER BY monthly_sales DESC) AS rank_in_category
FROM gs8_products
QUALIFY rank_in_category <= 3  -- MySQL 8.0.31+
-- OR use subquery WHERE clause for earlier versions
ORDER BY category, rank_in_category;
```

## Activity 2: Running Average (17 min)
Calculate 3-month moving average for sales.

Setup:
```sql
DROP TABLE IF EXISTS gs8_monthly_sales;
CREATE TABLE gs8_monthly_sales (month DATE, revenue DECIMAL(12,2));
INSERT INTO gs8_monthly_sales VALUES 
('2025-01-01',10000),('2025-02-01',12000),('2025-03-01',11000),
('2025-04-01',13000),('2025-05-01',14500),('2025-06-01',15000);
```

Solution:
```sql
SELECT month, revenue,
  AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3mo
FROM gs8_monthly_sales;
```

## Activity 3: Department Comparison (18 min)
Show each employee's salary vs department average.

Setup:
```sql
DROP TABLE IF EXISTS gs8_employees;
CREATE TABLE gs8_employees (emp_name VARCHAR(60), dept VARCHAR(30), salary DECIMAL(10,2));
INSERT INTO gs8_employees VALUES 
('Alice','Sales',60000),('Bob','Sales',70000),('Carol','IT',80000),('Dave','IT',85000),('Eve','IT',75000);
```

Solution:
```sql
SELECT emp_name, dept, salary,
  AVG(salary) OVER (PARTITION BY dept) AS dept_avg,
  salary - AVG(salary) OVER (PARTITION BY dept) AS diff_from_avg
FROM gs8_employees
ORDER BY dept, salary DESC;
```

**Next:** Move to `03-Independent-Practice.md`
