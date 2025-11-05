# Paired Programming — Indexes & Optimization

## Challenge: Optimize Slow E-Commerce Queries — 40 min

**👥 Roles:**
- **Driver:** Writes SQL code, creates indexes
- **Navigator:** Analyzes EXPLAIN output, suggests optimization strategies, catches errors

**💡 Collaboration Tips:**
- Switch roles every 10-15 minutes
- Navigator should read EXPLAIN results aloud
- Discuss index choices before implementing
- Challenge each other's assumptions!

---

**📖 Scenario:** 

You're a team working on an e-commerce platform. The site is slow during peak hours. Customers complain about:
- Order history taking 5+ seconds to load
- Product search being sluggish
- Reports timing out

Your mission: Identify bottlenecks and optimize with strategic indexes!

---

**🗄️ Database Setup:**

```sql
-- Clean slate
DROP TABLE IF EXISTS pp11_order_items, pp11_orders, pp11_products, pp11_customers;

-- Customer table
CREATE TABLE pp11_customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(100),
  name VARCHAR(100),
  registration_date DATE
);

-- Product catalog
CREATE TABLE pp11_products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200),
  category VARCHAR(50),
  price DECIMAL(10,2),
  stock INT,
  brand VARCHAR(100)
);

-- Orders
CREATE TABLE pp11_orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  status VARCHAR(20),
  total_amount DECIMAL(10,2)
);

-- Order details
CREATE TABLE pp11_order_items (
  item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  price DECIMAL(10,2)
);

-- Insert test data: 50 customers
INSERT INTO pp11_customers (email, name, registration_date)
SELECT 
  CONCAT('customer', n, '@email.com'),
  CONCAT('Customer ', n),
  DATE_SUB(CURDATE(), INTERVAL MOD(n * 7, 365) DAY)
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
LIMIT 50;

-- Insert test data: 100 products
INSERT INTO pp11_products (name, category, price, stock, brand)
SELECT 
  CONCAT('Product ', n),
  ELT(MOD(n, 5) + 1, 'Electronics', 'Clothing', 'Books', 'Home', 'Sports'),
  ROUND(10 + RAND() * 490, 2),
  FLOOR(RAND() * 100),
  ELT(MOD(n, 4) + 1, 'BrandA', 'BrandB', 'BrandC', 'BrandD')
FROM (
  SELECT @row := @row + 1 AS n 
  FROM 
    (SELECT 0 UNION ALL SELECT 1) t1,
    (SELECT 0 UNION ALL SELECT 1) t2,
    (SELECT 0 UNION ALL SELECT 1) t3,
    (SELECT 0 UNION ALL SELECT 1) t4,
    (SELECT 0 UNION ALL SELECT 1) t5,
    (SELECT 0 UNION ALL SELECT 1) t6,
    (SELECT 0 UNION ALL SELECT 1) t7,
    (SELECT @row := 0) r
) numbers
LIMIT 100;

-- Insert test data: 200 orders
INSERT INTO pp11_orders (customer_id, order_date, status, total_amount)
SELECT 
  1 + MOD(n, 50),
  DATE_SUB(CURDATE(), INTERVAL MOD(n, 180) DAY),
  ELT(MOD(n, 3) + 1, 'pending', 'shipped', 'delivered'),
  ROUND(50 + RAND() * 450, 2)
FROM (
  SELECT @row := @row + 1 AS n 
  FROM 
    (SELECT 0 UNION ALL SELECT 1) t1,
    (SELECT 0 UNION ALL SELECT 1) t2,
    (SELECT 0 UNION ALL SELECT 1) t3,
    (SELECT 0 UNION ALL SELECT 1) t4,
    (SELECT 0 UNION ALL SELECT 1) t5,
    (SELECT 0 UNION ALL SELECT 1) t6,
    (SELECT 0 UNION ALL SELECT 1) t7,
    (SELECT 0 UNION ALL SELECT 1) t8,
    (SELECT @row := 0) r
) numbers
LIMIT 200;

-- Insert test data: 500 order items (2-3 products per order on average)
INSERT INTO pp11_order_items (order_id, product_id, quantity, price)
SELECT 
  1 + MOD(n, 200),
  1 + MOD(n * 7, 100),
  1 + FLOOR(RAND() * 5),
  ROUND(10 + RAND() * 90, 2)
FROM (
  SELECT @row := @row + 1 AS n 
  FROM 
    (SELECT 0 UNION ALL SELECT 1) t1,
    (SELECT 0 UNION ALL SELECT 1) t2,
    (SELECT 0 UNION ALL SELECT 1) t3,
    (SELECT 0 UNION ALL SELECT 1) t4,
    (SELECT 0 UNION ALL SELECT 1) t5,
    (SELECT 0 UNION ALL SELECT 1) t6,
    (SELECT 0 UNION ALL SELECT 1) t7,
    (SELECT 0 UNION ALL SELECT 1) t8,
    (SELECT 0 UNION ALL SELECT 1) t9,
    (SELECT @row := 0) r
) numbers
LIMIT 500;

-- Verify setup
SELECT 'Customers' AS table_name, COUNT(*) AS count FROM pp11_customers
UNION ALL
SELECT 'Products', COUNT(*) FROM pp11_products
UNION ALL
SELECT 'Orders', COUNT(*) FROM pp11_orders
UNION ALL
SELECT 'Order Items', COUNT(*) FROM pp11_order_items;
```

