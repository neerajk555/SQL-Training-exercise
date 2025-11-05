# Module 11 · Indexes & Query Optimization

## 📚 What You'll Learn

Indexes are like a book's index - they help you find information quickly without reading every page. In databases, indexes dramatically speed up SELECT queries, but they come with trade-offs. This module teaches you when to use indexes, how to create them effectively, and how to optimize query performance.

---

## 🎯 Learning Objectives

By the end of this module, you will:
- ✅ Understand what indexes are and how they work
- ✅ Create single-column and composite indexes
- ✅ Use EXPLAIN to analyze query performance
- ✅ Optimize slow queries with strategic indexing
- ✅ Balance query speed vs. write performance
- ✅ Identify and remove unused indexes

---

## 🔑 Key Concepts

### What Are Indexes?

**Simple Explanation:**
Think of a phone book. To find "John Smith," you don't read every page from the beginning. You jump to the "S" section because the book is **indexed** alphabetically. Database indexes work the same way!

**Without Index:**
- Database reads every row (called a "table scan")
- Slow for large tables (like reading a phone book page-by-page)

**With Index:**
- Database jumps directly to matching rows
- Fast lookups (like finding "Smith" in the phone book's "S" section)

---

### Basic Index Syntax

```sql
-- ✅ Create a simple index on one column
CREATE INDEX idx_email ON users(email);

-- ✅ Create a composite index on multiple columns
-- (Use when queries filter by multiple columns together)
CREATE INDEX idx_name_date ON orders(customer_name, order_date);

-- ✅ Create a UNIQUE index (enforces uniqueness + speeds up lookups)
CREATE UNIQUE INDEX idx_username ON accounts(username);

-- ✅ Analyze how MySQL will execute a query
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';

-- ✅ View all indexes on a table
SHOW INDEXES FROM users;

-- ✅ Remove an index when no longer needed
DROP INDEX idx_email ON users;
```

---

### When to Use Indexes

**✅ CREATE indexes on columns used in:**
- `WHERE` clauses → `WHERE email = 'test@example.com'`
- `JOIN` conditions → `JOIN orders ON users.id = orders.user_id`
- `ORDER BY` clauses → `ORDER BY created_at DESC`
- `GROUP BY` clauses → `GROUP BY category`

**❌ DON'T create indexes on:**
- Columns with very few unique values (e.g., `status` with only 'active'/'inactive')
- Columns that are rarely queried
- Small tables (< 100 rows - table scans are already fast)
- Columns updated frequently (indexes slow down INSERT/UPDATE/DELETE)

---

### Index Trade-offs

| **Benefit** | **Cost** |
|-------------|----------|
| ✅ **Faster SELECT queries** | ❌ **Slower INSERT/UPDATE/DELETE** (must update index too) |
| ✅ **Speeds up WHERE/JOIN/ORDER BY** | ❌ **Uses disk space** |
| ✅ **Enforces uniqueness (UNIQUE indexes)** | ❌ **Too many indexes hurt performance** |

**Beginner Rule:** Start with no indexes (except PRIMARY KEY). Add indexes only when queries become slow!

---

### Understanding EXPLAIN

`EXPLAIN` shows MySQL's query execution plan. Key fields to watch:

```sql
EXPLAIN SELECT * FROM products WHERE category = 'Electronics';
```

**Important columns in EXPLAIN output:**

| Column | What It Means | Good Values | Bad Values |
|--------|---------------|-------------|------------|
| **type** | How rows are accessed | `const`, `ref`, `range` | `ALL` (full table scan) |
| **possible_keys** | Indexes MySQL could use | Shows index names | `NULL` (no indexes available) |
| **key** | Index MySQL actually uses | Shows index name | `NULL` (no index used) |
| **rows** | Estimated rows scanned | Low number | High number |
| **Extra** | Additional info | `Using index` (covering index) | `Using filesort` (slow sorting) |

**Example:**
```sql
-- ❌ Bad: Full table scan
EXPLAIN SELECT * FROM orders WHERE customer_id = 5;
-- type: ALL, key: NULL, rows: 50000

-- ✅ Good: Uses index
CREATE INDEX idx_customer ON orders(customer_id);
EXPLAIN SELECT * FROM orders WHERE customer_id = 5;
-- type: ref, key: idx_customer, rows: 23
```

---

### Composite Indexes (Multi-Column Indexes)

**Rule:** Column order matters! Put the most selective (most unique values) column first.

```sql
-- ✅ Correct: category first (filters most rows), then price
CREATE INDEX idx_category_price ON products(category, price);

-- This index helps these queries:
SELECT * FROM products WHERE category = 'Electronics';  -- ✅ Uses index
SELECT * FROM products WHERE category = 'Electronics' AND price > 100;  -- ✅ Uses both columns
SELECT * FROM products WHERE category = 'Electronics' ORDER BY price;  -- ✅ No filesort needed!

-- ❌ This query CANNOT use the index efficiently:
SELECT * FROM products WHERE price > 100;  -- price is 2nd column, can't use index alone
```

**Think of it like a phone book:** Indexed by (LastName, FirstName). You can find "Smith, John" or all "Smiths," but you can't efficiently find all "Johns" without a last name!

---

## 📋 Best Practices

1. **Start Simple:** Only add indexes when queries are slow (use EXPLAIN to check)
2. **Index Foreign Keys:** Always index columns used in JOINs
3. **Composite Indexes:** Order columns by selectivity (most unique first)
4. **Monitor Usage:** Use `SHOW INDEXES` and `EXPLAIN` to verify indexes are actually used
5. **Remove Unused Indexes:** Periodically check for indexes that aren't helping queries
6. **Don't Over-Index:** Each index slows down INSERT/UPDATE/DELETE operations
7. **Test with Real Data:** Indexes matter most with large tables (10,000+ rows)

---

## 🚀 Quick Reference

```sql
-- Create indexes
CREATE INDEX idx_column ON table_name(column_name);
CREATE INDEX idx_multi ON table_name(col1, col2);
CREATE UNIQUE INDEX idx_unique ON table_name(column_name);

-- Analyze queries
EXPLAIN SELECT * FROM table_name WHERE column_name = 'value';
SHOW INDEXES FROM table_name;

-- Remove indexes
DROP INDEX idx_name ON table_name;

-- View index usage (MySQL 5.7+)
SELECT * FROM sys.schema_unused_indexes;
```

---

## 💡 Beginner Tips

1. **PRIMARY KEY is automatically indexed** - no need to create an additional index
2. **UNIQUE constraints create indexes automatically** - speeds up lookups + enforces uniqueness
3. **Use EXPLAIN before and after creating an index** - see the difference!
4. **Look for `type: ALL` in EXPLAIN** - this means "full table scan" (slow!)
5. **Composite indexes can replace single-column indexes** - `idx_category_price` covers queries on `category` alone
6. **Foreign keys should ALWAYS be indexed** - dramatically speeds up JOINs

---

## 📖 Module Structure

- **Quick Warm-Ups:** 8 exercises (5-10 min each) - Basic index creation and EXPLAIN
- **Guided Step-by-Step:** 2 detailed projects (15-20 min each) - Real optimization scenarios
- **Independent Practice:** 3 exercises (20-40 min each) - Apply indexing strategies
- **Paired Programming:** Collaborative optimization challenge
- **Real-World Project:** Full database performance audit
- **Error Detective:** Common indexing mistakes and fixes
- **Speed Drills:** Fast practice for muscle memory
- **Take-Home Challenges:** Advanced research projects
