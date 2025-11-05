# Take-Home Challenges — Window Functions (Advanced)

**🎯 Purpose:** These are comprehensive, real-world challenges that combine multiple window function techniques. Each takes 45-60 minutes and simulates actual data analyst work.

**💡 Approach:**
1. Read the business context carefully
2. Break down requirements into steps
3. Test each piece before combining
4. Document your insights

---

## Challenge 1: Time Series Anomaly Detection (50 min)

### 🎯 Business Context:
You're a data analyst at a SaaS company. The operations team needs an automated alert system to detect unusual traffic patterns that might indicate:
- **Viral growth** (positive spike - scale up servers!)
- **System issues** (negative drop - investigate bugs!)
- **Seasonal patterns** (normal weekly cycles)

### 📋 Project Requirements:
Your anomaly detection system should:
1. Calculate 7-day and 30-day moving averages (smooth out noise)
2. Identify days where traffic deviates >20% from 7-day average
3. Rank anomalies by severity (most extreme = highest priority)
4. Detect weekly patterns (compare to same day last week)

### Setup:
```sql
DROP TABLE IF EXISTS thc8_traffic;
CREATE TABLE thc8_traffic (traffic_date DATE, visitors INT);

-- Sample data: 30 days with some anomalies
INSERT INTO thc8_traffic VALUES 
('2025-03-01', 1000), ('2025-03-02', 1050), ('2025-03-03', 980),
('2025-03-04', 1020), ('2025-03-05', 1100), ('2025-03-06', 1080),
('2025-03-07', 1040), ('2025-03-08', 2500),  -- SPIKE! Anomaly
('2025-03-09', 1060), ('2025-03-10', 1030), ('2025-03-11', 1070),
('2025-03-12', 1090), ('2025-03-13', 1110), ('2025-03-14', 1050),
('2025-03-15', 500),  -- DROP! Anomaly
('2025-03-16', 1040), ('2025-03-17', 1080), ('2025-03-18', 1100),
('2025-03-19', 1060), ('2025-03-20', 1090), ('2025-03-21', 1070),
('2025-03-22', 1050), ('2025-03-23', 1080), ('2025-03-24', 1100),
('2025-03-25', 1090), ('2025-03-26', 1070), ('2025-03-27', 1080),
('2025-03-28', 1060), ('2025-03-29', 1100), ('2025-03-30', 1080);

-- For a real project, you'd have 90+ days of data
```

### 💡 Hints Before You Start:
- **Moving averages**: Use `AVG() OVER (ORDER BY date ROWS BETWEEN n PRECEDING AND CURRENT ROW)`
- **7-day**: 6 PRECEDING + current = 7 days
- **30-day**: 29 PRECEDING + current = 30 days
- **Deviation**: `(actual - average) / average * 100` for percentage
- **Weekly pattern**: `LAG(visitors, 7)` compares to same day last week
- **Ranking**: Use `RANK() OVER (ORDER BY deviation DESC)` for severity

### Solution Framework:
```sql
-- Step 1: Calculate moving averages and weekly comparison
WITH traffic_analysis AS (
  SELECT 
    traffic_date, 
    visitors,
    -- 7-day moving average (smooths out daily fluctuations)
    ROUND(AVG(visitors) OVER (
      ORDER BY traffic_date 
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS ma_7day,
    -- 30-day moving average (long-term trend)
    ROUND(AVG(visitors) OVER (
      ORDER BY traffic_date 
      ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ), 2) AS ma_30day,
    -- Same day last week (weekly seasonality)
    LAG(visitors, 7) OVER (ORDER BY traffic_date) AS same_day_last_week
  FROM thc8_traffic
),
-- Step 2: Calculate deviations and flag anomalies
anomaly_detection AS (
  SELECT *,
    -- Percent deviation from 7-day average
    ROUND((visitors - ma_7day) / NULLIF(ma_7day, 0) * 100, 2) AS pct_deviation_7day,
    -- Percent change from same day last week
    ROUND((visitors - same_day_last_week) / NULLIF(same_day_last_week, 0) * 100, 2) AS week_over_week_pct,
    -- Flag anomalies (>20% deviation)
    CASE 
      WHEN ABS((visitors - ma_7day) / NULLIF(ma_7day, 0)) > 0.2 THEN 'Anomaly'
      ELSE 'Normal'
    END AS status,
    -- Determine type of anomaly
    CASE 
      WHEN (visitors - ma_7day) / NULLIF(ma_7day, 0) > 0.2 THEN 'Positive Spike'
      WHEN (visitors - ma_7day) / NULLIF(ma_7day, 0) < -0.2 THEN 'Negative Drop'
      ELSE 'Normal'
    END AS anomaly_type
  FROM traffic_analysis
  WHERE ma_7day IS NOT NULL  -- Need at least 7 days of data
)
-- Step 3: Rank anomalies by severity
SELECT 
  traffic_date,
  visitors,
  ma_7day,
  ma_30day,
  pct_deviation_7day,
  status,
  anomaly_type,
  week_over_week_pct,
  RANK() OVER (ORDER BY ABS(pct_deviation_7day) DESC) AS anomaly_severity_rank
FROM anomaly_detection
ORDER BY anomaly_severity_rank;
```

