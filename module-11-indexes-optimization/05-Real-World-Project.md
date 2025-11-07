# Real-World Project — E-Commerce Database Performance Audit

## 📋 Before You Start

### Learning Objectives
By completing this real-world project, you will:
- Conduct a complete database performance audit
- Use EXPLAIN to identify query bottlenecks
- Apply strategic indexing to optimize slow queries
- Build composite indexes for multi-column query patterns
- Measure and document performance improvements

### Time Allocation (60-90 minutes)
- 📖 **10 min**: Understand the scenario and set up the database
- 🔍 **15 min**: Audit current performance using EXPLAIN
- 🔧 **40-55 min**: Add indexes and optimize queries
- ✅ **10 min**: Document results and review improvements

### Success Tips
- ✅ Always run EXPLAIN before and after making changes
- ✅ Focus on columns used in WHERE, JOIN, and ORDER BY
- ✅ Create composite indexes for queries with multiple conditions
- ✅ Measure actual query execution time improvements
- ✅ Remember: indexes speed up reads but slow down writes

---

## 🎯 Project Scenario

You've been hired as a database consultant for "ShopFast," an e-commerce company experiencing slow page loads. Their database has:

- **5 tables** with customer, order, and product data
- **Slow queries** taking 2-10 seconds each
- **No optimization** since the site launched 2 years ago
- **Growing complaints** from users about slow checkout

**Your Mission:** Audit the database and optimize the top 5 slowest queries.

---

## 📦 Step 1: Set Up the Database (10 minutes)

### 1.1 Create the Schema

First, create the e-commerce database structure:

```sql
-- Create database
CREATE DATABASE shopfast_db;
USE shopfast_db;

-- Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    city VARCHAR(50),
    country VARCHAR(50),
    registration_date DATE
);

-- Categories table
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50),
    description TEXT
);

-- Products table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    category_id INT,
    price DECIMAL(10, 2),
    stock_quantity INT,
    supplier VARCHAR(100)
);

-- Orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATETIME,
    status VARCHAR(20),
    total_amount DECIMAL(10, 2),
    shipping_city VARCHAR(50)
);

-- Order items table
CREATE TABLE order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2)
);
```

### 1.2 Generate Test Data

Insert sample data (at least 1000 rows per table for realistic testing):

```sql
-- Insert 1000 customers
INSERT INTO customers (email, first_name, last_name, city, country, registration_date)
SELECT 
    CONCAT('user', n, '@email.com'),
    CONCAT('First', n),
    CONCAT('Last', n),
    ELT(FLOOR(1 + RAND() * 5), 'New York', 'Los Angeles', 'Chicago', 'Houston', 'Miami'),
    'USA',
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 730) DAY)
FROM (
    SELECT @row := @row + 1 AS n
    FROM (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t1,
         (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t2,
         (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t3,
         (SELECT @row := 0) r
    LIMIT 1000
) nums;

-- Insert categories
INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Gadgets and devices'),
('Clothing', 'Apparel and accessories'),
('Books', 'Physical and digital books'),
('Home & Garden', 'Furniture and decor'),
('Sports', 'Athletic equipment');

-- Insert 2000 products
INSERT INTO products (product_name, category_id, price, stock_quantity, supplier)
SELECT 
    CONCAT('Product ', n),
    FLOOR(1 + RAND() * 5),
    ROUND(10 + RAND() * 490, 2),
    FLOOR(RAND() * 100),
    CONCAT('Supplier ', FLOOR(1 + RAND() * 20))
FROM (
    SELECT @row := @row + 1 AS n
    FROM (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t1,
         (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t2,
         (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t3,
         (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t4,
         (SELECT @row := 0) r
    LIMIT 2000
) nums;

-- Insert 5000 orders
INSERT INTO orders (customer_id, order_date, status, total_amount, shipping_city)
SELECT 
    FLOOR(1 + RAND() * 1000),
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY),
    ELT(FLOOR(1 + RAND() * 4), 'pending', 'shipped', 'delivered', 'cancelled'),
    ROUND(50 + RAND() * 450, 2),
    ELT(FLOOR(1 + RAND() * 5), 'New York', 'Los Angeles', 'Chicago', 'Houston', 'Miami')
FROM (
    SELECT @row := @row + 1 AS n
    FROM (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t1,
         (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t2,
         (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t3,
         (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t4,
         (SELECT @row := 0) r
    LIMIT 5000
) nums;

-- Insert 15000 order items (3 items per order average)
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT 
    FLOOR(1 + RAND() * 5000),
    FLOOR(1 + RAND() * 2000),
    FLOOR(1 + RAND() * 5),
    ROUND(10 + RAND() * 490, 2)
FROM (
    SELECT @row := @row + 1 AS n
    FROM (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t1,
         (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t2,
         (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t3,
         (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t4,
         (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t5,
         (SELECT @row := 0) r
    LIMIT 15000
) nums;
```

