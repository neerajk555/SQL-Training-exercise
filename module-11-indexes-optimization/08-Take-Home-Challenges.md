# Take-Home Challenges — Indexes & Optimization# Take-Home Challenges — Indexes & Optimization



**🎯 Goal:** Deep-dive research projects to master advanced indexing concepts## Challenge 1: Optimize Complex JOIN Query

Given a 5-table JOIN with slow performance, identify bottlenecks and add strategic indexes. Compare execution times.

**💡 Instructions:** These challenges require research, experimentation, and documentation. Take your time!

## Challenge 2: Index Strategy for Time-Series Data

---Design index strategy for IoT sensor data (billions of rows). Consider partitioning + indexes. Balance write vs read performance.



## Challenge 1: Optimize Complex Multi-Table JOIN Query (2-3 hours)## Challenge 3: Covering Index Analysis

Find queries that would benefit from covering indexes. Calculate space vs performance trade-offs.

**Scenario:** You inherit a legacy reporting query joining 5 tables that takes 30+ seconds.

## Challenge 4: Index Maintenance Script

**Your Tasks:**Write script to identify unused indexes (never used in EXPLAIN). Safely remove them in production.

1. Create schema with 5 tables (customers, orders, order_items, products, categories)

2. Generate test data (1000+ rows per table)## Challenge 5: Query Rewriting

3. Write complex query joining all 5 tablesGiven queries that can't use indexes (functions on columns, OR conditions), rewrite to be index-friendly.

4. Identify bottlenecks using EXPLAIN

5. Add strategic indexes one-by-one## Challenge 6: Composite Index Order Optimization

6. Document before/after metricsGiven query patterns, determine optimal column order for composite indexes. Test with different orderings.



**Deliverable:**## Challenge 7: Full-Text Search vs Regular Indexes

- SQL script with schema + test dataCompare FULLTEXT indexes vs LIKE queries with regular indexes for text search. When to use each?

- Analysis report with EXPLAIN output

- Performance improvement graph**Research:** MySQL query optimizer, index selectivity, query execution plans, performance_schema

- Recommendations document


---

## Challenge 2: Index Strategy for Time-Series Data (3-4 hours)

**Scenario:** Design indexing for IoT sensor data (billions of rows).

**Schema Example:**
```sql
CREATE TABLE sensor_readings (
  reading_id BIGINT PRIMARY KEY,
  sensor_id INT,
  timestamp DATETIME,
  temperature DECIMAL(5,2),
  humidity DECIMAL(5,2)
);
```

**Your Tasks:**
1. Research MySQL partitioning
2. Design partition strategy (by date)
3. Plan indexes for common queries
4. Balance write vs read performance
5. Consider data retention

**Research:** Partitioning, write amplification, index selectivity

---

## Challenge 3: Covering Index Cost-Benefit Analysis (2 hours)

**Task:** Analyze if covering indexes are worth the disk space.

**Measure:**
- Query performance improvement
- Index size (MB)
- INSERT/UPDATE impact
- Calculate ROI

**Deliverable:** Decision guide for when to use covering indexes

---

## Challenge 4: Unused Index Detection Script (2 hours)

**Task:** Write script to find unused indexes in production.

**Tools:**
- `sys.schema_unused_indexes` view
- `performance_schema` tables

**Deliverable:** Automated monitoring script + safe deletion strategy

---

## Challenge 5: Query Rewriting for Index Compatibility (2-3 hours)

**Task:** Rewrite these queries to be index-friendly:

```sql
-- Problem 1: Function on column
SELECT * FROM users WHERE YEAR(registration_date) = 2025;

-- Problem 2: Leading wildcard
SELECT * FROM products WHERE name LIKE '%phone%';

-- Problem 3: OR conditions
SELECT * FROM orders WHERE status = 'pending' OR status = 'processing';
```

**Deliverable:** Rewritten queries + EXPLAIN comparisons

---

## Challenge 6: Composite Index Column Order (2 hours)

**Task:** Test all column order permutations to find optimal performance.

**Variables:**
- category (5 distinct values)
- brand (20 distinct values)
- price (100 distinct values)

**Deliverable:** Decision tree for choosing column order

---

## Challenge 7: Full-Text Search vs Regular Indexes (3 hours)

**Task:** Compare performance of:
```sql
-- Regular index + LIKE
CREATE INDEX idx_title ON articles(title);
SELECT * FROM articles WHERE title LIKE '%keyword%';

-- FULLTEXT index
CREATE FULLTEXT INDEX idx_ft ON articles(title);
SELECT * FROM articles WHERE MATCH(title) AGAINST('keyword');
```

**Deliverable:** When to use each approach + performance matrix

---

## 📚 Research Resources

1. **MySQL Documentation:**
   - MySQL 8.0 Optimization Guide
   - EXPLAIN Output Format
   - Partitioning

2. **Books:**
   - "High Performance MySQL" by Baron Schwartz

3. **Tools:**
   - MySQL Workbench Query Profiler
   - Percona Toolkit

---

## 🎓 Evaluation Template

For each challenge document:
1. **Problem Analysis:** What's the issue?
2. **Solution Design:** Why this approach?
3. **Implementation:** SQL code
4. **Testing:** Before/after metrics
5. **Conclusion:** Learnings

---

**🚀 Bonus:** Present findings to your team or study group!