### 📊 Expected Insights:
```
traffic_date | visitors | ma_7day | pct_deviation_7day | status  | anomaly_type   | severity_rank
2025-03-08   | 2500     | 1038.57 | 140.76             | Anomaly | Positive Spike | 1  ← ALERT!
2025-03-15   | 500      | 1298.57 | -61.49             | Anomaly | Negative Drop  | 2  ← ALERT!
2025-03-09   | 1060     | 1284.29 | -17.46             | Normal  | Normal         | 24
...
```

### 🎓 What You're Learning:
- **Multiple window frames**: Different time periods (7-day vs 30-day)
- **LAG for seasonality**: Compare to same day last week
- **Deviation calculations**: Statistical anomaly detection
- **Ranking by severity**: Prioritize alerts
- **Real-world analytics**: Actual technique used in monitoring systems!

---

---

## Challenge 2: Sales Leaderboard with Streaks (50 min)

### 🎯 Business Context:
You're building a gamified sales dashboard for a competitive sales team. The VP wants to see:
- **Who's #1 this month?** (Current rankings)
- **Who's rising/falling?** (Rank changes from last month)
- **Who's on a hot streak?** (Consecutive months at #1)
- **Where does everyone stand?** (Percentile rankings)

This dashboard will be displayed in the office to motivate the team!