---

## 🔍 Step 2: Audit Current Performance (15 minutes)

### 2.1 Check Existing Indexes

Find out what indexes currently exist:

```sql
-- Check indexes on each table
SHOW INDEXES FROM customers;
SHOW INDEXES FROM categories;
SHOW INDEXES FROM products;
SHOW INDEXES FROM orders;
SHOW INDEXES FROM order_items;
```

**What to Look For:**
- ✅ PRIMARY KEY on each table (should exist)
- ❌ Missing indexes on foreign keys (customer_id, product_id, etc.)
- ❌ No indexes on frequently filtered columns (status, order_date, city)

### 2.2 Identify Slow Queries

These are the 5 most common slow queries reported by users:

#### **Query 1: Customer Order History**
```sql
-- Get all orders for a specific customer
SELECT * FROM orders 
WHERE customer_id = 500 
ORDER BY order_date DESC;
```

#### **Query 2: Products by Category**
```sql
-- Find all electronics products
SELECT * FROM products 
WHERE category_id = 1 
ORDER BY price DESC;
```

#### **Query 3: Recent Orders Report**
```sql
-- Get orders from last 30 days with customer info
SELECT o.order_id, o.order_date, o.total_amount, 
       c.first_name, c.last_name, c.email
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY o.order_date DESC;
```

#### **Query 4: Order Details with Products**
```sql
-- Get full order details with product names
SELECT oi.item_id, oi.quantity, oi.unit_price,
       p.product_name, p.category_id,
       o.order_date
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id = 1000;
```

#### **Query 5: Top Customers by City**
```sql
-- Find top spending customers in each city
SELECT c.city, c.first_name, c.last_name, 
       SUM(o.total_amount) as total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.customer_id, c.city, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 100;
```

### 2.3 Analyze Each Query with EXPLAIN

Run EXPLAIN on each query to identify problems:

```sql
EXPLAIN SELECT * FROM orders 
WHERE customer_id = 500 
ORDER BY order_date DESC;
```

**What to Look For in EXPLAIN Output:**

| Column | Bad Sign | Good Sign |
|--------|----------|-----------|
| **type** | ALL (full table scan) | ref, eq_ref, range |
| **possible_keys** | NULL | Shows available indexes |
| **key** | NULL (no index used) | Shows index name |
| **rows** | Large number | Small number |
| **Extra** | Using filesort, Using temporary | Using index |

### 2.4 Document Baseline Performance

Create a table to track improvements:

```sql
-- Create results tracking table
CREATE TABLE performance_audit (
    query_name VARCHAR(100),
    before_time_ms INT,
    after_time_ms INT,
    rows_examined_before INT,
    rows_examined_after INT,
    index_added VARCHAR(200)
);
```

**Measure execution time:**
```sql
-- Enable timing
SET profiling = 1;

-- Run query
SELECT * FROM orders WHERE customer_id = 500;

-- Check time
SHOW PROFILES;
```

---

## 🔧 Step 3: Add Strategic Indexes (40-55 minutes)

### 3.1 Fix Query 1: Customer Order History

**Problem:** Full table scan on `orders` table

**Solution:** Add index on `customer_id`

```sql
-- Add index
CREATE INDEX idx_customer_id ON orders(customer_id);

-- Test with EXPLAIN
EXPLAIN SELECT * FROM orders 
WHERE customer_id = 500 
ORDER BY order_date DESC;
```

**Expected Improvement:**
- Type: ALL → ref
- Rows examined: 5000 → ~5
- Speed: 10x-100x faster

### 3.2 Fix Query 1 Further: Optimize ORDER BY

**Problem:** Still shows "Using filesort" in EXPLAIN

**Solution:** Create composite index for WHERE + ORDER BY

```sql
-- Better index: covers both filter and sort
CREATE INDEX idx_customer_date ON orders(customer_id, order_date DESC);

-- Drop old index
DROP INDEX idx_customer_id ON orders;

-- Test again
EXPLAIN SELECT * FROM orders 
WHERE customer_id = 500 
ORDER BY order_date DESC;
```

**Expected Improvement:**
- Extra: Using filesort → Using index

### 3.3 Fix Query 2: Products by Category

**Problem:** Full table scan + filesort

**Solution:** Composite index on category + price

```sql
-- Add composite index
CREATE INDEX idx_category_price ON products(category_id, price DESC);

-- Test
EXPLAIN SELECT * FROM products 
WHERE category_id = 1 
ORDER BY price DESC;
```

### 3.4 Fix Query 3: Recent Orders with JOIN

**Problem:** Slow JOIN, no index on order_date

**Solution:** Add indexes on JOIN and filter columns

