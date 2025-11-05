# Real-World Project — Window Functions (45-60 min)

## Project: E-Commerce Customer Analytics Dashboard

### 🎯 Business Problem:
You're a data analyst at an e-commerce company. The VP of Marketing needs a comprehensive customer analytics dashboard to answer:
1. **Who are our most valuable customers?** (Lifetime value rankings)
2. **How are cohorts performing?** (Monthly customer acquisition & spending trends)
3. **Who's at risk of churning?** (Time between purchases)

This is a realistic project that combines multiple window function techniques!

### 📊 What You'll Build:
- Customer lifetime value (LTV) rankings
- Tier-based comparisons (Gold vs Silver vs Bronze)
- Monthly cohort analysis with running totals
- Churn risk detection using purchase patterns

### Setup (comprehensive dataset):
```sql
-- Customer master data
DROP TABLE IF EXISTS rw8_customers;
CREATE TABLE rw8_customers (
  customer_id INT PRIMARY KEY, 
  signup_date DATE, 
  tier VARCHAR(20)
);
INSERT INTO rw8_customers VALUES 
(1,'2024-01-15','Gold'),
(2,'2024-01-20','Silver'),
(3,'2024-02-10','Gold'),
(4,'2024-02-15','Bronze'),
(5,'2024-03-05','Silver');

-- Transaction data
DROP TABLE IF EXISTS rw8_orders;
CREATE TABLE rw8_orders (
  order_id INT PRIMARY KEY, 
  customer_id INT, 
  order_date DATE, 
  amount DECIMAL(10,2)
);
INSERT INTO rw8_orders VALUES 
(101,1,'2024-02-01',500),
(102,1,'2024-03-01',750),
(103,2,'2024-02-15',200),
(104,3,'2024-03-10',1000),
(105,1,'2024-04-01',600),
(106,4,'2024-03-20',150);
```

**💡 Tip:** Run each deliverable separately, review results, then move to the next!

---

### Deliverable 1: Customer Lifetime Value Ranking (20 min)

**🎯 Business Question:** "Who are our most valuable customers overall, and how do they rank within their membership tier?"

**📋 Requirements:**
1. Calculate total lifetime spend per customer
2. Rank customers overall (across all tiers)
3. Rank customers within their tier (Gold vs Gold, Silver vs Silver, etc.)
4. Show how much above/below their tier average they are

**💡 Window Functions Needed:**
- RANK() for overall ranking
- RANK() with PARTITION BY for tier-based ranking
- AVG() with PARTITION BY for tier averages

**🔍 Step-by-Step Approach:**

**Step 1:** Calculate customer lifetime spend
```sql
-- First, see total spend per customer
SELECT 
  c.customer_id, 
  c.tier, 
  COALESCE(SUM(o.amount), 0) AS total_spend
FROM rw8_customers c
LEFT JOIN rw8_orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.tier
ORDER BY total_spend DESC;
```

**Step 2:** Add rankings and comparisons
```sql
WITH customer_totals AS (
  SELECT 
    c.customer_id, 
    c.tier, 
    COALESCE(SUM(o.amount), 0) AS total_spend
  FROM rw8_customers c
  LEFT JOIN rw8_orders o ON c.customer_id = o.customer_id
  GROUP BY c.customer_id, c.tier
)
SELECT 
  customer_id, 
  tier, 
  total_spend,
  RANK() OVER (ORDER BY total_spend DESC) AS overall_rank,
  RANK() OVER (PARTITION BY tier ORDER BY total_spend DESC) AS tier_rank,
  ROUND(AVG(total_spend) OVER (PARTITION BY tier), 2) AS tier_avg_spend,
  ROUND(total_spend - AVG(total_spend) OVER (PARTITION BY tier), 2) AS vs_tier_avg
FROM customer_totals
ORDER BY overall_rank;
```

**📊 Expected Results:**
```
customer_id | tier   | total_spend | overall_rank | tier_rank | tier_avg_spend | vs_tier_avg
1           | Gold   | 1850        | 1            | 1         | 1425.00        | 425.00
3           | Gold   | 1000        | 2            | 2         | 1425.00        | -425.00
2           | Silver | 200         | 3            | 1         | 200.00         | 0.00
4           | Bronze | 150         | 4            | 1         | 150.00         | 0.00
5           | Silver | 0           | 5            | 2         | 200.00         | -200.00
```

