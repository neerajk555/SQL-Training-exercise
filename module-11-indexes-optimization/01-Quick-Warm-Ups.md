# Quick Warm-Ups — Indexes & Optimization (5–10 min each)

##  Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Create indexes to speed up queries
- Use EXPLAIN to analyze query performance
- Understand when indexes help (and when they don't)
- Identify slow queries and optimize them
- Balance query speed vs write performance

### Key Index Concepts for Beginners
**What are Indexes?**
- Special lookup structures that speed up data retrieval
- Like a book index: find information without reading every page
- Created on columns frequently used in WHERE, JOIN, ORDER BY

**Index Trade-offs:**
- ✅ **Faster**: SELECT queries with WHERE/JOIN/ORDER BY
- ❌ **Slower**: INSERT, UPDATE, DELETE (must update index too)
- ❌ **Storage**: Indexes take disk space
- **Rule**: Index columns you search, not columns you update frequently

**Types of Indexes:**
- **PRIMARY KEY**: Automatically indexed, unique, not null
- **UNIQUE**: Indexed automatically, enforces uniqueness
- **INDEX**: Non-unique index for faster lookups
- **COMPOSITE**: Index on multiple columns (e.g., last_name, first_name)

**Using EXPLAIN:**
- Shows how MySQL will execute your query
- Look for: `type: ALL` (bad—full table scan) vs `type: ref` (good—uses index)
- Check `possible_keys` and `key` to see if indexes are used

### Execution Tips
1. **EXPLAIN before indexing**: See current query plan
2. **Create index**: On columns in WHERE/JOIN/ORDER BY
3. **EXPLAIN after indexing**: Verify index is used
4. **Test with data**: Indexes help most with large tables

**Beginner Tip:** Indexes speed up SELECT/WHERE/JOIN but slow down INSERT/UPDATE/DELETE. Use EXPLAIN to see if queries use indexes. Index columns used in WHERE, JOIN ON, and ORDER BY clauses!

---

## 1) Create Simple Index — 5 min
```sql
DROP TABLE IF EXISTS wu11_users;
CREATE TABLE wu11_users (
  user_id INT PRIMARY KEY,
  email VARCHAR(100),
  created_at TIMESTAMP
);
INSERT INTO wu11_users VALUES
(1, 'alice@email.com', '2025-01-01 10:00:00'),
(2, 'bob@email.com', '2025-01-15 11:30:00');
```

Task: Create index on `email` column.

Solution:
```sql
CREATE INDEX idx_email ON wu11_users(email);
SHOW INDEXES FROM wu11_users;
```

---

## 2) Analyze Query with EXPLAIN — 6 min
```sql
DROP TABLE IF EXISTS wu11_products;
CREATE TABLE wu11_products (
  product_id INT PRIMARY KEY,
  category VARCHAR(50),
  price DECIMAL(10,2)
);
INSERT INTO wu11_products VALUES
(1, 'Electronics', 299.99),
(2, 'Electronics', 499.99),
(3, 'Clothing', 49.99);
```

Task: Use EXPLAIN to analyze query performance.

Solution:
```sql
-- Before index
EXPLAIN SELECT * FROM wu11_products WHERE category = 'Electronics';
-- Shows type: ALL (full table scan)

-- Create index
CREATE INDEX idx_category ON wu11_products(category);

-- After index
EXPLAIN SELECT * FROM wu11_products WHERE category = 'Electronics';
-- Shows type: ref (uses index)
```

---

## 3) Composite Index — 7 min
```sql
DROP TABLE IF EXISTS wu11_orders;
CREATE TABLE wu11_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  status VARCHAR(20)
);
INSERT INTO wu11_orders VALUES
(1, 101, '2025-11-01', 'completed'),
(2, 102, '2025-11-02', 'pending'),
(3, 101, '2025-11-03', 'completed');
```

Task: Create composite index on (customer_id, order_date).

Solution:
```sql
CREATE INDEX idx_customer_date ON wu11_orders(customer_id, order_date);

-- This query uses the index efficiently
EXPLAIN SELECT * FROM wu11_orders 
WHERE customer_id = 101 AND order_date >= '2025-11-01';
```

---

## 4) Drop Unused Index — 5 min

**What You'll Learn:** How to identify and remove unnecessary indexes.

**Beginner Explanation:**
Too many indexes slow down INSERT/UPDATE/DELETE because MySQL must update every index when data changes. If an index isn't helping queries, remove it!

```sql
DROP TABLE IF EXISTS wu11_logs;
CREATE TABLE wu11_logs (
  log_id INT PRIMARY KEY,
  message TEXT,
  log_date DATE
);
-- ❌ Bad: Indexing TEXT columns is rarely useful (and expensive!)
CREATE INDEX idx_message ON wu11_logs(message(100));  -- Prefix index on first 100 chars
```

**Task:** Drop the inefficient index on TEXT column and explain why it's problematic.

**Why This is Bad:**
- TEXT columns are large (can be megabytes!)
- Indexing TEXT uses lots of disk space
- Queries with `LIKE '%keyword%'` (wildcard search) can't use indexes anyway
- Better alternatives: Full-text search (FULLTEXT index) or search engine (Elasticsearch)

**Solution:**
```sql
-- View all indexes on the table
SHOW INDEXES FROM wu11_logs;

-- Remove the inefficient index
DROP INDEX idx_message ON wu11_logs;

-- ✅ Better approach: Index date for time-range queries
CREATE INDEX idx_log_date ON wu11_logs(log_date);

-- Now this query is fast:
SELECT * FROM wu11_logs WHERE log_date >= '2025-01-01';
```

**Key Takeaway:** Only index columns that will actually speed up your queries. TEXT/BLOB columns rarely benefit from indexes!

---

## 5) Optimize Slow Query — 8 min
```sql
DROP TABLE IF EXISTS wu11_employees;
CREATE TABLE wu11_employees (
  emp_id INT PRIMARY KEY,
  dept_id INT,
  salary DECIMAL(10,2),
  hire_date DATE
);
INSERT INTO wu11_employees VALUES
(1, 10, 50000, '2020-01-15'),
(2, 10, 60000, '2021-03-20'),
(3, 20, 55000, '2019-07-10');
```

Task: Optimize query that filters by dept_id and orders by salary.

Solution:
```sql
-- Slow query
EXPLAIN SELECT * FROM wu11_employees 
WHERE dept_id = 10 ORDER BY salary DESC;

-- Create composite index
CREATE INDEX idx_dept_salary ON wu11_employees(dept_id, salary);

-- Now faster!
EXPLAIN SELECT * FROM wu11_employees 
WHERE dept_id = 10 ORDER BY salary DESC;
```

---

## 6) UNIQUE Index — 6 min
```sql
DROP TABLE IF EXISTS wu11_accounts;
CREATE TABLE wu11_accounts (
  account_id INT PRIMARY KEY,
  username VARCHAR(50)
);
```

Task: Add UNIQUE index on username.

Solution:
```sql
CREATE UNIQUE INDEX idx_username ON wu11_accounts(username);

-- Test: This succeeds
INSERT INTO wu11_accounts VALUES (1, 'alice');

-- This fails (duplicate)
-- INSERT INTO wu11_accounts VALUES (2, 'alice');
```

---

## 7) Covering Index — 7 min

**What You'll Learn:** Create "covering indexes" that make queries super-fast.

**Beginner Explanation:**
A **covering index** contains ALL columns needed by a query. MySQL can answer the query using ONLY the index, without touching the actual table data. This is MUCH faster!

**Think of it like this:**
- Normal index: Like a book index that says "see page 42" (you still need to look up page 42)
- Covering index: Like a book index that includes the full answer (no need to look up the page!)

```sql
DROP TABLE IF EXISTS wu11_customers;
CREATE TABLE wu11_customers (
  customer_id INT PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  city VARCHAR(50)
);
INSERT INTO wu11_customers VALUES
(1, 'Alice', 'Smith', 'alice@email.com', 'Boston'),
(2, 'Bob', 'Jones', 'bob@email.com', 'New York');
```

**Task:** Create a covering index for a query that selects email and city by customer_id.

**Solution:**
```sql
-- ❌ Without covering index:
EXPLAIN SELECT email, city FROM wu11_customers WHERE customer_id = 1;
-- Uses PRIMARY KEY, but must access table to get email/city

-- ✅ Create covering index (includes customer_id, email, AND city)
CREATE INDEX idx_covering ON wu11_customers(customer_id, email, city);

-- Now the query is SUPER fast!
EXPLAIN SELECT email, city FROM wu11_customers WHERE customer_id = 1;
-- Extra: Using index
-- MySQL reads ONLY the index, not the table!

-- Test: This query benefits from covering index
SELECT email, city FROM wu11_customers WHERE customer_id = 2;
-- Fast because all needed columns (customer_id, email, city) are in the index
```

**Key Takeaway:** 
- Include all SELECT columns in the index to create a "covering index"
- Look for "Using index" in EXPLAIN output
- Trade-off: Larger index size for faster queries

---

## 8) Prefix Index on VARCHAR — 6 min

**What You'll Learn:** Save disk space with prefix indexes on long VARCHAR columns.

**Beginner Explanation:**
URLs, descriptions, and long text fields take up lots of space. A **prefix index** only indexes the first N characters instead of the entire value. This saves disk space while still speeding up queries!

**Example:** Instead of indexing the full URL `https://example.com/blog/articles/2025/january/my-article-title-is-very-long-and-takes-space`, just index the first 100 characters: `https://example.com/blog/articles/2025/january/my-article-title-is-very-long-and-takes-`

```sql
DROP TABLE IF EXISTS wu11_articles;
CREATE TABLE wu11_articles (
  article_id INT PRIMARY KEY,
  title VARCHAR(255),
  url VARCHAR(500)
);

-- Insert test data
INSERT INTO wu11_articles VALUES
(1, 'MySQL Guide', 'https://example.com/blog/mysql-indexing-tutorial'),
(2, 'Python Tips', 'https://example.com/blog/python-best-practices');
```

**Task:** Create a prefix index on the first 100 characters of the URL column.

**Solution:**
```sql
-- ✅ Index only first 100 characters to save space
-- (Most URLs differ in the first 100 chars anyway!)
CREATE INDEX idx_url_prefix ON wu11_articles(url(100));

-- Check the index was created
SHOW INDEXES FROM wu11_articles;

-- ✅ Still helps with prefix searches:
SELECT * FROM wu11_articles WHERE url LIKE 'https://example.com/blog/%';

-- ✅ Also helps with exact matches (if match is in first 100 chars):
SELECT * FROM wu11_articles WHERE url = 'https://example.com/blog/mysql-indexing-tutorial';
```

**When to Use Prefix Indexes:**
- ✅ Long VARCHAR columns (> 100 characters)
- ✅ URLs, file paths, descriptions
- ✅ When queries use prefix matching (`LIKE 'prefix%'`)

**When NOT to Use:**
- ❌ When you need suffix matching (`LIKE '%suffix'`) - prefix indexes don't help
- ❌ Short columns (< 50 characters) - just index the whole column
- ❌ When exact uniqueness is needed (use full column index)

**Key Takeaway:** Prefix indexes save space on long VARCHAR columns while still speeding up queries!

---

**Key Takeaways:**
- Use EXPLAIN to understand query execution
- Index columns in WHERE, JOIN, ORDER BY
- Composite indexes: most selective column first
- Too many indexes slow down writes
- UNIQUE indexes enforce constraint + improve performance
- Prefix indexes save space on long VARCHAR columns
- Covering indexes avoid table lookups