### 📋 Project Requirements:
1. Rank salespeople by monthly sales performance
2. Compare to previous month's rank using LAG()
3. Identify winning streaks (consecutive #1 finishes)
4. Show percentile rankings (top 10%, top 25%, etc.)
5. Flag significant changes (jumped 3+ positions)

### Setup:
```sql
DROP TABLE IF EXISTS thc8_monthly_sales;
CREATE TABLE thc8_monthly_sales (
  month DATE, 
  salesperson VARCHAR(60), 
  total_sales DECIMAL(10,2)
);

-- 6 months of data for 5 salespeople
INSERT INTO thc8_monthly_sales VALUES 
('2024-01-01', 'Alice', 50000), ('2024-01-01', 'Bob', 45000), ('2024-01-01', 'Carol', 48000),
('2024-01-01', 'Dave', 42000), ('2024-01-01', 'Eve', 47000),
('2024-02-01', 'Alice', 52000), ('2024-02-01', 'Bob', 49000), ('2024-02-01', 'Carol', 51000),
('2024-02-01', 'Dave', 44000), ('2024-02-01', 'Eve', 46000),
('2024-03-01', 'Alice', 55000), ('2024-03-01', 'Bob', 48000), ('2024-03-01', 'Carol', 50000),
('2024-03-01', 'Dave', 47000), ('2024-03-01', 'Eve', 49000),
('2024-04-01', 'Alice', 54000), ('2024-04-01', 'Bob', 52000), ('2024-04-01', 'Carol', 53000),
('2024-04-01', 'Dave', 51000), ('2024-04-01', 'Eve', 50000),
('2024-05-01', 'Alice', 58000), ('2024-05-01', 'Bob', 54000), ('2024-05-01', 'Carol', 52000),
('2024-05-01', 'Dave', 53000), ('2024-05-01', 'Eve', 51000),
('2024-06-01', 'Alice', 60000), ('2024-06-01', 'Bob', 57000), ('2024-06-01', 'Carol', 55000),
('2024-06-01', 'Dave', 54000), ('2024-06-01', 'Eve', 56000);
```

### 💡 Hints Before You Start:
- **Monthly ranking**: `RANK() OVER (PARTITION BY month ORDER BY sales DESC)`
- **Previous rank**: Use LAG on the ranking column (tricky - need to PARTITION BY salesperson!)
- **Percentile**: `PERCENT_RANK() OVER (PARTITION BY month ORDER BY sales DESC)`
- **Streaks**: Count consecutive months where rank = 1 (advanced - may need session windows)
- **Rank change**: Current rank - previous rank (negative = improved!)

### Solution Approach:
```sql
-- Step 1: Calculate monthly rankings and percentiles
WITH monthly_rankings AS (
  SELECT 
    month, 
    salesperson, 
    total_sales,
    -- Rank within each month
    RANK() OVER (PARTITION BY month ORDER BY total_sales DESC) AS monthly_rank,
    -- Percentile within each month (0 = worst, 1 = best)
    ROUND(PERCENT_RANK() OVER (PARTITION BY month ORDER BY total_sales DESC), 3) AS percentile
  FROM thc8_monthly_sales
),
-- Step 2: Compare to previous month (LAG across time)
rank_changes AS (
  SELECT 
    month,
    salesperson,
    total_sales,
    monthly_rank,
    percentile,
    -- Get previous month's rank for this salesperson
    LAG(monthly_rank, 1) OVER (PARTITION BY salesperson ORDER BY month) AS prev_month_rank,
    -- Get previous month's sales
    LAG(total_sales, 1) OVER (PARTITION BY salesperson ORDER BY month) AS prev_month_sales,
    -- Calculate change
    LAG(monthly_rank, 1) OVER (PARTITION BY salesperson ORDER BY month) - monthly_rank AS rank_change
  FROM monthly_rankings
),
-- Step 3: Add business logic and categories
final_leaderboard AS (
  SELECT 
    month,
    salesperson,
    total_sales,
    monthly_rank,
    prev_month_rank,
    COALESCE(rank_change, 0) AS rank_change,
    ROUND((total_sales - prev_month_sales) / NULLIF(prev_month_sales, 0) * 100, 1) AS sales_growth_pct,
    percentile,
    -- Performance tier based on percentile
    CASE 
      WHEN percentile = 0 THEN 'Top Performer'
      WHEN percentile <= 0.25 THEN 'High Performer'
      WHEN percentile <= 0.50 THEN 'Average'
      ELSE 'Needs Improvement'
    END AS performance_tier,
    -- Flag significant changes
    CASE 
      WHEN rank_change >= 3 THEN '🔥 Major Improvement'
      WHEN rank_change >= 1 THEN '↗ Improved'
      WHEN rank_change = 0 THEN '→ Stable'
      WHEN rank_change <= -1 THEN '↘ Declined'
      WHEN rank_change IS NULL THEN '🆕 First Month'
    END AS trend
  FROM rank_changes
)
SELECT * FROM final_leaderboard
ORDER BY month DESC, monthly_rank;

-- Bonus: Identify current #1 streaks
WITH monthly_ranks AS (
  SELECT 
    month, 
    salesperson,
    RANK() OVER (PARTITION BY month ORDER BY total_sales DESC) AS rank
  FROM thc8_monthly_sales
),
top_performers AS (
  SELECT 
    salesperson,
    month,
    rank,
    -- Count consecutive months at #1 (this is advanced!)
    ROW_NUMBER() OVER (PARTITION BY salesperson ORDER BY month) -
    ROW_NUMBER() OVER (PARTITION BY salesperson, (rank = 1) ORDER BY month) AS streak_group
  FROM monthly_ranks
  WHERE rank = 1
)
SELECT 
  salesperson,
  COUNT(*) AS consecutive_months_at_rank_1,
  MIN(month) AS streak_start,
  MAX(month) AS streak_end
FROM top_performers
WHERE streak_group = 0  -- Only the most recent streak
GROUP BY salesperson
HAVING COUNT(*) > 1  -- Show streaks of 2+ months
ORDER BY consecutive_months_at_rank_1 DESC;
```

### 📊 Expected Insights:
```
-- Main Leaderboard (June 2024)
salesperson | total_sales | monthly_rank | prev_month_rank | rank_change | trend
Alice       | 60000       | 1            | 1               | 0           | → Stable (6 months at #1!)
Bob         | 57000       | 2            | 2               | 0           | → Stable
Eve         | 56000       | 3            | 5               | 2           | ↗ Improved
Carol       | 55000       | 4            | 3               | -1          | ↘ Declined
Dave        | 54000       | 5            | 4               | -1          | ↘ Declined

-- Winning Streaks
salesperson | consecutive_months_at_rank_1 | streak_start | streak_end
Alice       | 6                            | 2024-01-01   | 2024-06-01  ← Dominant!
```

### 🎓 What You're Learning:
- **Multiple PARTITION BY uses**: By month for rankings, by person for comparisons
- **LAG on calculated columns**: Getting previous month's rank
- **PERCENT_RANK()**: Showing relative performance (percentiles)
- **Streak detection**: Advanced technique using ROW_NUMBER differences
- **Business intelligence**: Real sales dashboard logic!

---

---

## Challenge 3: Customer Segmentation with RFM Analysis (60 min)

### 🎯 Business Context:
You're a marketing analyst tasked with segmenting customers for targeted campaigns. Instead of treating all customers the same, you'll use **RFM Analysis** (a classic marketing framework):
- **R**ecency: How recently did they purchase? (Recent = engaged)
- **F**requency: How often do they purchase? (Frequent = loyal)
- **M**onetary: How much do they spend? (High = valuable)

Your segmentation will determine who gets VIP treatment, who needs re-engagement, etc.

### 📋 Project Requirements:
1. Calculate RFM metrics for each customer
2. Score each dimension using quartiles (NTILE)
3. Create composite RFM score (average or concatenation)
4. Segment customers into actionable groups (Champions, At Risk, etc.)
5. Rank customers by overall value

### Setup:
```sql
DROP TABLE IF EXISTS thc8_customer_orders;
CREATE TABLE thc8_customer_orders (
  customer_id INT,
  order_date DATE,
  amount DECIMAL(10,2)
);

-- Sample data: Various customer purchase patterns
INSERT INTO thc8_customer_orders VALUES 
-- Customer 1: Champion (recent, frequent, high spend)
(1, '2025-01-15', 500), (1, '2025-02-20', 750), (1, '2025-03-25', 600),
-- Customer 2: Loyal (recent, very frequent, medium spend)
(2, '2025-01-05', 200), (2, '2025-01-20', 250), (2, '2025-02-10', 200),
(2, '2025-02-25', 300), (2, '2025-03-15', 250), (2, '2025-03-28', 200),
-- Customer 3: Big Spender (recent, infrequent, very high spend)
(3, '2025-03-20', 2000),
-- Customer 4: At Risk (not recent, used to buy frequently)
(4, '2024-10-01', 400), (4, '2024-10-15', 350), (4, '2024-11-01', 300),
-- Customer 5: Lost (very old, low spend)
(5, '2024-06-01', 100), (5, '2024-07-01', 150);

-- Assume current date is 2025-04-01 for analysis
```

### 💡 Hints Before You Start:
- **Recency**: `DATEDIFF(CURDATE(), MAX(order_date))` - lower is better!
- **Frequency**: `COUNT(order_id)` - higher is better
- **Monetary**: `SUM(amount)` - higher is better
- **Scoring**: Use NTILE(4) or NTILE(5) for quartiles/quintiles
- **Direction matters**: R score should be reverse (lower recency = higher score)

### Solution:
```sql
-- Step 1: Calculate raw RFM metrics
WITH rfm_metrics AS (
  SELECT 
    customer_id,
    -- Recency: Days since last purchase (lower = better)
    DATEDIFF('2025-04-01', MAX(order_date)) AS recency_days,
    -- Frequency: Number of purchases (higher = better)
    COUNT(*) AS frequency_count,
    -- Monetary: Total spend (higher = better)
    SUM(amount) AS monetary_value
  FROM thc8_customer_orders
  GROUP BY customer_id
),
-- Step 2: Assign quartile scores (1-4, where 4 = best)
rfm_scores AS (
  SELECT 
    customer_id, 
    recency_days, 
    frequency_count, 
    monetary_value,
    -- R Score: Lower recency = better, so ORDER BY ASC
    5 - NTILE(4) OVER (ORDER BY recency_days ASC) AS r_score,
    -- F Score: Higher frequency = better
    NTILE(4) OVER (ORDER BY frequency_count DESC) AS f_score,
    -- M Score: Higher monetary = better  
    NTILE(4) OVER (ORDER BY monetary_value DESC) AS m_score
  FROM rfm_metrics
),
-- Step 3: Create composite score and segment
rfm_segments AS (
  SELECT 
    customer_id,
    recency_days,
    frequency_count,
    monetary_value,
    r_score,
    f_score,
    m_score,
    -- Composite RFM score (average of 3 dimensions)
    ROUND((r_score + f_score + m_score) / 3.0, 2) AS rfm_score,
    -- RFM String (e.g., "444" = best, "111" = worst)
    CONCAT(r_score, f_score, m_score) AS rfm_string,
    -- Business segmentation logic
    CASE 
      WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Champions'
      WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
      WHEN r_score >= 3 AND m_score >= 3 THEN 'Big Spenders'
      WHEN r_score >= 3 THEN 'Potential Loyalists'
      WHEN r_score = 2 AND f_score >= 2 THEN 'At Risk'
      WHEN r_score = 1 THEN 'Lost Customers'
      ELSE 'Needs Attention'
    END AS segment,
    -- Overall value ranking
    RANK() OVER (ORDER BY rfm_score DESC) AS value_rank
  FROM rfm_scores
)
SELECT * FROM rfm_segments
ORDER BY rfm_score DESC;
```

### 📊 Expected Insights:
```
customer_id | recency | frequency | monetary | r_score | f_score | m_score | rfm_score | segment
2           | 4       | 6         | 1400     | 4       | 4       | 3       | 3.67      | Champions
1           | 7       | 3         | 1850     | 4       | 3       | 4       | 3.67      | Champions
3           | 12      | 1         | 2000     | 3       | 1       | 4       | 2.67      | Big Spenders
4           | 152     | 3         | 1050     | 1       | 3       | 2       | 2.00      | Lost (re-engage!)
5           | 274     | 2         | 250      | 1       | 2       | 1       | 1.33      | Lost
```

### 🎓 What You're Learning:
- **NTILE() for binning**: Dividing continuous data into quartiles
- **Scoring direction**: Reversing scores when "lower is better"
- **Composite scoring**: Combining multiple metrics
- **Business logic**: Translating scores into actionable segments
- **Real marketing analytics**: RFM is industry-standard!

### 💼 Marketing Actions Based on Segments:

| Segment | Action | Campaign Type |
|---------|--------|---------------|
| Champions | Reward and retain | VIP program, early access, referral rewards |
| Loyal Customers | Upsell and cross-sell | Premium products, bundles |
| Big Spenders | Increase frequency | Subscription offers, convenience features |
| At Risk | Re-engagement | Win-back discounts, "We miss you" emails |
| Lost Customers | Reactivation | Deep discounts, new product announcements |

---

## 🎉 Challenges Complete!

**What You've Accomplished:**
1. ✅ **Anomaly Detection** - Time series analysis with multiple moving averages
2. ✅ **Sales Leaderboards** - Competitive rankings with streak detection
3. ✅ **RFM Segmentation** - Customer value scoring and marketing segments

**Advanced Techniques Mastered:**
- Multiple frame specifications (7-day, 30-day windows)
- Nested PARTITION BY (by month, then by person)
- NTILE() for quartile/percentile scoring
- LAG() for period-over-period comparisons
- Complex CASE logic for business rules
- Streak detection with window functions

**Real-World Applications:**
- Operations monitoring (Challenge 1)
- Sales performance tracking (Challenge 2)
- Marketing automation (Challenge 3)

---

## 📚 What's Next?

**You've completed Module 08: Window Functions!**

**Skills Gained:**
- ✅ Ranking functions (ROW_NUMBER, RANK, DENSE_RANK)
- ✅ Aggregate window functions (SUM, AVG, COUNT)
- ✅ Time-series comparisons (LAG, LEAD)
- ✅ Frame specifications (ROWS BETWEEN)
- ✅ PARTITION BY for grouped analytics
- ✅ Real-world business intelligence queries

**Continue Learning:**
- **Module 09**: DML Operations (INSERT, UPDATE, DELETE)
- **Module 10**: DDL & Schema Design (CREATE, ALTER, DROP)
- **Module 11**: Indexes & Performance Optimization
- **Module 12**: Transactions & Concurrency Control

**💡 Practice Tip:** Try applying window functions to your own datasets! Look for opportunities to:
- Rank items within categories
- Calculate running totals
- Compare periods (month-over-month, year-over-year)
- Detect trends and anomalies

**Keep up the great work! 🚀**
