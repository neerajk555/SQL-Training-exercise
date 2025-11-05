# Error Detective — Indexes & Optimization

**🎯 Goal:** Learn to identify and fix common indexing mistakes that cause slow queries!

**💡 For Each Error:**
1. Read the problematic code
2. Identify what's wrong
3. Understand why it's slow
4. Apply the fix
5. Verify with EXPLAIN

---

## Error 1: Function on Indexed Column ❌

```sql
CREATE INDEX idx_name ON users(name);
SELECT * FROM users WHERE UPPER(name) = 'ALICE';
```

**Issue:** Function on indexed column prevents index use - full table scan!

**Why This is Wrong:**
MySQL can't use the index because `UPPER(name)` transforms the column. The index is on `name`, not `UPPER(name)`.

**✅ Fix:** Remove function or use functional index (MySQL 8.0+)
```sql
-- Fix 1: Search without function
SELECT * FROM users WHERE name = 'Alice';

-- Fix 2: MySQL 8.0+ functional index
CREATE INDEX idx_name_upper ON users((UPPER(name)));
SELECT * FROM users WHERE UPPER(name) = 'ALICE';
```

**Key Lesson:** Never use functions on indexed columns in WHERE clauses!

---

## Error 2: Wrong Column Order in Composite Index ❌

```sql
CREATE INDEX idx_date_customer ON orders(order_date, customer_id);
SELECT * FROM orders WHERE customer_id = 1 AND order_date >= '2025-01-01';
```

**Issue:** Index not fully utilized because customer_id is the second column.

**Why This is Wrong:**
Composite indexes work like a phone book: organized by (LastName, FirstName). You can find "Smith" or "Smith, John", but you can't efficiently find all "Johns" without a last name. Similarly, this index on (order_date, customer_id) can't efficiently find customer_id alone.

**✅ Fix:** Put the most selective (most filtered) column first
```sql
-- Correct order: customer_id first (filters to one customer), then date
CREATE INDEX idx_customer_date ON orders(customer_id, order_date);

-- Now this query uses both columns efficiently!
SELECT * FROM orders WHERE customer_id = 1 AND order_date >= '2025-01-01';
```

**Key Lesson:** Column order matters! Put filtering columns before sorting/range columns.

---

## Error 3: Over-Indexing (Redundant Indexes) ❌

```sql
CREATE INDEX idx1 ON products(category);
CREATE INDEX idx2 ON products(category, price);
CREATE INDEX idx3 ON products(category, price, stock);
```

**Issue:** idx2 and idx3 make idx1 redundant - wasting disk space and slowing writes!

**Why This is Wrong:**
- idx3 (category, price, stock) can handle ALL queries that idx1 and idx2 can handle
- Extra indexes waste disk space
- Every INSERT/UPDATE/DELETE must update ALL three indexes (slower writes)

**✅ Fix:** Keep only idx3 (covers all query patterns)
```sql
-- Drop redundant indexes
DROP INDEX idx1 ON products;
DROP INDEX idx2 ON products;

-- Keep only the most comprehensive index
-- idx3 handles:
--   - WHERE category = 'X'
--   - WHERE category = 'X' AND price > 100
--   - WHERE category = 'X' AND price > 100 AND stock > 10
```

**Key Lesson:** Composite indexes cover single-column queries on their first column. Don't create redundant indexes!

---

## Error 4: Indexing Low-Cardinality Column ❌

```sql
CREATE INDEX idx_status ON orders(status);
-- status only has 3 values: pending, shipped, delivered
```

**Issue:** Index not selective enough - MySQL might ignore it!

**Why This is Wrong:**
- With only 3 distinct values, each value appears in ~33% of rows
- Scanning 33% of a table is almost as slow as scanning 100%
- MySQL might decide a full table scan is faster than using the index!

**Beginner Explanation:**
Imagine a phone book where everyone has the same last name (Smith, Smith, Smith...). The index doesn't help you narrow down the search!

**✅ Fix:** Only index if combined with high-cardinality column
```sql
-- Remove single-column index on low-cardinality column
DROP INDEX idx_status ON orders;

-- Instead, create composite index with selective column first
CREATE INDEX idx_customer_status ON orders(customer_id, status);

-- This helps: WHERE customer_id = 1 AND status = 'pending'
```

**Key Lesson:** Don't index columns with few distinct values (gender, status, boolean flags). They're not selective enough!

---

## Error 5: Missing Foreign Key Index ❌

```sql
CREATE TABLE order_items (
  item_id INT PRIMARY KEY,
  order_id INT,
  product_id INT,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
-- No index on order_id! No index on product_id!
```

