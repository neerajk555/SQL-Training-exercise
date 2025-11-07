# Take-Home Challenges — Indexes & Optimization

## 📋 Before You Start

### Learning Objectives
By completing these take-home challenges, you will:
- Apply indexing strategies to optimize query performance
- Master EXPLAIN output analysis for bottleneck identification
- Research advanced index types (composite, covering, partial)
- Develop performance auditing and tuning methodology
- Learn to balance index benefits vs maintenance costs

### How to Approach Each Challenge
**Time Allocation (60-90 min per challenge):**
- 📖 **10 min**: Analyze the problem and understand table structures
- 🎯 **10 min**: Run EXPLAIN to identify missing indexes
- 💻 **35-60 min**: Add indexes, test performance, compare times
- ✅ **15 min**: Document findings and review index strategy

**Success Tips:**
- ✅ Always run EXPLAIN before and after indexing
- ✅ Test with realistic data volumes (1000+ rows)
- ✅ Consider composite indexes for multi-column WHERE/JOIN
- ✅ Use `SHOW INDEXES FROM table_name;` to verify index creation
- ✅ Document execution time improvements (e.g., 2.5s → 0.03s)
- ✅ Watch for "Using filesort" and "Using temporary" in EXPLAIN output

**⚠️ Performance Note:** Indexes speed up SELECT queries but slow down INSERT/UPDATE/DELETE. Balance carefully!

---

## 🎯 The Challenges

**💡 Instructions:** These challenges require research, experimentation, and documentation. Take your time and learn deeply!


---

## Challenge 1: Optimize Complex Multi-Table JOIN Query

**Difficulty:** ⭐⭐⭐ Intermediate

**Scenario:** You inherit a legacy reporting query that joins 5 tables and takes 30+ seconds to run.

### Your Tasks:

1. **Create the Schema** - Set up 5 tables:
   - `customers` (customer_id, name, email, city)
   - `orders` (order_id, customer_id, order_date, status)
   - `order_items` (item_id, order_id, product_id, quantity, price)
   - `products` (product_id, name, category_id, price)
   - `categories` (category_id, name)

2. **Generate Test Data** - Insert at least 1000 rows per table

3. **Write a Complex Query** - Join all 5 tables (e.g., "Get all customers who ordered products in 'Electronics' category in 2024")

4. **Identify Bottlenecks** - Run `EXPLAIN` and look for:
   - Full table scans (type: ALL)
   - Missing indexes on JOIN columns
   - "Using filesort" or "Using temporary"

5. **Add Indexes Strategically** - Add one index at a time:
   - Foreign keys (customer_id, product_id, etc.)
   - Columns in WHERE clause
   - Columns in ORDER BY

6. **Measure Performance** - Document execution time before and after each index

### Deliverable:
- ✅ SQL script with schema + test data
- ✅ Analysis report with EXPLAIN output (before/after)
- ✅ Performance improvement table
- ✅ Recommendations for which indexes to keep

**📚 Research Topics:** MySQL query optimizer, index selectivity, query execution plans

---

## Challenge 2: Index Strategy for Time-Series Data

**Difficulty:** ⭐⭐⭐⭐ Advanced

**Scenario:** You need to design indexing for an IoT sensor database with billions of rows that receives new data every second.

### Sample Schema:
```sql
CREATE TABLE sensor_readings (
  reading_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  sensor_id INT,
  timestamp DATETIME,
  temperature DECIMAL(5,2),
  humidity DECIMAL(5,2),
  pressure DECIMAL(6,2)
);
```

### Your Tasks:

1. **Research MySQL Partitioning** - Learn how to partition tables by date/range
2. **Design Partition Strategy** - Partition by month or week
3. **Plan Indexes for Common Queries:**
   - "Get all readings for sensor X in the last 24 hours"
   - "Get average temperature per sensor for last week"
   - "Find sensors with temperature > 100°C today"
4. **Balance Write vs Read Performance** - Indexes slow down INSERTs
5. **Consider Data Retention** - Archive old partitions

### Deliverable:
- ✅ Partitioning strategy document
- ✅ Index recommendations with reasoning
- ✅ Trade-off analysis (write performance vs query speed)

**📚 Research Topics:** Table partitioning, write amplification, time-series databases


---

## Challenge 3: Covering Index Cost-Benefit Analysis

**Difficulty:** ⭐⭐⭐ Intermediate

**Goal:** Decide if covering indexes are worth the extra disk space.

### What is a Covering Index?
A covering index includes ALL columns needed by a query, so MySQL doesn't need to read the actual table rows.

**Example:**
```sql
-- Query needs: product_id, name, price
-- Regular index: INDEX(category_id)
-- Covering index: INDEX(category_id, product_id, name, price)

SELECT product_id, name, price 
FROM products 
WHERE category_id = 5;
```

