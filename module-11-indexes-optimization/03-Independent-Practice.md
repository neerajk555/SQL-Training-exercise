# Independent Practice — Indexes & Optimization

## Exercise 1: Blog Platform Optimization (Easy) — 20 min

**Scenario:** Blog with slow post search queries.

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

-- Insert 1000 posts
INSERT INTO ip11_posts (author_id, title, category, published_date, views)
SELECT 
  1 + MOD(n, 20),
  CONCAT('Post Title ', n),
  ELT(MOD(n, 4) + 1, 'Tech', 'Lifestyle', 'Travel', 'Food'),
  DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY),
  FLOOR(RAND() * 10000)
FROM (SELECT @row := @row + 1 AS n FROM 
      (SELECT 0 UNION SELECT 1) t1, (SELECT 0 UNION SELECT 1) t2, 
      (SELECT 0 UNION SELECT 1) t3, (SELECT 0 UNION SELECT 1) t4,
      (SELECT 0 UNION SELECT 1) t5, (SELECT 0 UNION SELECT 1) t6,
      (SELECT 0 UNION SELECT 1) t7, (SELECT 0 UNION SELECT 1) t8,
      (SELECT 0 UNION SELECT 1) t9, (SELECT 0 UNION SELECT 1) t10,
      (SELECT @row := 0) r) numbers
LIMIT 1000;
```

**Requirements:**
1. Analyze query: `SELECT * FROM ip11_posts WHERE category = 'Tech' ORDER BY views DESC`
2. Add appropriate index(es)
3. Verify with EXPLAIN that index is used
4. Optimize: `SELECT * FROM ip11_posts WHERE author_id = 5 AND published_date >= '2025-01-01'`

**Solution:**
```sql
-- 1. Analyze slow query
EXPLAIN SELECT * FROM ip11_posts WHERE category = 'Tech' ORDER BY views DESC;
-- type: ALL, Extra: Using filesort

-- 2. Create composite index for category + views
CREATE INDEX idx_category_views ON ip11_posts(category, views);

-- 3. Verify
EXPLAIN SELECT * FROM ip11_posts WHERE category = 'Tech' ORDER BY views DESC;
-- type: ref, no filesort!

-- 4. Optimize author + date query
CREATE INDEX idx_author_date ON ip11_posts(author_id, published_date);

EXPLAIN SELECT * FROM ip11_posts 
WHERE author_id = 5 AND published_date >= '2025-01-01';
-- Uses idx_author_date, type: range
```

---

## Exercise 2: Social Media Feed (Medium) — 30 min

**Scenario:** Social network with slow timeline queries.

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

-- Test data
INSERT INTO ip11_posts_social (user_id, content, like_count)
SELECT 
  1 + MOD(n, 100),
  CONCAT('Post content ', n),
  FLOOR(RAND() * 1000)
FROM (SELECT @row := @row + 1 AS n FROM 
      (SELECT 0 UNION SELECT 1) t1, (SELECT 0 UNION SELECT 1) t2,
      (SELECT 0 UNION SELECT 1) t3, (SELECT 0 UNION SELECT 1) t4,
      (SELECT 0 UNION SELECT 1) t5, (SELECT @row := 0) r) numbers
LIMIT 500;

INSERT INTO ip11_follows (follower_id, following_id)
SELECT 1, n FROM (SELECT @row := @row + 1 AS n FROM 
      (SELECT 0 UNION SELECT 1) t1, (SELECT 0 UNION SELECT 1) t2,
      (SELECT 0 UNION SELECT 1) t3, (SELECT @row := 1) r) numbers
LIMIT 20;
```

**Requirements:**
1. Optimize: Get posts from users that user_id 1 follows, ordered by recency
2. Add indexes to speed up JOIN
3. Optimize: Most liked posts from last 7 days

**Solution:**
```sql
-- 1. Analyze feed query
EXPLAIN SELECT p.* FROM ip11_posts_social p
JOIN ip11_follows f ON p.user_id = f.following_id
WHERE f.follower_id = 1
ORDER BY p.created_at DESC LIMIT 20;

-- 2. Add indexes
CREATE INDEX idx_user_created ON ip11_posts_social(user_id, created_at);
-- follows already has PK on (follower_id, following_id)

-- 3. Optimize trending posts
CREATE INDEX idx_created_likes ON ip11_posts_social(created_at, like_count);

EXPLAIN SELECT * FROM ip11_posts_social
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY like_count DESC LIMIT 10;
```

---

## Exercise 3: Analytics Dashboard (Hard) — 40 min

**Scenario:** Dashboard with slow aggregate queries on large dataset.

**Requirements:**
1. Table with 100K+ rows of sales data
2. Query: Monthly revenue by category
3. Query: Top products by revenue
4. Optimize both queries with appropriate indexes

**Hints:**
- Consider covering indexes
- Composite indexes for grouping columns
- Test with EXPLAIN

**Solution:** Design indexes that minimize table scans for GROUP BY operations.