---

**🎯 Your Tasks:**

### Task 1: Optimize Customer Order History (15 min)

**Problem:** Customer order history page is very slow!

```sql
-- Slow query: Get customer 5's order history with product details
SELECT 
  c.name AS customer_name,
  o.order_date,
  o.status,
  p.name AS product_name,
  oi.quantity,
  oi.price
FROM pp11_customers c
JOIN pp11_orders o ON c.customer_id = o.customer_id
JOIN pp11_order_items oi ON o.order_id = oi.order_id
JOIN pp11_products p ON oi.product_id = p.product_id
WHERE c.customer_id = 5
ORDER BY o.order_date DESC;
```

**📋 Steps:**
1. **Navigator:** Run EXPLAIN and identify the problem
2. **Driver:** Create appropriate indexes
3. **Both:** Discuss which indexes are needed and why
4. **Navigator:** Verify improvement with EXPLAIN

---

### Task 2: Optimize Product Search (10 min)

**Problem:** Searching for products by category and price is slow!

```sql
-- Slow query: Find Electronics under $200
SELECT * 
FROM pp11_products
WHERE category = 'Electronics' 
AND price < 200
ORDER BY price ASC;
```

**📋 Steps:**
1. Analyze with EXPLAIN
2. Create optimal index
3. Verify improvement

---

### Task 3: Optimize Popular Products Report (15 min)

**Problem:** Report showing most popular products times out!

```sql
-- Slow query: Top 10 most ordered products
SELECT 
  p.product_id,
  p.name,
  p.category,
  COUNT(oi.item_id) AS times_ordered,
  SUM(oi.quantity) AS total_quantity
FROM pp11_products p
JOIN pp11_order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name, p.category
ORDER BY times_ordered DESC
LIMIT 10;
```

**📋 Steps:**
1. Analyze performance issue
2. Add indexes to optimize the JOIN
3. Discuss: Can we create a covering index?

---

**💬 Discussion Questions:**

After completing the tasks, discuss:

1. **Which indexes were most impactful?** Why?

2. **Did we create any redundant indexes?** 
   - Example: If we have `idx_category_price`, do we need `idx_category`?

3. **Trade-offs:** 
   - How do indexes affect INSERT/UPDATE/DELETE performance?
   - When would we NOT want to add an index?

4. **Column order in composite indexes:**
   - Why does order matter?
   - What happens if we reverse the column order?

5. **Real-world scenarios:**
   - How would you monitor index usage in production?
   - When should you remove an index?

---

**✅ Complete Solution:**

