# Guided Step-by-Step — Indexes & Optimization (15–20 min each)

**Beginner Tip:** Always EXPLAIN before and after adding indexes to see the difference!

---

## Activity 1: Optimizing E-Commerce Product Search — 18 min

### Business Context
Your e-commerce site is slow when customers search for products. Queries take 3+ seconds with only 100,000 products.

### Database Setup
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

-- Insert test data
INSERT INTO gs11_products (name, category, price, stock_quantity, brand)
SELECT 
  CONCAT('Product ', n),
  ELT(MOD(n, 5) + 1, 'Electronics', 'Clothing', 'Books', 'Home', 'Sports'),
  ROUND(RAND() * 1000, 2),
  FLOOR(RAND() * 100),
  ELT(MOD(n, 3) + 1, 'BrandA', 'BrandB', 'BrandC')
FROM (SELECT @row := @row + 1 AS n FROM 
      (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) t1,
      (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) t2,
      (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) t3,
      (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) t4,
      (SELECT @row := 0) r) numbers
LIMIT 1000;
```

### Step 1: Identify Slow Query (3 min)
```sql
-- Slow query: search by category
EXPLAIN SELECT * FROM gs11_products WHERE category = 'Electronics';
-- type: ALL (full table scan - BAD!)

-- Time it
SELECT * FROM gs11_products WHERE category = 'Electronics';
```

### Step 2: Create Index (2 min)
```sql
CREATE INDEX idx_category ON gs11_products(category);
```

### Step 3: Verify Improvement (2 min)
```sql
EXPLAIN SELECT * FROM gs11_products WHERE category = 'Electronics';
-- type: ref (uses index - GOOD!)
```

### Step 4: Optimize Multi-Column Search (3 min)
```sql
-- Common query: category + price range
EXPLAIN SELECT * FROM gs11_products 
WHERE category = 'Electronics' AND price BETWEEN 100 AND 500;
-- Uses idx_category but still scans many rows

-- Create composite index
CREATE INDEX idx_category_price ON gs11_products(category, price);

EXPLAIN SELECT * FROM gs11_products 
WHERE category = 'Electronics' AND price BETWEEN 100 AND 500;
-- Now uses idx_category_price efficiently!
```

### Step 5: Handle Sort Operations (3 min)
```sql
-- Query with ORDER BY
EXPLAIN SELECT * FROM gs11_products 
WHERE category = 'Books' ORDER BY price DESC;
-- Extra: Using filesort (slow)

-- Composite index helps sorting too!
-- idx_category_price already created above handles this
EXPLAIN SELECT * FROM gs11_products 
WHERE category = 'Books' ORDER BY price DESC;
-- No filesort needed!
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

-- Insert test data
INSERT INTO gs11_customers (email, name)
SELECT CONCAT('user', n, '@email.com'), CONCAT('User ', n)
FROM (SELECT @row := @row + 1 AS n FROM 
      (SELECT 0 UNION ALL SELECT 1) t1,
      (SELECT 0 UNION ALL SELECT 1) t2,
      (SELECT 0 UNION ALL SELECT 1) t3,
      (SELECT 0 UNION ALL SELECT 1) t4,
      (SELECT @row := 0) r) numbers
LIMIT 100;

INSERT INTO gs11_orders (customer_id, order_date, total_amount)
SELECT 
  1 + MOD(n, 100),
  DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY),
  ROUND(RAND() * 500, 2)
FROM (SELECT @row := @row + 1 AS n FROM 
      (SELECT 0 UNION ALL SELECT 1) t1,
      (SELECT 0 UNION ALL SELECT 1) t2,
      (SELECT 0 UNION ALL SELECT 1) t3,
      (SELECT @row := 0) r) numbers
LIMIT 500;
```

### Steps: Optimize JOIN Performance
```sql
-- Step 1: Analyze slow query
EXPLAIN SELECT c.name, o.order_date, o.total_amount
FROM gs11_customers c
JOIN gs11_orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = 1;
-- type: ALL on orders (no index on foreign key!)

-- Step 2: Add FK index
CREATE INDEX idx_customer_id ON gs11_orders(customer_id);

-- Step 3: Verify improvement
EXPLAIN SELECT c.name, o.order_date, o.total_amount
FROM gs11_customers c
JOIN gs11_orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = 1;
-- Now uses index!

-- Step 4: Optimize date range queries
CREATE INDEX idx_order_date ON gs11_orders(order_date);

EXPLAIN SELECT * FROM gs11_orders 
WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31';
-- Uses idx_order_date

-- Step 5: Composite index for common query pattern
CREATE INDEX idx_customer_date ON gs11_orders(customer_id, order_date);

EXPLAIN SELECT * FROM gs11_orders 
WHERE customer_id = 1 AND order_date >= '2025-01-01'
ORDER BY order_date DESC;
-- Uses idx_customer_date, no filesort!
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

