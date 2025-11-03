# Take-Home Challenges — Window Functions (Advanced)

## Challenge 1: Time Series Anomaly Detection (50 min)

### Context:
Detect unusual patterns in daily website traffic using window functions.

### Setup:
```sql
DROP TABLE IF EXISTS thc8_traffic;
CREATE TABLE thc8_traffic (traffic_date DATE, visitors INT);
-- Insert 90 days of data with some anomalies
```

### Tasks:
1. Calculate 7-day and 30-day moving averages
2. Identify days where traffic is >20% above/below 7-day average
3. Rank anomalies by severity
4. Detect weekly patterns using LAG(value, 7)

### Solution Framework:
```sql
WITH traffic_analysis AS (
  SELECT traffic_date, visitors,
    AVG(visitors) OVER (ORDER BY traffic_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS ma_7day,
    AVG(visitors) OVER (ORDER BY traffic_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS ma_30day,
    LAG(visitors, 7) OVER (ORDER BY traffic_date) AS same_day_last_week
  FROM thc8_traffic
)
SELECT *,
  ROUND((visitors - ma_7day) / ma_7day * 100, 2) AS pct_deviation_7day,
  CASE 
    WHEN ABS((visitors - ma_7day) / ma_7day) > 0.2 THEN 'Anomaly'
    ELSE 'Normal'
  END AS status,
  RANK() OVER (ORDER BY ABS(visitors - ma_7day) DESC) AS anomaly_rank
FROM traffic_analysis
WHERE ma_7day IS NOT NULL;
```

---

## Challenge 2: Sales Leaderboard with Streaks (50 min)

### Context:
Build dynamic leaderboard showing current rankings, rank changes, and winning streaks.

### Tasks:
1. Rank salespeople by monthly performance
2. Compare to previous month's rank (LAG)
3. Identify longest winning streak (consecutive #1 rankings)
4. Show percentile rankings

### Solution Approach:
```sql
WITH monthly_rankings AS (
  SELECT salesperson, month, total_sales,
    RANK() OVER (PARTITION BY month ORDER BY total_sales DESC) AS monthly_rank,
    LAG(RANK() OVER (PARTITION BY month ORDER BY total_sales DESC), 1) 
      OVER (PARTITION BY salesperson ORDER BY month) AS prev_rank,
    PERCENT_RANK() OVER (PARTITION BY month ORDER BY total_sales) AS percentile
  FROM sales
)
SELECT salesperson, month, monthly_rank, prev_rank,
  monthly_rank - prev_rank AS rank_change,
  percentile
FROM monthly_rankings;
```

---

## Challenge 3: Customer Segmentation with RFM Analysis (60 min)

### Context:
Implement Recency, Frequency, Monetary (RFM) analysis using window functions.

### Tasks:
1. Calculate recency (days since last purchase), frequency (purchase count), monetary (total spend)
2. Assign quartiles for each RFM dimension using NTILE(4)
3. Create composite RFM score
4. Rank customers and identify top/bottom segments

### Solution:
```sql
WITH rfm_metrics AS (
  SELECT customer_id,
    DATEDIFF(CURDATE(), MAX(order_date)) AS recency,
    COUNT(order_id) AS frequency,
    SUM(amount) AS monetary
  FROM orders
  GROUP BY customer_id
),
rfm_scores AS (
  SELECT customer_id, recency, frequency, monetary,
    NTILE(4) OVER (ORDER BY recency ASC) AS r_score,  -- Lower recency = better
    NTILE(4) OVER (ORDER BY frequency DESC) AS f_score,
    NTILE(4) OVER (ORDER BY monetary DESC) AS m_score
  FROM rfm_metrics
)
SELECT customer_id,
  r_score, f_score, m_score,
  (r_score + f_score + m_score) / 3.0 AS rfm_avg_score,
  CASE 
    WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Champions'
    WHEN r_score >= 3 AND f_score >= 2 THEN 'Loyal'
    WHEN r_score >= 3 THEN 'Potential'
    WHEN r_score = 1 THEN 'At Risk'
    ELSE 'Needs Attention'
  END AS segment,
  RANK() OVER (ORDER BY (r_score + f_score + m_score) DESC) AS overall_rank
FROM rfm_scores
ORDER BY overall_rank;
```

**Module 8 Complete!**
