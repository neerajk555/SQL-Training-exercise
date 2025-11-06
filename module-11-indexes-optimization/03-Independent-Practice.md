# Independent Practice — Indexes & Optimization

**Beginner Instructions:**
1. Run the setup code to create tables
2. Use EXPLAIN to analyze slow queries
3. Create appropriate indexes
4. Verify improvement with EXPLAIN
5. Compare rows scanned before/after

---

## Exercise 1: Blog Platform Optimization (Easy)

**Scenario:** You're a backend developer for a blog platform. Users complain that searching for posts by category is slow. Your job is to identify the problem and optimize the queries!

**Business Impact:** 
- Users wait 2-3 seconds for search results
- High bounce rate (users leaving the site)
- Need to speed up category search and author queries

```sql
DROP TABLE IF EXISTS ip11_posts;
CREATE TABLE ip11_posts (
  post_id INT AUTO_INCREMENT PRIMARY KEY,
  author_id INT,
  title VARCHAR(200),
  category VARCHAR(50),
  published_date DATE,
  views INT DEFAULT 0
);

-- Insert 1000 posts (across 20 authors, 4 categories)
INSERT INTO ip11_posts (author_id, title, category, published_date, views)
SELECT 
  1 + MOD(n, 20) AS author_id,
  CONCAT('Post Title ', n) AS title,
  ELT(MOD(n, 4) + 1, 'Tech', 'Lifestyle', 'Travel', 'Food') AS category,
  DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY) AS published_date,
  FLOOR(RAND() * 10000) AS views
FROM (
  SELECT @row := @row + 1 AS n 
  FROM 
    (SELECT 0 UNION ALL SELECT 1) t1, 
    (SELECT 0 UNION ALL SELECT 1) t2, 
    (SELECT 0 UNION ALL SELECT 1) t3, 
    (SELECT 0 UNION ALL SELECT 1) t4,
    (SELECT 0 UNION ALL SELECT 1) t5, 
    (SELECT 0 UNION ALL SELECT 1) t6,
    (SELECT 0 UNION ALL SELECT 1) t7, 
    (SELECT 0 UNION ALL SELECT 1) t8,
    (SELECT 0 UNION ALL SELECT 1) t9, 
    (SELECT 0 UNION ALL SELECT 1) t10,
    (SELECT @row := 0) r
) numbers
LIMIT 1000;

-- Verify data distribution
SELECT category, COUNT(*) AS post_count 
FROM ip11_posts 
GROUP BY category;

SELECT COUNT(*) AS total_posts FROM ip11_posts;
```

**Your Tasks:**

**Task 1:** Analyze and optimize category search with sorting
```sql
-- Slow query: Get Tech posts sorted by most views
SELECT * FROM ip11_posts 
WHERE category = 'Tech' 
ORDER BY views DESC;
```

**Task 2:** Optimize author + date range query
```sql
-- Slow query: Get author 5's posts from 2025
SELECT * FROM ip11_posts 
WHERE author_id = 5 
AND published_date >= '2025-01-01';
```

**Task 3:** Verify both indexes with EXPLAIN

---

**💡 Hints for Beginners:**
- Use EXPLAIN before creating indexes to see the baseline
- For queries with WHERE + ORDER BY, consider composite indexes
- Column order matters: filtering column first, sorting column second
- Check the `type` and `Extra` columns in EXPLAIN output

---

**Solution:**