**🔍 Business Insights:**
- Customer #1 is our top spender overall ($1,850)
- Customer #1 spends $425 MORE than the average Gold member
- Customer #3 is a Gold member but spends LESS than average for their tier
- Customer #5 signed up but never purchased (churn risk!)

**💡 Beginner Explanation:**
- First CTE: Calculate totals (GROUP BY collapses rows)
- Then: Add window functions (preserve all customer rows)
- `RANK() OVER (ORDER BY...)`: Overall ranking (all customers compete)
- `RANK() OVER (PARTITION BY tier...)`: Within-tier ranking (Gold vs Gold, etc.)
- `AVG(...) OVER (PARTITION BY tier)`: Tier-specific average for comparison

---

### Deliverable 2: Monthly Cohort Analysis (20 min)

**🎯 Business Question:** "How many customers did we acquire each month, and what's the revenue trend?"

**📋 Requirements:**
1. Group customers by signup month (cohort)
2. Count customers and total revenue per cohort
3. Show cumulative customer count over time
4. Calculate 3-month moving average of revenue

**💡 Window Functions Needed:**
- SUM() for running total of customers
- AVG() with frame specification for moving average

**🔍 Step-by-Step Approach:**

**Step 1:** Create monthly cohorts
```sql
-- First, see customers and revenue by signup month
SELECT 
  DATE_FORMAT(c.signup_date, '%Y-%m-01') AS cohort_month,
  COUNT(DISTINCT c.customer_id) AS cohort_size,
  COALESCE(SUM(o.amount), 0) AS total_revenue
FROM rw8_customers c
LEFT JOIN rw8_orders o ON c.customer_id = o.customer_id
GROUP BY DATE_FORMAT(c.signup_date, '%Y-%m-01')
ORDER BY cohort_month;
```

**💡 MySQL Note:** `DATE_FORMAT(date, '%Y-%m-01')` converts any date to the first day of that month
- '2024-01-15' → '2024-01-01'
- '2024-01-20' → '2024-01-01'
- This groups all January signups together!

**Step 2:** Add cumulative and trend analysis
```sql
WITH monthly_cohorts AS (
  SELECT 
    DATE_FORMAT(c.signup_date, '%Y-%m-01') AS cohort_month,
    COUNT(DISTINCT c.customer_id) AS cohort_size,
    COALESCE(SUM(o.amount), 0) AS total_revenue
  FROM rw8_customers c
  LEFT JOIN rw8_orders o ON c.customer_id = o.customer_id
  GROUP BY DATE_FORMAT(c.signup_date, '%Y-%m-01')
)
SELECT 
  cohort_month, 
  cohort_size, 
  total_revenue,
  SUM(cohort_size) OVER (ORDER BY cohort_month) AS cumulative_customers,
  ROUND(AVG(total_revenue) OVER (
    ORDER BY cohort_month 
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ), 2) AS moving_avg_revenue_3mo
FROM monthly_cohorts
ORDER BY cohort_month;
```

**📊 Expected Results:**
```
cohort_month | cohort_size | total_revenue | cumulative_customers | moving_avg_revenue_3mo
2024-01-01   | 2           | 2050          | 2                    | 2050.00       ← Only 1 month
2024-02-01   | 2           | 1350          | 4                    | 1700.00       ← Avg of 2 months
2024-03-01   | 1           | 0             | 5                    | 1133.33       ← Avg of 3 months
```

