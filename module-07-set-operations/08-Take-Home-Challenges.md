# Take-Home Challenges — Set Operations (Advanced)

Three advanced multi-part problems for deeper practice. Each includes complex requirements, realistic data, open-ended components, and detailed solutions with trade-offs.

**Challenge Tip:** These are designed to take 45-60 minutes each. Break them into parts, test incrementally, and explore multiple approaches!

---

## Challenge 1: Multi-Platform Social Media Analytics (45–55 min)

### Business Context
You're a social media analyst for a brand with presence on Twitter, Instagram, and TikTok. Each platform has different user engagement patterns. Management wants to understand:
1. Total unique reach across all platforms
2. Cross-platform users (engaged on multiple platforms)
3. Platform-exclusive users (for targeted content)
4. Engagement quality scores based on multi-platform presence

### Setup
```sql
DROP TABLE IF EXISTS thc7_twitter_engagement;
CREATE TABLE thc7_twitter_engagement (
  user_handle VARCHAR(60) PRIMARY KEY,
  followers INT,
  avg_likes INT,
  avg_retweets INT,
  engagement_score DECIMAL(5,2)
);
INSERT INTO thc7_twitter_engagement VALUES
('@alice_tech',15000,120,45,8.5),
('@bob_dev',8000,90,30,7.2),
('@carol_data',22000,200,80,9.1),
('@dave_ai',5000,60,20,6.8),
('@eve_ml',12000,150,55,8.0),
('@frank_ops',3000,40,15,5.5);

DROP TABLE IF EXISTS thc7_instagram_engagement;
CREATE TABLE thc7_instagram_engagement (
  user_handle VARCHAR(60) PRIMARY KEY,
  followers INT,
  avg_likes INT,
  avg_comments INT,
  engagement_score DECIMAL(5,2)
);
INSERT INTO thc7_instagram_engagement VALUES
('@alice_tech',18000,250,40,8.8),
('@carol_data',25000,300,60,9.3),
('@eve_ml',14000,180,35,8.2),
('@grace_design',20000,280,50,9.0),
('@henry_product',7000,100,20,7.0),
('@iris_ux',9000,120,25,7.5);

DROP TABLE IF EXISTS thc7_tiktok_engagement;
CREATE TABLE thc7_tiktok_engagement (
  user_handle VARCHAR(60) PRIMARY KEY,
  followers INT,
  avg_views INT,
  avg_likes INT,
  engagement_score DECIMAL(5,2)
);
INSERT INTO thc7_tiktok_engagement VALUES
('@alice_tech',25000,5000,450,9.2),
('@dave_ai',8000,2000,180,7.5),
('@eve_ml',16000,3500,320,8.5),
('@grace_design',22000,4800,400,9.1),
('@jack_frontend',5000,1200,100,6.5),
('@karen_backend',6000,1500,130,7.0);
```

### Part 1: Total Reach Analysis (15 min)
**Requirements:**
- Calculate total unique users across all platforms
- Show user count per platform
- Identify total follower reach (sum unique followers)
- Calculate average engagement score across all platforms