```sql
-- ============================================
-- Task 1: Optimize category search with sorting
-- ============================================

-- Step 1: Analyze the slow query
EXPLAIN SELECT * FROM ip11_posts 
WHERE category = 'Tech' 
ORDER BY views DESC;

-- 📊 Before optimization:
-- type: ALL (full table scan - scanning 1000 rows!)
-- rows: 1000
-- Extra: Using where; Using filesort (slow sorting!)

-- Step 2: Create composite index (category + views)
-- Why? Category filters rows, views sorts them
CREATE INDEX idx_category_views ON ip11_posts(category, views);

-- Step 3: Verify improvement
EXPLAIN SELECT * FROM ip11_posts 
WHERE category = 'Tech' 
ORDER BY views DESC;

-- 📊 After optimization:
-- type: ref (uses index!)
-- key: idx_category_views
-- rows: ~250 (only Tech posts)
-- Extra: Backward index scan (no filesort needed!)

-- ✅ Result: 4x fewer rows scanned, no slow sorting!

-- ============================================
-- Task 2: Optimize author + date query
-- ============================================

-- Step 1: Analyze the query
EXPLAIN SELECT * FROM ip11_posts 
WHERE author_id = 5 
AND published_date >= '2025-01-01';

-- 📊 Before optimization:
-- type: ALL
-- rows: 1000
-- Extra: Using where

-- Step 2: Create composite index (author_id + date)
-- Why? Author filters first, date filters second
CREATE INDEX idx_author_date ON ip11_posts(author_id, published_date);

-- Step 3: Verify improvement
EXPLAIN SELECT * FROM ip11_posts 
WHERE author_id = 5 
AND published_date >= '2025-01-01';

-- 📊 After optimization:
-- type: range (uses index for range query!)
-- key: idx_author_date
-- rows: ~20 (only author 5's recent posts)

-- ✅ Result: 50x fewer rows scanned!

-- ============================================
-- Task 3: Review all indexes
-- ============================================

SHOW INDEXES FROM ip11_posts;

-- You should see:
-- PRIMARY (on post_id)
-- idx_category_views (on category, views)
-- idx_author_date (on author_id, published_date)
```

**🎓 What You Learned:**
1. ✅ Composite indexes handle WHERE + ORDER BY efficiently
2. ✅ Column order matters: filter first, then sort
3. ✅ "Using filesort" in EXPLAIN means slow sorting
4. ✅ "type: ref" or "type: range" means index is being used
5. ✅ Always verify with EXPLAIN before and after!

---

## Exercise 2: Social Media Feed (Medium)

**Scenario:** You're optimizing a social media app. The timeline feed query (showing posts from users you follow) is very slow. With 100 users and 500 posts, it takes 2+ seconds!

**Business Impact:**
- Users wait too long for their feed to load
- High server CPU usage
- Need to optimize: timeline feed and trending posts

```sql
DROP TABLE IF EXISTS ip11_posts_social, ip11_follows;

CREATE TABLE ip11_posts_social (
  post_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  content TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  like_count INT DEFAULT 0
);

CREATE TABLE ip11_follows (
  follower_id INT,
  following_id INT,
  followed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (follower_id, following_id)
);

-- Insert 500 posts from 100 different users
INSERT INTO ip11_posts_social (user_id, content, like_count)
SELECT 
  1 + MOD(n, 100) AS user_id,
  CONCAT('Post content ', n) AS content,
  FLOOR(RAND() * 1000) AS like_count
FROM (
  SELECT @row := @row + 1 AS n 
  FROM 
    (SELECT 0 UNION ALL SELECT 1) t1, 
    (SELECT 0 UNION ALL SELECT 1) t2,
    (SELECT 0 UNION ALL SELECT 1) t3, 
    (SELECT 0 UNION ALL SELECT 1) t4,
    (SELECT 0 UNION ALL SELECT 1) t5, 
    (SELECT 0 UNION ALL SELECT 1) t6,
    (SELECT 0 UNION ALL SELECT 1) t7, 
    (SELECT 0 UNION ALL SELECT 1) t8,
    (SELECT 0 UNION ALL SELECT 1) t9,
    (SELECT @row := 0) r
) numbers
LIMIT 500;

-- User 1 follows 20 users (users 2-21)
INSERT INTO ip11_follows (follower_id, following_id)
SELECT 1 AS follower_id, n AS following_id
FROM (
  SELECT @row := @row + 1 AS n 
  FROM 
    (SELECT 0 UNION ALL SELECT 1) t1, 
    (SELECT 0 UNION ALL SELECT 1) t2,
    (SELECT 0 UNION ALL SELECT 1) t3, 
    (SELECT 0 UNION ALL SELECT 1) t4,
    (SELECT 0 UNION ALL SELECT 1) t5,
    (SELECT @row := 1) r
) numbers
LIMIT 20; 
-- Verify data
SELECT COUNT(*) AS total_posts FROM ip11_posts_social;
SELECT COUNT(*) AS users_followed FROM ip11_follows WHERE follower_id = 1;
```

**Your Tasks:**

