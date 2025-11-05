# Speed Drills — Indexes & Optimization (2 min each)

**🎯 Goal:** Build muscle memory for index operations. Complete each drill in under 2 minutes!

---

## Drill 1: Create Simple Index
**Task:** Create an index on email column

**Answer:**
```sql
CREATE INDEX idx_email ON users(email);
```

---

## Drill 2: Analyze Query Performance
**Task:** Use EXPLAIN to analyze a query

**Answer:**
```sql
EXPLAIN SELECT * FROM products WHERE category = 'Electronics';
```
**Check:** Look for `type: ref` (good) vs `type: ALL` (bad)

---

## Drill 3: Create Composite Index
**Task:** Index category and price together

**Answer:**
```sql
CREATE INDEX idx_category_price ON products(category, price);
```
**Why:** Optimizes filtering + sorting on both columns

---

## Drill 4: Drop Index
**Task:** Remove an unused index

**Answer:**
```sql
DROP INDEX idx_old ON table_name;
```

---

## Drill 5: Show All Indexes
**Task:** Display all indexes on a table

**Answer:**
```sql
SHOW INDEXES FROM products;
```

---

## Drill 6: Create Unique Index
**Task:** Enforce uniqueness on email

**Answer:**
```sql
CREATE UNIQUE INDEX idx_unique_email ON users(email);
```
**Bonus:** Prevents duplicates + speeds up queries

---

## Drill 7: Create Prefix Index
**Task:** Index first 100 chars of URL

**Answer:**
```sql
CREATE INDEX idx_url_prefix ON articles(url(100));
```
**Why:** Saves space on long VARCHAR columns

---

## Drill 8: Create Covering Index
**Task:** Include all query columns in index

**Answer:**
```sql
CREATE INDEX idx_covering ON users(user_id, email, name);
```
**Result:** MySQL reads only index, not table!

---

## Drill 9: Check Index Usage
**Task:** Verify query uses an index

**Answer:**
```sql
EXPLAIN SELECT * FROM orders WHERE customer_id = 1;
```
**Check:** `key` column shows index name (not NULL)

---

## Drill 10: Optimize Foreign Key JOIN
**Task:** Index a foreign key column

**Answer:**
```sql
CREATE INDEX idx_order_id ON order_items(order_id);
```
**Rule:** ALWAYS index foreign keys!

---

## 🏆 Challenge: Complete All 10 in Under 15 Minutes!