```sql
-- Index for JOIN
CREATE INDEX idx_customer_id ON customers(customer_id);

-- Index for date filter + sort
CREATE INDEX idx_order_date ON orders(order_date);

-- Test
EXPLAIN SELECT o.order_id, o.order_date, o.total_amount, 
       c.first_name, c.last_name, c.email
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY o.order_date DESC;
```

### 3.5 Fix Query 4: Order Details JOIN

**Problem:** Multiple JOINs without indexes

**Solution:** Add foreign key indexes

```sql
-- Index for order_items JOIN
CREATE INDEX idx_order_id ON order_items(order_id);
CREATE INDEX idx_product_id ON order_items(product_id);

-- Test
EXPLAIN SELECT oi.item_id, oi.quantity, oi.unit_price,
       p.product_name, p.category_id, o.order_date
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id = 1000;
```

### 3.6 Fix Query 5: Grouped Query with Filter

**Problem:** Slow GROUP BY and WHERE on status

**Solution:** Add index on status + customer_id

```sql
-- Index for status filter
CREATE INDEX idx_status_customer ON orders(status, customer_id);

-- Test
EXPLAIN SELECT c.city, c.first_name, c.last_name, 
       SUM(o.total_amount) as total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.customer_id, c.city, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 100;
```

---

## ✅ Step 4: Measure and Document Results (10 minutes)

### 4.1 Compare EXPLAIN Output

Create a comparison document:

| Query | Before (type) | After (type) | Before (rows) | After (rows) |
|-------|---------------|--------------|---------------|--------------|
| Customer Orders | ALL | ref | 5000 | 5 |
| Products by Category | ALL | ref | 2000 | 400 |
| Recent Orders JOIN | ALL | ref | 5000 | 150 |
| Order Details | ALL | eq_ref | 15000 | 3 |
| Top Customers | ALL | ref | 5000 | 2000 |

### 4.2 Verify Index Usage

Check that indexes are being used:

```sql
-- Show all indexes created
SHOW INDEXES FROM orders;
SHOW INDEXES FROM products;
SHOW INDEXES FROM order_items;

-- Verify index size
SELECT 
    table_name,
    index_name,
    ROUND(stat_value * @@innodb_page_size / 1024 / 1024, 2) as size_mb
FROM mysql.innodb_index_stats
WHERE database_name = 'shopfast_db'
GROUP BY table_name, index_name;
```

### 4.3 Final Recommendations

**Document these points:**

1. ✅ **Indexes Added:** List all CREATE INDEX statements
2. ✅ **Performance Gains:** Show before/after execution times
3. ✅ **Trade-offs:** Note that writes (INSERT/UPDATE) may be slightly slower
4. ✅ **Maintenance:** Recommend monthly index usage review
5. ✅ **Future Optimizations:** Suggest query caching, read replicas if needed

---

## 📊 Deliverables

Submit the following:

### 1. SQL Script File
```sql
-- File: shopfast_optimization.sql
-- Contains:
-- - Schema creation
-- - Test data generation
-- - All CREATE INDEX statements
-- - Before/after EXPLAIN outputs (as comments)
```

### 2. Performance Report (Markdown or Document)

```markdown
# ShopFast Database Performance Audit Report

## Executive Summary
- Optimized 5 critical queries
- Average speed improvement: 85%
- Total indexes added: 8

## Query-by-Query Analysis

### Query 1: Customer Order History
**Problem:** Full table scan on 5000 rows
**Solution:** Composite index on (customer_id, order_date)
**Result:** 98% faster (2.5s → 0.05s)

[Repeat for each query...]

## Recommendations
1. Monitor index usage monthly
2. Consider partitioning orders table by year
3. Implement query caching for frequent reports
```

### 3. Index Summary Table

| Table | Index Name | Columns | Purpose | Size (MB) |
|-------|-----------|---------|---------|-----------|
| orders | idx_customer_date | customer_id, order_date | Customer history lookup | 1.2 |
| orders | idx_order_date | order_date | Recent orders filter | 0.8 |
| ... | ... | ... | ... | ... |

---

## 🎓 Self-Assessment Checklist

- [ ] Created all 5 tables with realistic data
- [ ] Ran EXPLAIN on all 5 slow queries (before optimization)
- [ ] Added appropriate indexes for each query
- [ ] Re-ran EXPLAIN to verify improvements
- [ ] Documented performance metrics (before/after)
- [ ] Verified indexes are actually being used
- [ ] Checked index sizes to ensure reasonable overhead
- [ ] Created final recommendations document

---

## 🚀 Bonus Challenges

If you finish early, try these:

1. **Covering Index:** Create a covering index that eliminates "Using temporary"
2. **Unused Index Detection:** Query `sys.schema_unused_indexes` to find any indexes not being used
3. **Query Rewriting:** Rewrite Query 5 using a CTE for better readability
4. **Partitioning:** Partition the `orders` table by year for even better performance

**Great work on completing this real-world project! 🎉**