**Task 1:** Optimize the timeline feed query (posts from followed users, newest first)
```sql
-- Slow query: Get user 1's timeline feed
SELECT p.* 
FROM ip11_posts_social p
JOIN ip11_follows f ON p.user_id = f.following_id
WHERE f.follower_id = 1
ORDER BY p.created_at DESC 
LIMIT 20;
```

**Task 2:** Optimize trending posts (most liked posts from last 7 days)
```sql
-- Slow query: Get trending posts
SELECT * 
FROM ip11_posts_social
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY like_count DESC 
LIMIT 10;
```

**Task 3:** Verify both optimizations with EXPLAIN

---

**💡 Hints:**
- The `follows` table already has a PRIMARY KEY on (follower_id, following_id)
- For JOINs, index the column you're joining ON
- For queries with WHERE + ORDER BY, consider composite indexes
- DATE comparisons benefit from indexes on date columns

---

**Solution:**

```sql
-- ============================================
-- Task 1: Optimize timeline feed (JOIN + ORDER BY)
-- ============================================

-- Step 1: Analyze the slow query
EXPLAIN SELECT p.* 
FROM ip11_posts_social p
JOIN ip11_follows f ON p.user_id = f.following_id
WHERE f.follower_id = 1
ORDER BY p.created_at DESC 
LIMIT 20;

-- 📊 Before optimization:
-- posts_social: type: ALL (full table scan!)
-- rows: 500 (checking every post!)
-- Extra: Using filesort

-- Step 2: Add composite index (user_id + created_at)
-- Why? JOIN uses user_id, ORDER BY uses created_at
CREATE INDEX idx_user_created ON ip11_posts_social(user_id, created_at);

-- Step 3: Verify improvement
EXPLAIN SELECT p.* 
FROM ip11_posts_social p
JOIN ip11_follows f ON p.user_id = f.following_id
WHERE f.follower_id = 1
ORDER BY p.created_at DESC 
LIMIT 20;

-- 📊 After optimization:
-- follows: type: ref (uses PRIMARY KEY)
-- posts_social: type: ref (uses idx_user_created!)
-- rows: ~5 per followed user (20 users × 5 posts = 100 rows instead of 500)
-- Extra: Backward index scan (no filesort!)

-- ✅ Result: 5x fewer rows scanned, no slow sorting!

-- ============================================
-- Task 2: Optimize trending posts
-- ============================================

-- Step 1: Analyze the query
EXPLAIN SELECT * 
FROM ip11_posts_social
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY like_count DESC 
LIMIT 10;

-- 📊 Before optimization:
-- type: ALL
-- rows: 500
-- Extra: Using where; Using filesort

-- Step 2: Create composite index (created_at + like_count)
-- Why? Filter by date first, then sort by likes
CREATE INDEX idx_created_likes ON ip11_posts_social(created_at, like_count);

-- Step 3: Verify improvement
EXPLAIN SELECT * 
FROM ip11_posts_social
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY like_count DESC 
LIMIT 10;

-- 📊 After optimization:
-- type: range (uses index for date range!)
-- key: idx_created_likes
-- rows: ~50 (only recent posts)
-- Extra: Using index condition; Backward index scan

-- ✅ Result: 10x fewer rows scanned, efficient sorting!

-- ============================================
-- Review your work
-- ============================================

SHOW INDEXES FROM ip11_posts_social;
SHOW INDEXES FROM ip11_follows;

-- Test the queries again and see the speed difference!
SELECT p.* 
FROM ip11_posts_social p
JOIN ip11_follows f ON p.user_id = f.following_id
WHERE f.follower_id = 1
ORDER BY p.created_at DESC 
LIMIT 20;
```

**🎓 What You Learned:**
1. ✅ Always index foreign key columns used in JOINs
2. ✅ Composite indexes can eliminate filesort
3. ✅ Date range queries benefit from indexes
4. ✅ "Backward index scan" means efficient DESC sorting
5. ✅ PRIMARY KEY on multiple columns acts as a composite index

---

## Exercise 3: Analytics Dashboard (Hard)

**Scenario:** You're building an analytics dashboard for an e-commerce company. The dashboard queries are timing out with large sales data. You need to optimize aggregate queries (GROUP BY, SUM) using strategic indexes.

**Business Impact:**
- Dashboard takes 10+ seconds to load
- Reports timing out during peak hours
- Need to optimize: monthly revenue reports and top products