```sql
-- ============================================
-- Task 1 Solution: Customer Order History
-- ============================================

-- Step 1: Analyze the problem
EXPLAIN SELECT 
  c.name AS customer_name,
  o.order_date,
  o.status,
  p.name AS product_name,
  oi.quantity,
  oi.price
FROM pp11_customers c
JOIN pp11_orders o ON c.customer_id = o.customer_id
JOIN pp11_order_items oi ON o.order_id = oi.order_id
JOIN pp11_products p ON oi.product_id = p.product_id
WHERE c.customer_id = 5
ORDER BY o.order_date DESC;

-- 📊 Problems identified:
-- orders: type: ALL (no index on customer_id FK!)
-- order_items: type: ALL (no index on order_id FK!)
-- order_items: type: ALL (no index on product_id FK!)

-- Step 2: Add foreign key indexes
CREATE INDEX idx_customer_id ON pp11_orders(customer_id);
CREATE INDEX idx_order_id ON pp11_order_items(order_id);
CREATE INDEX idx_product_id ON pp11_order_items(product_id);

-- Step 3: Further optimize with composite index for ORDER BY
-- Since we're filtering by customer AND sorting by date
CREATE INDEX idx_customer_date ON pp11_orders(customer_id, order_date);

-- Step 4: Verify improvement
EXPLAIN SELECT 
  c.name AS customer_name,
  o.order_date,
  o.status,
  p.name AS product_name,
  oi.quantity,
  oi.price
FROM pp11_customers c
JOIN pp11_orders o ON c.customer_id = o.customer_id
JOIN pp11_order_items oi ON o.order_id = oi.order_id
JOIN pp11_products p ON oi.product_id = p.product_id
WHERE c.customer_id = 5
ORDER BY o.order_date DESC;

-- 📊 After optimization:
-- All JOINs now use type: ref (index lookups!)
-- Much fewer rows scanned
-- No filesort needed (thanks to composite index)

-- ============================================
-- Task 2 Solution: Product Search
-- ============================================

-- Step 1: Analyze
EXPLAIN SELECT * 
FROM pp11_products
WHERE category = 'Electronics' 
AND price < 200
ORDER BY price ASC;

-- 📊 Before: type: ALL, Extra: Using where; Using filesort

-- Step 2: Create composite index
CREATE INDEX idx_category_price ON pp11_products(category, price);

-- Step 3: Verify
EXPLAIN SELECT * 
FROM pp11_products
WHERE category = 'Electronics' 
AND price < 200
ORDER BY price ASC;

-- 📊 After: type: range, key: idx_category_price, no filesort!

-- ============================================
-- Task 3 Solution: Popular Products Report
-- ============================================

-- Step 1: Analyze
EXPLAIN SELECT 
  p.product_id,
  p.name,
  p.category,
  COUNT(oi.item_id) AS times_ordered,
  SUM(oi.quantity) AS total_quantity
FROM pp11_products p
JOIN pp11_order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name, p.category
ORDER BY times_ordered DESC
LIMIT 10;

-- 📊 Problem: order_items table may not efficiently join

-- Step 2: Foreign key index already created (idx_product_id)
-- But we can optimize further with a covering index!

-- Create covering index that includes all columns needed
CREATE INDEX idx_product_covering ON pp11_order_items(product_id, quantity, item_id);

-- Step 3: Verify
EXPLAIN SELECT 
  p.product_id,
  p.name,
  p.category,
  COUNT(oi.item_id) AS times_ordered,
  SUM(oi.quantity) AS total_quantity
FROM pp11_products p
JOIN pp11_order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name, p.category
ORDER BY times_ordered DESC
LIMIT 10;

-- 📊 After: Uses covering index - doesn't need to access table!

-- ============================================
-- Review: Check all indexes
-- ============================================

SHOW INDEXES FROM pp11_customers;
SHOW INDEXES FROM pp11_products;
SHOW INDEXES FROM pp11_orders;
SHOW INDEXES FROM pp11_order_items;

-- ============================================
-- Cleanup: Remove redundant indexes
-- ============================================

-- If idx_customer_date exists, we don't need idx_customer_id
DROP INDEX idx_customer_id ON pp11_orders;

-- idx_customer_date covers queries on customer_id alone too!

-- Final index structure:
-- pp11_orders: PRIMARY KEY, idx_customer_date
-- pp11_order_items: PRIMARY KEY, idx_order_id, idx_product_covering
-- pp11_products: PRIMARY KEY, idx_category_price
-- pp11_customers: PRIMARY KEY

-- ============================================
-- Test final queries
-- ============================================

-- Test 1: Fast customer order history
SELECT 
  c.name AS customer_name,
  o.order_date,
  o.status,
  p.name AS product_name,
  oi.quantity,
  oi.price
FROM pp11_customers c
JOIN pp11_orders o ON c.customer_id = o.customer_id
JOIN pp11_order_items oi ON o.order_id = oi.order_id
JOIN pp11_products p ON oi.product_id = p.product_id
WHERE c.customer_id = 5
ORDER BY o.order_date DESC;

-- Test 2: Fast product search
SELECT * 
FROM pp11_products
WHERE category = 'Electronics' 
AND price < 200
ORDER BY price ASC;

-- Test 3: Fast popular products report
SELECT 
  p.product_id,
  p.name,
  p.category,
  COUNT(oi.item_id) AS times_ordered,
  SUM(oi.quantity) AS total_quantity
FROM pp11_products p
JOIN pp11_order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name, p.category
ORDER BY times_ordered DESC
LIMIT 10;
```

---

**🎓 Key Learnings:**

1. **Always Index Foreign Keys**
   - Dramatically speeds up JOINs
   - Should be standard practice

2. **Composite Indexes are Powerful**
   - Handle WHERE + ORDER BY together
   - Column order matters!

3. **Covering Indexes**
   - Include all SELECT columns
   - Avoids table access entirely
   - Trade-off: larger index size

4. **Remove Redundant Indexes**
   - `idx_customer_date` covers `idx_customer_id` queries
   - Too many indexes slow down writes

5. **EXPLAIN is Your Friend**
   - Always check before and after
   - Look for: type, key, rows, Extra columns

---

**🚀 Bonus Challenge:**

If you finish early, try these additional optimizations:

1. **Optimize date range queries:**
   ```sql
   SELECT * FROM pp11_orders 
   WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31';
   ```

2. **Optimize status filtering:**
   ```sql
   SELECT * FROM pp11_orders 
   WHERE status = 'pending' 
   ORDER BY order_date DESC;
   ```

3. **Optimize customer search:**
   ```sql
   SELECT * FROM pp11_customers 
   WHERE email LIKE 'customer1%';
   ```

Discuss: Which of these would benefit from indexes? Which wouldn't?