### Your Tasks:

1. **Create Test Query** - Pick a common query in your schema
2. **Measure with Regular Index:**
   - Query execution time
   - EXPLAIN output (check "Extra" column for "Using index")
3. **Create Covering Index** - Include all SELECT columns
4. **Measure Again:**
   - Query execution time improvement
   - Index size: `SELECT index_name, ROUND(SUM(stat_value * @@innodb_page_size) / 1024 / 1024, 2) as size_mb FROM mysql.innodb_index_stats GROUP BY index_name;`
5. **Calculate Trade-offs:**
   - Speed improvement (%)
   - Disk space cost (MB)
   - INSERT/UPDATE slowdown (test this!)

### Deliverable:
- ✅ Decision guide: "Use covering indexes when..."
- ✅ Cost-benefit table with real numbers

**📚 Research Topics:** Index-only scans, query optimization


---

## Challenge 4: Unused Index Detection Script

**Difficulty:** ⭐⭐⭐⭐ Advanced

**Goal:** Find indexes that are never used and safely remove them to improve write performance.

### Why This Matters:
Every index slows down INSERT/UPDATE/DELETE operations. Unused indexes waste disk space and memory.

### Your Tasks:

1. **Enable Performance Schema** (if not already on):
   ```sql
   -- Check if enabled
   SHOW VARIABLES LIKE 'performance_schema';
   ```

2. **Find Unused Indexes** - Query `sys.schema_unused_indexes`:
   ```sql
   SELECT * FROM sys.schema_unused_indexes;
   ```

