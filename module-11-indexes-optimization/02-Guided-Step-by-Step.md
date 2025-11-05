# Guided Step-by-Step — Indexes & Optimization (15–20 min each)

**Beginner Tip:** Always EXPLAIN before and after adding indexes to see the difference!

---

## Activity 1: Optimizing E-Commerce Product Search — 18 min

### Business Context
Your e-commerce site is slow when customers search for products. Queries take 3+ seconds with only 100,000 products.

### Database Setup

**Beginner Note:** We're creating a table with 1,000 products to simulate a real e-commerce database. With larger datasets, indexes make a huge difference!

```sql
DROP TABLE IF EXISTS gs11_products;
CREATE TABLE gs11_products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200),
  category VARCHAR(50),
  price DECIMAL(10,2),
  stock_quantity INT,
  brand VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert 1000 test products
-- This generates realistic e-commerce data for testing
INSERT INTO gs11_products (name, category, price, stock_quantity, brand)
SELECT 
  CONCAT('Product ', n) AS name,
  ELT(MOD(n, 5) + 1, 'Electronics', 'Clothing', 'Books', 'Home', 'Sports') AS category,
  ROUND(RAND() * 1000, 2) AS price,
  FLOOR(RAND() * 100) AS stock_quantity,
  ELT(MOD(n, 3) + 1, 'BrandA', 'BrandB', 'BrandC') AS brand
FROM (
  SELECT @row := @row + 1 AS n 
  FROM 
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) t1,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) t2,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) t3,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) t4,
    (SELECT @row := 0) r
) numbers
LIMIT 1000;

-- Verify data was inserted
SELECT COUNT(*) AS total_products FROM gs11_products;
SELECT category, COUNT(*) AS count 
FROM gs11_products 
GROUP BY category;
```

### Step 1: Identify Slow Query (3 min)

**What to Look For:** When you run EXPLAIN, check the `type` column. `ALL` means "full table scan" - MySQL reads EVERY row! This is slow on large tables.

```sql
-- Slow query: search by category
EXPLAIN SELECT * FROM gs11_products WHERE category = 'Electronics';

-- 📊 Look at the output:
-- type: ALL            ← BAD! Reads all 1000 rows
-- possible_keys: NULL  ← No index available
-- key: NULL            ← Not using any index
-- rows: 1000           ← Scanning 1000 rows to find ~200 Electronics products
```

**Beginner Explanation:** Without an index, MySQL checks every single product (all 1,000) to find Electronics. It's like reading a phone book from page 1 to find all "Smiths"!

```sql
-- Time the query to see how slow it is
SELECT * FROM gs11_products WHERE category = 'Electronics';
-- With 1,000 rows this is fast, but with 1,000,000 rows it would be very slow!
```

---

### Step 2: Create Index (2 min)

**Solution:** Create an index on the `category` column so MySQL can jump directly to Electronics products.

```sql
-- Create index on category
CREATE INDEX idx_category ON gs11_products(category);

-- Verify the index was created
SHOW INDEXES FROM gs11_products;
-- You should see idx_category in the list
```