**Database Setup:**

```sql
DROP TABLE IF EXISTS ip11_sales;

CREATE TABLE ip11_sales (
  sale_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT,
  category VARCHAR(50),
  sale_date DATE,
  quantity INT,
  unit_price DECIMAL(10,2),
  total_amount DECIMAL(10,2),
  region VARCHAR(50)
);

-- Insert 5000 sales records (simulating a large dataset)
-- In real life, this would be 100K+ rows
INSERT INTO ip11_sales (product_id, category, sale_date, quantity, unit_price, total_amount, region)
SELECT 
  1 + MOD(n, 50) AS product_id,
  ELT(MOD(n, 5) + 1, 'Electronics', 'Clothing', 'Books', 'Home', 'Sports') AS category,
  DATE_SUB(CURDATE(), INTERVAL MOD(n, 365) DAY) AS sale_date,
  1 + FLOOR(RAND() * 10) AS quantity,
  ROUND(10 + RAND() * 490, 2) AS unit_price,
  ROUND((1 + FLOOR(RAND() * 10)) * (10 + RAND() * 490), 2) AS total_amount,
  ELT(MOD(n, 4) + 1, 'North', 'South', 'East', 'West') AS region
FROM (
  SELECT @row := @row + 1 AS n 
  FROM 
    (SELECT 0 UNION ALL SELECT 1) t1,
    (SELECT 0 UNION ALL SELECT 1) t2,
    (SELECT 0 UNION ALL SELECT 1) t3,
    (SELECT 0 UNION ALL SELECT 1) t4,
    (SELECT 0 UNION ALL SELECT 1) t5,
    (SELECT 0 UNION ALL SELECT 1) t6,
    (SELECT 0 UNION ALL SELECT 1) t7,
    (SELECT 0 UNION ALL SELECT 1) t8,
    (SELECT 0 UNION ALL SELECT 1) t9,
    (SELECT 0 UNION ALL SELECT 1) t10,
    (SELECT 0 UNION ALL SELECT 1) t11,
    (SELECT 0 UNION ALL SELECT 1) t12,
    (SELECT @row := 0) r
) numbers
LIMIT 5000;

-- Verify data
SELECT COUNT(*) AS total_sales FROM ip11_sales;
SELECT category, COUNT(*) AS sales_count 
FROM ip11_sales 
GROUP BY category;
```

**Your Tasks:**

**Task 1:** Optimize monthly revenue by category
```sql
-- Slow query: Get revenue per category per month
SELECT 
  category,
  DATE_FORMAT(sale_date, '%Y-%m') AS month,
  SUM(total_amount) AS revenue,
  COUNT(*) AS sales_count
FROM ip11_sales
GROUP BY category, DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY month DESC, category;
```

**Task 2:** Optimize top products by revenue
```sql
-- Slow query: Top 10 products by revenue
SELECT 
  product_id,
  category,
  SUM(total_amount) AS total_revenue,
  SUM(quantity) AS total_quantity
FROM ip11_sales
GROUP BY product_id, category
ORDER BY total_revenue DESC
LIMIT 10;
```

**Task 3:** Optimize regional sales analysis
```sql
-- Slow query: Sales by region and category
SELECT 
  region,
  category,
  SUM(total_amount) AS revenue
FROM ip11_sales
WHERE sale_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
GROUP BY region, category;
```

---

**💡 Advanced Hints:**
- Indexes can't help much with SUM/COUNT calculations (MySQL still needs to read rows)
- But indexes CAN help GROUP BY avoid sorting
- Covering indexes can answer queries without accessing the table
- Column order in composite indexes matters for GROUP BY too!

---

**Solution:**

