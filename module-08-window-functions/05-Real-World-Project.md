# Real-World Project — Window Functions (45-60 min)

## Project: E-Commerce Customer Analytics Dashboard

### Business Problem:
Build comprehensive customer analytics using window functions: ranking, cohort analysis, trend detection.

### Setup (comprehensive dataset):
```sql
DROP TABLE IF EXISTS rw8_customers;
CREATE TABLE rw8_customers (customer_id INT PRIMARY KEY, signup_date DATE, tier VARCHAR(20));
INSERT INTO rw8_customers VALUES 
(1,'2024-01-15','Gold'),(2,'2024-01-20','Silver'),(3,'2024-02-10','Gold'),
(4,'2024-02-15','Bronze'),(5,'2024-03-05','Silver');

DROP TABLE IF EXISTS rw8_orders;
CREATE TABLE rw8_orders (order_id INT PRIMARY KEY, customer_id INT, order_date DATE, amount DECIMAL(10,2));
INSERT INTO rw8_orders VALUES 
(101,1,'2024-02-01',500),(102,1,'2024-03-01',750),(103,2,'2024-02-15',200),
(104,3,'2024-03-10',1000),(105,1,'2024-04-01',600),(106,4,'2024-03-20',150);
```

### Deliverable 1: Customer Lifetime Value Ranking
Rank customers by total spend with tier-based comparison.
```sql
WITH customer_totals AS (
  SELECT c.customer_id, c.tier, COALESCE(SUM(o.amount), 0) AS total_spend
  FROM rw8_customers c
  LEFT JOIN rw8_orders o ON c.customer_id = o.customer_id
  GROUP BY c.customer_id, c.tier
)
SELECT customer_id, tier, total_spend,
  RANK() OVER (ORDER BY total_spend DESC) AS overall_rank,
  RANK() OVER (PARTITION BY tier ORDER BY total_spend DESC) AS tier_rank,
  total_spend - AVG(total_spend) OVER (PARTITION BY tier) AS vs_tier_avg
FROM customer_totals
ORDER BY overall_rank;
```

### Deliverable 2: Monthly Cohort Analysis
Track customer acquisition and spending trends by cohort.
```sql
WITH monthly_cohorts AS (
  SELECT 
    DATE_FORMAT(c.signup_date, '%Y-%m-01') AS cohort_month,
    COUNT(DISTINCT c.customer_id) AS cohort_size,
    COALESCE(SUM(o.amount), 0) AS total_revenue
  FROM rw8_customers c
  LEFT JOIN rw8_orders o ON c.customer_id = o.customer_id
  GROUP BY cohort_month
)
SELECT cohort_month, cohort_size, total_revenue,
  SUM(cohort_size) OVER (ORDER BY cohort_month) AS cumulative_customers,
  AVG(total_revenue) OVER (ORDER BY cohort_month ROWS 2 PRECEDING) AS moving_avg_revenue
FROM monthly_cohorts;
```

### Deliverable 3: Purchase Pattern Analysis
Identify time between purchases and detect churning customers.
```sql
WITH customer_orders AS (
  SELECT customer_id, order_date,
    LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date,
    DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS days_since_last
  FROM rw8_orders
)
SELECT customer_id, order_date, prev_order_date, days_since_last,
  CASE 
    WHEN days_since_last > 60 THEN 'At Risk'
    WHEN days_since_last > 30 THEN 'Monitor'
    ELSE 'Active'
  END AS churn_risk
FROM customer_orders
WHERE prev_order_date IS NOT NULL;
```

**Project Complete!** You've built a comprehensive analytics dashboard using window functions.

**Next:** Move to `06-Error-Detective.md`