**What Just Happened:** MySQL created a lookup structure (like a book's index) that maps:
- `Electronics` → rows 1, 5, 10, 15, 20, ...
- `Clothing` → rows 2, 7, 12, 17, ...
- etc.

---

### Step 3: Verify Improvement (2 min)

**Check if MySQL uses the index:**

```sql
EXPLAIN SELECT * FROM gs11_products WHERE category = 'Electronics';

-- 📊 Now the output shows:
-- type: ref            ← GOOD! Uses index lookup
-- possible_keys: idx_category  ← Index is available
-- key: idx_category    ← MySQL chose to use our index!
-- rows: ~200           ← Only scans matching rows (80% fewer rows!)
```

**Beginner Explanation:** Now MySQL jumps directly to Electronics products using the index. It's like using the phone book's "S" section to find "Smiths" - much faster!

```sql
-- Run the query again and see the performance difference
SELECT * FROM gs11_products WHERE category = 'Electronics';
-- With 1,000,000 rows, this would be 5-10x faster!
```

### Step 4: Optimize Multi-Column Search (3 min)

**Problem:** Customers often search by BOTH category AND price range. Can we optimize further?

```sql
-- Common query: category + price range
EXPLAIN SELECT * FROM gs11_products 
WHERE category = 'Electronics' AND price BETWEEN 100 AND 500;

-- 📊 Current output:
-- key: idx_category    ← Uses category index
-- rows: ~200           ← Finds 200 Electronics products, then filters by price
-- Extra: Using where   ← Still needs to check price condition row-by-row
```

**Beginner Explanation:** MySQL uses the category index to find 200 Electronics products, but then must check EACH of those 200 rows to see if price is between 100 and 500. Can we do better?

**Solution:** Create a **composite index** on BOTH columns!

```sql
-- Create composite index (category + price together)
CREATE INDEX idx_category_price ON gs11_products(category, price);

-- Now check the improvement:
EXPLAIN SELECT * FROM gs11_products 
WHERE category = 'Electronics' AND price BETWEEN 100 AND 500;

-- 📊 New output:
-- key: idx_category_price  ← Uses our composite index
-- rows: ~50                ← Only finds matching rows (75% fewer rows scanned!)
-- Extra: Using index condition ← Both conditions handled by index!
```

**Why Column Order Matters:**
```sql
-- ✅ Correct: Category first (filters most rows)
CREATE INDEX idx_category_price ON gs11_products(category, price);

-- This index helps:
-- ✅ WHERE category = 'Electronics'
-- ✅ WHERE category = 'Electronics' AND price > 100
-- ✅ WHERE category = 'Electronics' ORDER BY price
-- ❌ WHERE price > 100  (can't use index - price is 2nd column)
```

**Think of it like a phone book:** Organized by (LastName, FirstName). You can find "Smith" or "Smith, John", but NOT all "Johns" efficiently!

### Step 5: Handle Sort Operations (3 min)

**Problem:** Sorting large result sets is slow. Can indexes help?

```sql
-- Query with ORDER BY (sorted by price)
EXPLAIN SELECT * FROM gs11_products 
WHERE category = 'Books' ORDER BY price DESC;

-- 📊 Output without proper index:
-- Extra: Using filesort  ← BAD! MySQL must sort results in memory (slow!)
```

**Beginner Explanation:** "Using filesort" means MySQL must:
1. Find all Books (using idx_category)
2. Load them into memory
3. Sort them by price (CPU-intensive!)

With millions of rows, this is VERY slow!

**Solution:** Our composite index `idx_category_price` helps sorting too!

```sql
-- Check if our composite index helps (it should!)
EXPLAIN SELECT * FROM gs11_products 
WHERE category = 'Books' ORDER BY price DESC;

-- 📊 New output:
-- key: idx_category_price  ← Uses composite index
-- Extra: Backward index scan ← Reads index in reverse order (no sorting needed!)
```

**Why This Works:** The composite index `idx_category_price` stores data already sorted by (category, price). MySQL can read it in reverse order to get DESC sorting for FREE!

**Key Insight:**
```sql
-- ✅ Index on (category, price) helps ALL these queries:
SELECT * FROM gs11_products WHERE category = 'Books';
SELECT * FROM gs11_products WHERE category = 'Books' AND price > 20;
SELECT * FROM gs11_products WHERE category = 'Books' ORDER BY price;  -- No filesort!
SELECT * FROM gs11_products WHERE category = 'Books' ORDER BY price DESC;  -- No filesort!

-- ❌ This query CANNOT use the index for sorting:
SELECT * FROM gs11_products WHERE category = 'Books' ORDER BY stock_quantity;
-- stock_quantity is not in the index!
```

### Step 6: Analyze Index Usage (3 min)
```sql
SHOW INDEXES FROM gs11_products;
-- See all indexes and their cardinality

-- Check which indexes are used
EXPLAIN SELECT * FROM gs11_products 
WHERE brand = 'BrandA' AND category = 'Electronics';
-- Uses idx_category (not brand)
```

### Step 7: Drop Unnecessary Index (2 min)
```sql
-- Remove single-column index since composite index covers it
DROP INDEX idx_category ON gs11_products;
-- Keep only idx_category_price (covers both category and price queries)
```

### Common Mistakes
- Creating too many indexes (slows writes)
- Wrong column order in composite indexes
- Indexing low-cardinality columns (status with only 2 values)
- Not using EXPLAIN to verify

### Complete Solution
```sql
-- Final optimized schema
DROP TABLE IF EXISTS gs11_products;
CREATE TABLE gs11_products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200),
  category VARCHAR(50),
  price DECIMAL(10,2),
  stock_quantity INT,
  brand VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_category_price (category, price),
  INDEX idx_brand (brand),
  INDEX idx_created (created_at)
);
```

### Discussion Questions
1. Why put category before price in composite index?
2. When would you NOT want to add an index?
3. How to decide which columns to index?

---

## Activity 2: Optimizing JOIN Queries — 20 min

### Business Context
Customer order history query times out with 50,000+ orders.

### Database Setup
```sql
DROP TABLE IF EXISTS gs11_order_items, gs11_orders, gs11_customers;

CREATE TABLE gs11_customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(100),
  name VARCHAR(100)
);

CREATE TABLE gs11_orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  total_amount DECIMAL(10,2)
);

CREATE TABLE gs11_order_items (
  item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  price DECIMAL(10,2)
);

-- Insert 100 test customers
INSERT INTO gs11_customers (email, name)
SELECT 
  CONCAT('user', n, '@email.com') AS email, 
  CONCAT('User ', n) AS name
FROM (
  SELECT @row := @row + 1 AS n 
  FROM 
    (SELECT 0 UNION ALL SELECT 1) t1,
    (SELECT 0 UNION ALL SELECT 1) t2,
    (SELECT 0 UNION ALL SELECT 1) t3,
    (SELECT 0 UNION ALL SELECT 1) t4,
    (SELECT 0 UNION ALL SELECT 1) t5,
    (SELECT 0 UNION ALL SELECT 1) t6,
    (SELECT @row := 0) r
) numbers
LIMIT 100;

-- Insert 500 test orders (5 orders per customer on average)
INSERT INTO gs11_orders (customer_id, order_date, total_amount)
SELECT 
  1 + MOD(n, 100) AS customer_id,
  DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY) AS order_date,
  ROUND(RAND() * 500, 2) AS total_amount
FROM (
  SELECT @row := @row + 1 AS n 
  FROM 
    (SELECT 0 UNION ALL SELECT 1) t1,
    (SELECT 0 UNION ALL SELECT 1) t2,
    (SELECT 0 UNION ALL SELECT 1) t3,
    (SELECT 0 UNION ALL SELECT 1) t4,
    (SELECT 0 UNION ALL SELECT 1) t5,
    (SELECT @row := 0) r
) numbers
LIMIT 500;

-- Verify data
SELECT COUNT(*) AS total_customers FROM gs11_customers;
SELECT COUNT(*) AS total_orders FROM gs11_orders;
SELECT customer_id, COUNT(*) AS order_count 
FROM gs11_orders 
GROUP BY customer_id 
ORDER BY order_count DESC 
LIMIT 5;
```

### Steps: Optimize JOIN Performance

**Step 1: Analyze Slow JOIN Query**

**Beginner Explanation:** JOINs combine data from multiple tables. Without indexes on the JOIN columns, MySQL must scan the entire table for EACH matching row (very slow!).

```sql
-- Slow query: Get customer's order history
EXPLAIN SELECT c.name, o.order_date, o.total_amount
FROM gs11_customers c
JOIN gs11_orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = 1;

-- 📊 Output shows:
-- For customers table: type: const (good - uses PRIMARY KEY)
-- For orders table: type: ALL (BAD! - scans all 500 orders!)
-- rows: 500 (checking every order to find customer 1's orders)
```

**Problem:** No index on `orders.customer_id`, so MySQL must check all 500 orders!

---

**Step 2: Add Foreign Key Index**

**Rule of Thumb:** ALWAYS index foreign key columns!

```sql
-- Add index on the foreign key column
CREATE INDEX idx_customer_id ON gs11_orders(customer_id);

-- Verify it was created
SHOW INDEXES FROM gs11_orders;
```

---

**Step 3: Verify Improvement**

```sql
EXPLAIN SELECT c.name, o.order_date, o.total_amount
FROM gs11_customers c
JOIN gs11_orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = 1;

-- 📊 Now shows:
-- For orders table: type: ref (GOOD! - uses index)
-- key: idx_customer_id (using our new index!)
-- rows: ~5 (only scans customer 1's orders - 100x fewer rows!)
```

**Key Improvement:** Instead of scanning 500 rows, MySQL now jumps directly to customer 1's ~5 orders!

---

**Step 4: Optimize Date Range Queries**

**Common Query:** Find all orders in a date range.

```sql
-- Test without index
EXPLAIN SELECT * FROM gs11_orders 
WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31';
-- type: ALL (scans all 500 rows)

-- Add date index
CREATE INDEX idx_order_date ON gs11_orders(order_date);

-- Verify improvement
EXPLAIN SELECT * FROM gs11_orders 
WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31';
-- type: range (uses index for date range - much faster!)
```

---

**Step 5: Composite Index for Common Pattern**

**Real-World Scenario:** "Show me customer 1's orders from last year, newest first"

```sql
-- This query combines customer filter + date filter + sorting
EXPLAIN SELECT * FROM gs11_orders 
WHERE customer_id = 1 AND order_date >= '2025-01-01'
ORDER BY order_date DESC;

-- 📊 With separate indexes:
-- Uses idx_customer_id OR idx_order_date (not both!)
-- Extra: Using filesort (still needs to sort in memory)

-- Create composite index to handle all three operations!
CREATE INDEX idx_customer_date ON gs11_orders(customer_id, order_date);

-- Verify improvement
EXPLAIN SELECT * FROM gs11_orders 
WHERE customer_id = 1 AND order_date >= '2025-01-01'
ORDER BY order_date DESC;

-- 📊 Now shows:
-- key: idx_customer_date (uses composite index)
-- Extra: Backward index scan (sorted automatically!)
-- No filesort needed!
```

**Why This Works:** The composite index stores data sorted by (customer_id, order_date), so MySQL can:
1. Jump to customer 1's orders
2. Filter by date range
3. Read in reverse order for DESC sorting
All using ONE index lookup!

---

**Step 6: Clean Up Redundant Indexes**

```sql
-- Remove single-column indexes now covered by composite
DROP INDEX idx_customer_id ON gs11_orders;
-- Keep idx_customer_date (covers customer_id queries too!)

-- Final index structure:
SHOW INDEXES FROM gs11_orders;
-- Should show: PRIMARY KEY, idx_customer_date, idx_order_date
```

### Key Takeaways
- Always index foreign key columns
- Composite indexes help with filtering + sorting
- Use EXPLAIN to confirm index usage
- Monitor query performance over time

---

**Optimization Checklist:**
✅ Run EXPLAIN on slow queries  
✅ Index WHERE columns  
✅ Index JOIN columns (especially FKs)  
✅ Index ORDER BY columns  
✅ Use composite indexes for common query patterns  
✅ Monitor index usage with SHOW INDEX  
✅ Drop unused indexes  
✅ Test with realistic data volumes