```sql
-- ============================================
-- Task 1: Monthly revenue by category
-- ============================================

-- Step 1: Analyze the query
EXPLAIN SELECT 
  category,
  DATE_FORMAT(sale_date, '%Y-%m') AS month,
  SUM(total_amount) AS revenue,
  COUNT(*) AS sales_count
FROM ip11_sales
GROUP BY category, DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY month DESC, category;

-- 📊 Before optimization:
-- type: ALL (full table scan)
-- rows: 5000
-- Extra: Using temporary; Using filesort

-- Step 2: Create composite index for GROUP BY columns
-- Order matters: category and sale_date are grouped together
CREATE INDEX idx_category_date ON ip11_sales(category, sale_date);

-- Step 3: Verify improvement
EXPLAIN SELECT 
  category,
  DATE_FORMAT(sale_date, '%Y-%m') AS month,
  SUM(total_amount) AS revenue,
  COUNT(*) AS sales_count
FROM ip11_sales
GROUP BY category, DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY month DESC, category;

-- 📊 After optimization:
-- key: idx_category_date
-- Extra: Using index (reads sorted data from index!)

-- Note: MySQL still must calculate SUM/COUNT, but GROUP BY is faster

-- ============================================
-- Task 2: Top products by revenue
-- ============================================

-- Step 1: Analyze
EXPLAIN SELECT 
  product_id,
  category,
  SUM(total_amount) AS total_revenue,
  SUM(quantity) AS total_quantity
FROM ip11_sales
GROUP BY product_id, category
ORDER BY total_revenue DESC
LIMIT 10;

-- 📊 Before optimization:
-- type: ALL
-- Extra: Using temporary; Using filesort

-- Step 2: Create composite index
-- Include all columns needed for the query (covering index!)
CREATE INDEX idx_product_category_amount 
ON ip11_sales(product_id, category, total_amount, quantity);

-- Step 3: Verify
EXPLAIN SELECT 
  product_id,
  category,
  SUM(total_amount) AS total_revenue,
  SUM(quantity) AS total_quantity
FROM ip11_sales
GROUP BY product_id, category
ORDER BY total_revenue DESC
LIMIT 10;

-- 📊 After optimization:
-- key: idx_product_category_amount
-- Extra: Using index (covering index - no table access!)

-- ✅ This is a COVERING INDEX - all columns are in the index!

-- ============================================
-- Task 3: Regional sales with date filter
-- ============================================

-- Step 1: Analyze
EXPLAIN SELECT 
  region,
  category,
  SUM(total_amount) AS revenue
FROM ip11_sales
WHERE sale_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
GROUP BY region, category;

-- 📊 Before optimization:
-- type: ALL
-- rows: 5000
-- Extra: Using where; Using temporary

-- Step 2: Create composite index (date first for WHERE filter)
CREATE INDEX idx_date_region_category 
ON ip11_sales(sale_date, region, category);

-- Step 3: Verify
EXPLAIN SELECT 
  region,
  category,
  SUM(total_amount) AS revenue
FROM ip11_sales
WHERE sale_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
GROUP BY region, category;

-- 📊 After optimization:
-- type: range (uses index for date filter!)
-- key: idx_date_region_category
-- rows: ~400 (only last 90 days)

-- ✅ Filters by date first, then groups efficiently!

-- ============================================
-- Review and cleanup
-- ============================================

SHOW INDEXES FROM ip11_sales;

-- Test queries to see performance improvement
SELECT 
  category,
  DATE_FORMAT(sale_date, '%Y-%m') AS month,
  SUM(total_amount) AS revenue
FROM ip11_sales
GROUP BY category, month
ORDER BY month DESC
LIMIT 10;

SELECT 
  product_id,
  SUM(total_amount) AS revenue
FROM ip11_sales
GROUP BY product_id
ORDER BY revenue DESC
LIMIT 5;
```

**🎓 Advanced Concepts You Learned:**

1. **Covering Indexes** → Include all SELECT columns in the index
   - MySQL doesn't need to access the table at all!
   - Trade-off: Larger index size

2. **GROUP BY Optimization** → Indexes help avoid temporary tables
   - Index columns in the same order as GROUP BY
   - Reduces "Using temporary" overhead

3. **Multi-Purpose Indexes** → One index can help multiple queries
   - `idx_category_date` helps both filtering and grouping

4. **Column Order Strategy:**
   - WHERE columns first (most selective)
   - Then GROUP BY columns
   - Finally ORDER BY columns

5. **When Indexes Don't Help:**
   - Aggregate functions (SUM, COUNT) still need to read data
   - Indexes help with finding/grouping rows, not calculating totals
   - But they can avoid table access with covering indexes!

**🚀 Performance Tips:**
- Covering indexes are powerful but use more disk space
- Monitor index size vs. performance gain
- Too many indexes slow down INSERT/UPDATE
- Use EXPLAIN to verify indexes are actually used!