3. **Verify Before Deleting:**
   - Check index age (maybe it's used monthly)
   - Review application code
   - Test in staging first

4. **Write Automation Script:**
   - Generate DROP INDEX statements
   - Add safety checks (don't drop PRIMARY KEY or UNIQUE)
   - Log dropped indexes for rollback

### Deliverable:
- ✅ SQL script to find unused indexes
- ✅ Safe deletion procedure document
- ✅ Rollback plan (CREATE INDEX statements to restore)

**⚠️ Warning:** Never drop indexes in production without testing!

**📚 Research Topics:** MySQL performance_schema, sys schema views


---

## Challenge 5: Query Rewriting for Index Compatibility

**Difficulty:** ⭐⭐ Beginner-Intermediate

**Goal:** Rewrite queries that can't use indexes to make them index-friendly.

### Problem Patterns:

#### Problem 1: Function on Indexed Column ❌
```sql
-- CAN'T use index on registration_date
SELECT * FROM users 
WHERE YEAR(registration_date) = 2025;
```

**Your Task:** Rewrite to use date ranges instead
<details>
<summary>💡 Hint</summary>

```sql
-- CAN use index on registration_date ✅
SELECT * FROM users 
WHERE registration_date >= '2025-01-01' 
  AND registration_date < '2026-01-01';
```
</details>

#### Problem 2: Leading Wildcard ❌
```sql
-- CAN'T use index on name
SELECT * FROM products 
WHERE name LIKE '%phone%';
```

**Your Task:** Consider FULLTEXT index or prefix search
<details>
<summary>💡 Hint</summary>

```sql
-- If searching from start: ✅
WHERE name LIKE 'phone%';

-- Or use FULLTEXT index
CREATE FULLTEXT INDEX idx_ft_name ON products(name);
SELECT * FROM products WHERE MATCH(name) AGAINST('phone');
```
</details>

#### Problem 3: OR Conditions on Different Columns ❌
```sql
-- CAN'T efficiently use indexes
SELECT * FROM orders 
WHERE status = 'pending' OR priority = 'high';
```

**Your Task:** Rewrite using UNION or rethink the query
<details>
<summary>💡 Hint</summary>

```sql
-- Use UNION ✅
SELECT * FROM orders WHERE status = 'pending'
UNION
SELECT * FROM orders WHERE priority = 'high';
```
</details>

### Deliverable:
- ✅ Rewritten queries for all 3 problems
- ✅ EXPLAIN comparisons (before/after)
- ✅ Execution time measurements

**📚 Research Topics:** Sargable queries, index selectivity


---

## Challenge 6: Composite Index Column Order Optimization

**Difficulty:** ⭐⭐⭐ Intermediate

**Goal:** Discover the optimal column order for composite indexes through testing.

### The Problem:
Index order matters! `INDEX(a, b, c)` is different from `INDEX(c, b, a)`.

**Rule of Thumb:** Most selective (unique) columns first, but it depends on query patterns!

### Your Tasks:

1. **Create Test Table:**
   ```sql
   CREATE TABLE products (
     product_id INT PRIMARY KEY,
     category VARCHAR(50),  -- 5 distinct values
     brand VARCHAR(50),     -- 20 distinct values
     price DECIMAL(10,2)    -- 100+ distinct values
   );
   ```

2. **Generate Test Data** - 10,000+ rows

3. **Test All Orderings for This Query:**
   ```sql
   SELECT * FROM products 
   WHERE category = 'Electronics' 
     AND brand = 'Sony' 
     AND price BETWEEN 100 AND 500;
   ```

4. **Create Different Index Orderings:**
   - `INDEX(category, brand, price)`
   - `INDEX(price, brand, category)`
   - `INDEX(brand, category, price)`
   - etc.

5. **Measure Each:**
   - Run EXPLAIN
   - Check rows examined
   - Measure execution time

### Deliverable:
- ✅ Performance table showing all orderings
- ✅ Decision tree: "If query has X, Y, Z filters, use order..."
- ✅ General guidelines document

**📚 Research Topics:** Index cardinality, leftmost prefix rule, index selectivity


---

## Challenge 7: Full-Text Search vs Regular Indexes

**Difficulty:** ⭐⭐⭐ Intermediate

**Goal:** Compare FULLTEXT indexes with regular indexes for text search and know when to use each.

### Setup:
```sql
CREATE TABLE articles (
  article_id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255),
  content TEXT,
  category VARCHAR(50)
);

-- Insert 1000+ articles
```

### Approach 1: Regular Index + LIKE
```sql
CREATE INDEX idx_title ON articles(title);

SELECT * FROM articles 
WHERE title LIKE '%keyword%';
```

### Approach 2: FULLTEXT Index
```sql
CREATE FULLTEXT INDEX idx_ft_title ON articles(title);

SELECT * FROM articles 
WHERE MATCH(title) AGAINST('keyword');
```

### Your Tasks:

1. **Test Both Approaches** with different search patterns:
   - Exact word: "database"
   - Multiple words: "database optimization"
   - Prefix: "data%"
   - Wildcard: "%data%"

2. **Measure:**
   - Query execution time
   - Rows examined (from EXPLAIN)
   - Index size
   - Relevance ranking (FULLTEXT has built-in scoring)

3. **Compare Features:**
   - FULLTEXT: Natural language search, boolean mode, relevance ranking
   - LIKE: Simple pattern matching, case sensitivity

### Deliverable:
- ✅ Performance comparison table
- ✅ Decision matrix: "Use FULLTEXT when...", "Use LIKE when..."
- ✅ Example queries for both approaches

**📚 Research Topics:** FULLTEXT search modes, natural language search, boolean search

---

## 📚 Additional Research Resources

### Official Documentation:
- [MySQL 8.0 Optimization Guide](https://dev.mysql.com/doc/refman/8.0/en/optimization.html)
- [EXPLAIN Output Format](https://dev.mysql.com/doc/refman/8.0/en/explain-output.html)
- [Table Partitioning](https://dev.mysql.com/doc/refman/8.0/en/partitioning.html)

### Recommended Books:
- "High Performance MySQL" by Baron Schwartz (O'Reilly)
- "SQL Performance Explained" by Markus Winand

### Tools to Explore:
- **MySQL Workbench** - Visual EXPLAIN and Query Profiler
- **Percona Toolkit** - pt-query-digest, pt-index-usage
- **phpMyAdmin** - Index advisor

---

## 🎓 How to Document Your Findings

For each challenge, create a structured report:

### 1. **Problem Analysis** (1 paragraph)
- What's the performance issue?
- What are the symptoms?

### 2. **Solution Design** (bullet points)
- Why did you choose this approach?
- What alternatives did you consider?

### 3. **Implementation** (SQL code)
```sql
-- Show your CREATE INDEX statements
-- Include test queries
```

### 4. **Testing Results** (table format)
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Execution Time | 2.5s | 0.03s | 98.8% |
| Rows Examined | 10,000 | 50 | 99.5% |
| Index Size | - | 2.5 MB | - |

### 5. **Conclusion** (2-3 sentences)
- What did you learn?
- What would you do differently?

---

## 🚀 Next Steps

After completing these challenges:

1. **Share Your Findings** - Present to your team or study group
2. **Apply to Real Projects** - Audit indexes in your current application
3. **Explore Advanced Topics:**
   - Covering indexes in detail
   - Index merge optimization
   - Invisible indexes (MySQL 8.0+)
   - Descending indexes

**Remember:** The best way to learn indexing is through experimentation. Don't be afraid to test different approaches!

---

**📝 Submission Checklist:**
- [ ] All SQL scripts are tested and working
- [ ] EXPLAIN outputs are documented
- [ ] Performance metrics are measured (before/after)
- [ ] Analysis reports are complete
- [ ] Learnings and recommendations are documented

**Good luck, and happy optimizing! 🎯**