**Issue:** JOINs on order_id and product_id will be extremely slow - full table scan for every join!

**Why This is Wrong:**
```sql
-- This query scans ALL order_items for EACH order (N×M complexity!)
SELECT o.*, oi.*
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;
```

**✅ Fix:** ALWAYS index foreign key columns
```sql
-- Add indexes on all foreign key columns
CREATE INDEX idx_order_id ON order_items(order_id);
CREATE INDEX idx_product_id ON order_items(product_id);

-- Now JOINs are fast - index lookups instead of table scans!
```

**Key Lesson:** Foreign key columns should ALWAYS be indexed - this is a golden rule of database design!

---

## Error 6: Using LIKE with Leading Wildcard ❌

```sql
CREATE INDEX idx_email ON users(email);

-- This query is SLOW despite the index!
SELECT * FROM users WHERE email LIKE '%@gmail.com';
```

**Issue:** Leading wildcard (%) prevents index use - full table scan!

**Why This is Wrong:**
- Indexes work like a dictionary - you can quickly find words starting with "cat"
- But you can't quickly find all words ending with "cat" without reading the whole dictionary
- `LIKE '%@gmail.com'` searches for anything ending with @gmail.com - index can't help!

**✅ Fix:** Remove leading wildcard or redesign query
```sql
-- ✅ This uses the index:
SELECT * FROM users WHERE email LIKE 'john%';  -- Finds john@gmail.com, johnny@...

-- ❌ This does NOT use the index:
SELECT * FROM users WHERE email LIKE '%@gmail.com';  -- Scans all rows

-- Alternative: Store domain separately for efficient filtering
ALTER TABLE users ADD COLUMN email_domain VARCHAR(100);
UPDATE users SET email_domain = SUBSTRING_INDEX(email, '@', -1);
CREATE INDEX idx_domain ON users(email_domain);

-- Now this is fast:
SELECT * FROM users WHERE email_domain = 'gmail.com';
```

**Key Lesson:** Avoid leading wildcards in LIKE queries. Use trailing wildcards only!

---

## 🎓 Summary of Common Mistakes

| Error | Problem | Solution |
|-------|---------|----------|
| Functions on columns | `WHERE UPPER(name) = 'X'` | Remove function or use functional index |
| Wrong column order | `idx(date, customer)` for `WHERE customer = X` | Put filtered column first |
| Redundant indexes | Multiple overlapping indexes | Keep only most comprehensive |
| Low-cardinality index | Index on status (3 values) | Only index in composite with selective column |
| Missing FK index | No index on foreign keys | Always index foreign keys |
| Leading wildcard | `LIKE '%value'` | Use `LIKE 'value%'` or redesign |

---

## 🔍 Practice Exercise

Find and fix the errors in this schema:

```sql
CREATE TABLE blog_posts (
  post_id INT PRIMARY KEY,
  author_id INT,
  title VARCHAR(200),
  content TEXT,
  status VARCHAR(20),  -- 'draft', 'published'
  created_at TIMESTAMP
);

CREATE INDEX idx1 ON blog_posts(author_id);
CREATE INDEX idx2 ON blog_posts(author_id, created_at);
CREATE INDEX idx3 ON blog_posts(status);
CREATE INDEX idx4 ON blog_posts(title);

-- Common queries:
-- 1. WHERE author_id = X ORDER BY created_at DESC
-- 2. WHERE status = 'published' AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
-- 3. WHERE title LIKE '%keyword%'
```

<details>
<summary>Solution</summary>

**Problems:**
1. idx1 is redundant (covered by idx2)
2. idx3 on low-cardinality column (only 2 values)
3. idx4 on title won't help with `LIKE '%keyword%'`

**Fix:**
```sql
-- Drop redundant/useless indexes
DROP INDEX idx1 ON blog_posts;  -- idx2 covers this
DROP INDEX idx3 ON blog_posts;  -- Only 2 values (not selective)
DROP INDEX idx4 ON blog_posts;  -- Can't help with leading wildcard

-- Keep this index for Query 1
-- idx2 already exists: (author_id, created_at)

-- Add composite index for Query 2
CREATE INDEX idx_status_date ON blog_posts(created_at, status);
-- created_at first (more selective than 2-value status)

-- For Query 3: Full-text search is better
ALTER TABLE blog_posts ADD FULLTEXT INDEX idx_title_fulltext(title);
-- Use: WHERE MATCH(title) AGAINST('keyword')
```

</details>