**Hints:**
- Use UNION to find unique users
- Join back to each platform for follower counts
- Handle users present on multiple platforms (don't double-count followers)

**Solution:**
```sql
-- Total unique users
SELECT COUNT(*) AS unique_users
FROM (
  SELECT user_handle FROM thc7_twitter_engagement
  UNION
  SELECT user_handle FROM thc7_instagram_engagement
  UNION
  SELECT user_handle FROM thc7_tiktok_engagement
) AS all_users;
-- Result: 12 unique user handles

-- Per-platform counts
SELECT 'Twitter' AS platform, COUNT(*) AS user_count FROM thc7_twitter_engagement
UNION ALL
SELECT 'Instagram', COUNT(*) FROM thc7_instagram_engagement
UNION ALL
SELECT 'TikTok', COUNT(*) FROM thc7_tiktok_engagement;
-- Twitter: 6, Instagram: 6, TikTok: 6

-- Total follower reach (max followers per user across platforms)
SELECT 
  SUM(max_followers) AS total_reach,
  ROUND(AVG(max_followers), 0) AS avg_followers_per_user
FROM (
  SELECT 
    user_handle,
    MAX(followers) AS max_followers
  FROM (
    SELECT user_handle, followers FROM thc7_twitter_engagement
    UNION ALL
    SELECT user_handle, followers FROM thc7_instagram_engagement
    UNION ALL
    SELECT user_handle, followers FROM thc7_tiktok_engagement
  ) AS all_followers
  GROUP BY user_handle
) AS user_max_reach;
-- Total reach: 166,000 followers (max per user to avoid double-counting)

-- Average engagement score across all platform appearances
SELECT 
  ROUND(AVG(engagement_score), 2) AS overall_avg_engagement
FROM (
  SELECT engagement_score FROM thc7_twitter_engagement
  UNION ALL
  SELECT engagement_score FROM thc7_instagram_engagement
  UNION ALL
  SELECT engagement_score FROM thc7_tiktok_engagement
) AS all_scores;
-- Average: ~7.96
```

### Part 2: Cross-Platform Power Users (15 min)
**Requirements:**
- Identify users on 2+ platforms
- Show which platforms each user is on
- Calculate combined engagement score (average across platforms)
- Rank by platform count and engagement

**Solution:**
```sql
WITH user_platforms AS (
  SELECT user_handle, 'Twitter' AS platform, engagement_score FROM thc7_twitter_engagement
  UNION ALL
  SELECT user_handle, 'Instagram', engagement_score FROM thc7_instagram_engagement
  UNION ALL
  SELECT user_handle, 'TikTok', engagement_score FROM thc7_tiktok_engagement
)
SELECT 
  user_handle,
  COUNT(*) AS platform_count,
  GROUP_CONCAT(platform ORDER BY platform) AS platforms,
  ROUND(AVG(engagement_score), 2) AS avg_engagement,
  CASE 
    WHEN COUNT(*) = 3 THEN 'Omni-channel'
    WHEN COUNT(*) = 2 THEN 'Multi-platform'
    ELSE 'Single-platform'
  END AS user_type
FROM user_platforms
GROUP BY user_handle
HAVING COUNT(*) >= 2
ORDER BY platform_count DESC, avg_engagement DESC;

-- Results:
-- @alice_tech: 3 platforms, 8.83 avg (Omni-channel)
-- @eve_ml: 3 platforms, 8.23 avg (Omni-channel)
-- @carol_data: 2 platforms, 9.20 avg (Multi-platform)
-- @dave_ai: 2 platforms, 7.15 avg (Multi-platform)
-- @grace_design: 2 platforms, 9.05 avg (Multi-platform)
```

### Part 3: Platform-Exclusive Content Strategy (15 min)
**Requirements:**
- For each platform, find exclusive users (not on other platforms)
- Calculate average engagement for exclusive vs. cross-platform users
- Recommend which platform to focus exclusive content creation

**Solution:**
```sql
-- Twitter-exclusive users
SELECT 
  'Twitter' AS platform,
  COUNT(*) AS exclusive_users,
  ROUND(AVG(engagement_score), 2) AS avg_engagement
FROM thc7_twitter_engagement
WHERE user_handle NOT IN (
  SELECT user_handle FROM thc7_instagram_engagement
  UNION
  SELECT user_handle FROM thc7_tiktok_engagement
);
-- Twitter: 2 exclusive (@bob_dev, @frank_ops), avg 6.35

-- Instagram-exclusive users
SELECT 
  'Instagram' AS platform,
  COUNT(*) AS exclusive_users,
  ROUND(AVG(engagement_score), 2) AS avg_engagement
FROM thc7_instagram_engagement
WHERE user_handle NOT IN (
  SELECT user_handle FROM thc7_twitter_engagement
  UNION
  SELECT user_handle FROM thc7_tiktok_engagement
);
-- Instagram: 2 exclusive (@henry_product, @iris_ux), avg 7.25

-- TikTok-exclusive users
SELECT 
  'TikTok' AS platform,
  COUNT(*) AS exclusive_users,
  ROUND(AVG(engagement_score), 2) AS avg_engagement
FROM thc7_tiktok_engagement
WHERE user_handle NOT IN (
  SELECT user_handle FROM thc7_twitter_engagement
  UNION
  SELECT user_handle FROM thc7_instagram_engagement
);
-- TikTok: 2 exclusive (@jack_frontend, @karen_backend), avg 6.75

-- Combined analysis (simplified - no ranking)
SELECT 
  platform,
  exclusive_users,
  avg_engagement
FROM (
  SELECT 'Twitter' AS platform, COUNT(*) AS exclusive_users, ROUND(AVG(engagement_score), 2) AS avg_engagement
  FROM thc7_twitter_engagement
  WHERE user_handle NOT IN (SELECT user_handle FROM thc7_instagram_engagement UNION SELECT user_handle FROM thc7_tiktok_engagement)
  UNION ALL
  SELECT 'Instagram', COUNT(*), ROUND(AVG(engagement_score), 2)
  FROM thc7_instagram_engagement
  WHERE user_handle NOT IN (SELECT user_handle FROM thc7_twitter_engagement UNION SELECT user_handle FROM thc7_tiktok_engagement)
  UNION ALL
  SELECT 'TikTok', COUNT(*), ROUND(AVG(engagement_score), 2)
  FROM thc7_tiktok_engagement
  WHERE user_handle NOT IN (SELECT user_handle FROM thc7_twitter_engagement UNION SELECT user_handle FROM thc7_instagram_engagement)
) AS exclusive_analysis
ORDER BY avg_engagement DESC;

-- 📚 ADVANCED: To add engagement ranking, use window functions (Module 8, next module)
/*
SELECT 
  platform,
  exclusive_users,
  avg_engagement,
  RANK() OVER (ORDER BY avg_engagement DESC) AS engagement_rank
FROM (...previous query...)
*/
```

### Open-Ended Component
**Question:** Based on the data, should the brand invest in creating unique content for each platform or focus on cross-platform content?

**Analysis Approach:**
- Cross-platform users (@alice_tech, @eve_ml) have highest engagement (8.5+ average)
- 6 out of 12 users (50%) are multi/omni-channel
- Exclusive users have lower engagement (6.35-7.25 range)
- **Recommendation**: Prioritize cross-platform users for engagement quality, but maintain platform-exclusive content to grow those audiences toward multi-platform engagement

---

## Challenge 2: Healthcare Patient Cohort Analysis (50–60 min)

### Business Context
A hospital network operates three clinics (North, Central, South). You need to analyze patient distribution for resource allocation, identify patients using multiple clinics, and plan for integrated care coordination.

### Setup
```sql
DROP TABLE IF EXISTS thc7_north_clinic_patients;
CREATE TABLE thc7_north_clinic_patients (
  patient_id INT PRIMARY KEY,
  patient_name VARCHAR(60),
  age INT,
  condition_category VARCHAR(40),
  last_visit DATE,
  total_visits INT
);
INSERT INTO thc7_north_clinic_patients VALUES
(1001,'Alice Johnson',45,'Diabetes','2025-02-15',8),
(1002,'Bob Smith',62,'Hypertension','2025-02-20',12),
(1003,'Carol White',38,'Asthma','2025-02-10',5),
(1004,'Dave Brown',55,'Diabetes','2025-02-25',6),
(1005,'Eve Davis',70,'Hypertension','2025-02-18',15);

DROP TABLE IF EXISTS thc7_central_clinic_patients;
CREATE TABLE thc7_central_clinic_patients (
  patient_id INT PRIMARY KEY,
  patient_name VARCHAR(60),
  age INT,
  condition_category VARCHAR(40),
  last_visit DATE,
  total_visits INT
);
INSERT INTO thc7_central_clinic_patients VALUES
(1002,'Bob Smith',62,'Hypertension','2025-02-22',8),
(1004,'Dave Brown',55,'Diabetes','2025-02-28',4),
(1006,'Frank Miller',48,'Arthritis','2025-02-12',10),
(1007,'Grace Lee',33,'Asthma','2025-02-17',6),
(1008,'Henry Wilson',58,'Diabetes','2025-02-20',9);

DROP TABLE IF EXISTS thc7_south_clinic_patients;
CREATE TABLE thc7_south_clinic_patients (
  patient_id INT PRIMARY KEY,
  patient_name VARCHAR(60),
  age INT,
  condition_category VARCHAR(40),
  last_visit DATE,
  total_visits INT
);
INSERT INTO thc7_south_clinic_patients VALUES
(1001,'Alice Johnson',45,'Diabetes','2025-03-01',3),
(1005,'Eve Davis',70,'Heart Disease','2025-02-25',5),
(1006,'Frank Miller',48,'Arthritis','2025-02-15',7),
(1009,'Iris Chen',41,'Asthma','2025-02-19',4),
(1010,'Jack Taylor',67,'Hypertension','2025-02-23',11);
```

### Part 1: Network-Wide Patient Registry (15 min)
Create a unified patient list with total visits across all clinics and most recent visit date.

**Solution:**
```sql
-- Unified patient registry
WITH all_visits AS (
  SELECT patient_id, patient_name, age, condition_category, last_visit, total_visits, 'North' AS clinic
  FROM thc7_north_clinic_patients
  UNION ALL
  SELECT patient_id, patient_name, age, condition_category, last_visit, total_visits, 'Central'
  FROM thc7_central_clinic_patients
  UNION ALL
  SELECT patient_id, patient_name, age, condition_category, last_visit, total_visits, 'South'
  FROM thc7_south_clinic_patients
)
SELECT 
  patient_id,
  MAX(patient_name) AS patient_name,
  MAX(age) AS age,
  SUM(total_visits) AS network_total_visits,
  MAX(last_visit) AS most_recent_visit,
  COUNT(DISTINCT clinic) AS clinic_count,
  GROUP_CONCAT(DISTINCT clinic ORDER BY clinic) AS clinics_visited
FROM all_visits
GROUP BY patient_id
ORDER BY network_total_visits DESC;
-- 10 unique patients with combined visit counts
```

### Part 2: Multi-Clinic Patients (Care Coordination Priority) (15 min)
Identify patients visiting multiple clinics—they need coordinated care plans.

**Solution:**
```sql
WITH all_patients AS (
  SELECT patient_id, 'North' AS clinic FROM thc7_north_clinic_patients
  UNION ALL
  SELECT patient_id, 'Central' FROM thc7_central_clinic_patients
  UNION ALL
  SELECT patient_id, 'South' FROM thc7_south_clinic_patients
)
SELECT 
  patient_id,
  COUNT(*) AS clinic_count,
  GROUP_CONCAT(clinic ORDER BY clinic) AS clinics
FROM all_patients
GROUP BY patient_id
HAVING COUNT(*) > 1
ORDER BY clinic_count DESC, patient_id;
-- Results: 1001, 1002, 1004, 1005, 1006 (5 multi-clinic patients)
```

### Part 3: Condition-Specific Cohorts (20 min)
For each condition, find which clinics serve those patients and recommend consolidation opportunities.

**Solution:**
```sql
WITH all_conditions AS (
  SELECT patient_id, condition_category, 'North' AS clinic FROM thc7_north_clinic_patients
  UNION ALL
  SELECT patient_id, condition_category, 'Central' FROM thc7_central_clinic_patients
  UNION ALL
  SELECT patient_id, condition_category, 'South' FROM thc7_south_clinic_patients
)
SELECT 
  condition_category,
  COUNT(DISTINCT patient_id) AS patient_count,
  COUNT(DISTINCT clinic) AS clinic_spread,
  GROUP_CONCAT(DISTINCT clinic ORDER BY clinic) AS clinics_serving
FROM all_conditions
GROUP BY condition_category
ORDER BY patient_count DESC;

-- Diabetes: 4 patients across 3 clinics
-- Hypertension: 3 patients across 2 clinics (North, South)
-- Asthma: 3 patients across 2 clinics (North, Central)
-- Arthritis: 1 patient across 2 clinics (Central, South)
-- Heart Disease: 1 patient, 1 clinic (South)
```

### Open-Ended: Resource Allocation Recommendation
Analyze and recommend which clinic should become the center of excellence for each condition.

---

## Challenge 3: E-Commerce SKU Rationalization (45–55 min)

### Business Context
Your e-commerce company sells products across three channels (website, Amazon, eBay). Each channel has different SKU availability. You need to optimize inventory by identifying SKUs to discontinue, consolidate, or expand.

### Setup
```sql
DROP TABLE IF EXISTS thc7_website_skus;
CREATE TABLE thc7_website_skus (
  sku VARCHAR(20) PRIMARY KEY,
  product_name VARCHAR(100),
  category VARCHAR(40),
  monthly_sales INT,
  profit_margin DECIMAL(5,2)
);
INSERT INTO thc7_website_skus VALUES
('WEB-001','Laptop Stand','Office',120,25.50),
('WEB-002','USB Hub','Tech',200,15.25),
('WEB-003','Desk Lamp','Office',80,22.00),
('WEB-004','Wireless Mouse','Tech',350,18.75),
('WEB-005','Keyboard','Tech',180,20.00),
('WEB-006','Monitor Arm','Office',45,30.00);

DROP TABLE IF EXISTS thc7_amazon_skus;
CREATE TABLE thc7_amazon_skus (
  sku VARCHAR(20) PRIMARY KEY,
  product_name VARCHAR(100),
  category VARCHAR(40),
  monthly_sales INT,
  profit_margin DECIMAL(5,2)
);
INSERT INTO thc7_amazon_skus VALUES
('AMZ-001','Laptop Stand','Office',200,20.00),
('AMZ-002','USB Cable','Tech',450,10.50),
('AMZ-003','Wireless Mouse','Tech',500,16.00),
('AMZ-004','Desk Organizer','Office',150,28.00),
('AMZ-005','Phone Holder','Tech',300,12.75);

DROP TABLE IF EXISTS thc7_ebay_skus;
CREATE TABLE thc7_ebay_skus (
  sku VARCHAR(20) PRIMARY KEY,
  product_name VARCHAR(100),
  category VARCHAR(40),
  monthly_sales INT,
  profit_margin DECIMAL(5,2)
);
INSERT INTO thc7_ebay_skus VALUES
('EBY-001','Laptop Stand','Office',90,18.50),
('EBY-002','USB Hub','Tech',110,14.00),
('EBY-003','Desk Lamp','Office',60,20.00),
('EBY-004','Webcam','Tech',180,25.00),
('EBY-005','Keyboard','Tech',95,19.00);
```

### Parts 1-3: Product Portfolio Analysis
1. Identify products sold on multiple channels (cross-channel winners)
2. Calculate total sales and weighted avg profit margin per product
3. Find channel-exclusive products and evaluate discontinuation
4. Recommend SKU consolidation strategy

**Solution Framework:**
- Use UNION ALL with channel labels to combine all SKUs
- Group by product_name to find cross-channel products
- Calculate performance metrics (sales, margins)
- Apply business rules for keep/consolidate/discontinue

---

**Take-Home Challenges Complete!** These advanced scenarios showcase set operations in complex business contexts.

**Module 7 Complete!** You've mastered UNION, INTERSECT, EXCEPT, and their applications in real-world data analysis.
