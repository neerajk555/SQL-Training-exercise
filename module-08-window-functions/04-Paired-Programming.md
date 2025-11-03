# Paired Programming — Window Functions (30 min)

## Activity: Quarterly Sales Analysis
Partners analyze sales performance with window functions.

### Setup:
```sql
DROP TABLE IF EXISTS pp8_sales;
CREATE TABLE pp8_sales (quarter DATE, region VARCHAR(30), revenue DECIMAL(12,2));
INSERT INTO pp8_sales VALUES 
('2024-Q1','North',100000),('2024-Q1','South',95000),('2024-Q2','North',110000),
('2024-Q2','South',105000),('2024-Q3','North',115000),('2024-Q3','South',120000);
```

### Part A: Regional Ranking (Driver: Partner 1)
Rank regions by revenue each quarter.
```sql
SELECT quarter, region, revenue,
  RANK() OVER (PARTITION BY quarter ORDER BY revenue DESC) AS quarterly_rank
FROM pp8_sales;
```

### Part B: Quarter-over-Quarter Growth (Driver: Partner 2)
Calculate growth rate for each region.
```sql
SELECT quarter, region, revenue,
  LAG(revenue) OVER (PARTITION BY region ORDER BY quarter) AS prev_quarter,
  ROUND((revenue - LAG(revenue) OVER (PARTITION BY region ORDER BY quarter)) / 
    LAG(revenue) OVER (PARTITION BY region ORDER BY quarter) * 100, 2) AS qoq_growth_pct
FROM pp8_sales;
```

### Part C: Cumulative Analysis (Both Partners)
Running total and moving average.
```sql
SELECT quarter, region, revenue,
  SUM(revenue) OVER (PARTITION BY region ORDER BY quarter) AS cumulative_revenue,
  AVG(revenue) OVER (PARTITION BY region ORDER BY quarter ROWS 1 PRECEDING) AS moving_avg_2q
FROM pp8_sales;
```

**Next:** Move to `05-Real-World-Project.md`