**🔍 Business Insights:**
- **January cohort** (2 customers): Generated $2,050 in revenue
- **February cohort** (2 customers): Generated $1,350 in revenue  
- **March cohort** (1 customer): $0 revenue (new signup, hasn't purchased yet!)
- **Cumulative growth**: 2 → 4 → 5 customers
- **Revenue trend**: Moving average declining (needs attention!)

**💡 Beginner Explanation:**
- **Cohort**: Group of customers who signed up in the same month
- **Running total**: `SUM() OVER (ORDER BY...)` accumulates customer count
- **Moving average**: `ROWS BETWEEN 2 PRECEDING...` smooths out monthly spikes
- **Why it matters**: Helps identify which acquisition months brought high-value customers

---

### Deliverable 3: Purchase Pattern Analysis (20 min)

**🎯 Business Question:** "How often do customers purchase? Who's at risk of churning?"

**📋 Requirements:**
1. Calculate days between consecutive purchases for each customer
2. Identify purchase frequency patterns
3. Flag customers at churn risk (long gaps between orders)
4. Categorize risk levels: Active, Monitor, At Risk

**💡 Window Functions Needed:**
- LAG() to get previous order date
- DATEDIFF() to calculate gap
- PARTITION BY customer to track each customer separately

**🔍 Step-by-Step Approach:**

**Step 1:** Calculate days between orders
```sql
-- First, see each order with the previous order date
SELECT 
  customer_id, 
  order_date,
  LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date,
  DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS days_since_last
FROM rw8_orders
ORDER BY customer_id, order_date;
```

**💡 Beginner Explanation:**
- `LAG(order_date)`: Gets the previous order date for THIS customer
- `PARTITION BY customer_id`: Each customer tracked separately (Customer 1's orders don't affect Customer 2)
- `ORDER BY order_date`: Look backward in chronological order
- `DATEDIFF()`: Calculates days between two dates (MySQL function)

**Step 2:** Add churn risk assessment
```sql
WITH customer_orders AS (
  SELECT 
    customer_id, 
    order_date,
    LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date,
    DATEDIFF(
      order_date, 
      LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)
    ) AS days_since_last
  FROM rw8_orders
)
SELECT 
  customer_id, 
  order_date, 
  prev_order_date, 
  days_since_last,
  CASE 
    WHEN days_since_last IS NULL THEN 'First Purchase'
    WHEN days_since_last > 60 THEN 'At Risk'
    WHEN days_since_last > 30 THEN 'Monitor'
    ELSE 'Active'
  END AS churn_risk
FROM customer_orders
ORDER BY customer_id, order_date;
```

**📊 Expected Results:**
```
customer_id | order_date | prev_order_date | days_since_last | churn_risk
1           | 2024-02-01 | NULL            | NULL            | First Purchase
1           | 2024-03-01 | 2024-02-01      | 29              | Active         ← Good! Regular buyer
1           | 2024-04-01 | 2024-03-01      | 31              | Monitor        ← Slightly slow
2           | 2024-02-15 | NULL            | NULL            | First Purchase
3           | 2024-03-10 | NULL            | NULL            | First Purchase
4           | 2024-03-20 | NULL            | NULL            | First Purchase
```

**🔍 Business Insights:**
- **Customer #1**: Repeat buyer! Purchased 3 times
  - First gap: 29 days (Active) ✅
  - Second gap: 31 days (Monitor) ⚠️
  - Action: Send a "we miss you" email if they don't purchase soon
- **Customers 2, 3, 4**: Only 1 purchase each
  - Action: Send onboarding sequence, offer incentive for 2nd purchase

**💡 Advanced Analysis - Current Status:**
```sql
-- Who hasn't purchased in a while?
SELECT 
  c.customer_id,
  c.tier,
  MAX(o.order_date) AS last_order_date,
  DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order,
  CASE 
    WHEN MAX(o.order_date) IS NULL THEN 'Never Purchased'
    WHEN DATEDIFF(CURDATE(), MAX(o.order_date)) > 60 THEN 'High Churn Risk'
    WHEN DATEDIFF(CURDATE(), MAX(o.order_date)) > 30 THEN 'Medium Risk'
    ELSE 'Active'
  END AS current_status
FROM rw8_customers c
LEFT JOIN rw8_orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.tier
ORDER BY days_since_last_order DESC NULLS FIRST;
```

**🎓 Why This Matters:**
- **Churn prevention**: Proactively reach out before customers leave
- **Re-engagement campaigns**: Target "Monitor" and "At Risk" customers
- **Lifetime value**: Regular buyers (short gaps) are more valuable

---

## 🎉 Project Complete!

**What You've Built:**
1. ✅ **Customer LTV Rankings** - Identified top spenders overall and per tier
2. ✅ **Cohort Analysis** - Tracked monthly acquisition and revenue trends
3. ✅ **Churn Detection** - Flagged at-risk customers based on purchase patterns

**Window Functions Used:**
- RANK() for competitive rankings
- PARTITION BY for group-specific calculations
- SUM() for running totals
- AVG() with frames for moving averages
- LAG() for time-series comparisons
- CASE statements for business logic

**Real-World Applications:**
- Executive dashboards
- Marketing campaign targeting
- Customer retention programs
- Sales performance tracking

**Next:** Move to `06-Error-Detective.md` to learn common mistakes and how to fix them!
