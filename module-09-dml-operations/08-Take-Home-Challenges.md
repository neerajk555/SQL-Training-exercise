# Take-Home Challenges — DML Operations (Advanced)

Three multi-part exercises focusing on advanced DML operations. Each includes realistic data, 3–4 parts, an open-ended component, and detailed solutions with notes/trade-offs.

**⚠️ CRITICAL SAFETY:** Always use transactions for these challenges! Run `START TRANSACTION;` before modifications, verify results, then `COMMIT;` or `ROLLBACK;`.

---

## Challenge 1: Customer Data Deduplication (40–50 min)

**Scenario:** Your company's CRM has accumulated duplicate customer records over years of data entry. You need to merge duplicates, preserve the best data from each record, and maintain referential integrity with related orders.

### Schema and Sample Data
```sql
DROP TABLE IF EXISTS thc9_customers;
CREATE TABLE thc9_customers (
    customer_id INT PRIMARY KEY,
    email VARCHAR(100),
    full_name VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(200),
    created_date DATE,
    total_orders INT DEFAULT 0,
    status VARCHAR(20)
);

INSERT INTO thc9_customers VALUES
(1001, 'alice@email.com', 'Alice Johnson', '555-0101', '123 Main St, Austin TX', '2023-01-15', 15, 'active'),
(1002, 'alice@email.com', 'Alice M Johnson', '555-0101', '123 Main Street, Austin TX 78701', '2023-01-16', 3, 'active'),  -- Duplicate
(1003, 'bob.smith@email.com', 'Bob Smith', '555-0102', '456 Oak Ave, Dallas TX', '2023-02-01', 8, 'active'),
(1004, 'carol@email.com', 'Carol White', NULL, '789 Elm St, Houston TX', '2023-03-10', 5, 'active'),
(1005, 'carol@email.com', 'Carol A White', '555-0103', NULL, '2023-03-12', 2, 'active'),  -- Duplicate
(1006, 'david@email.com', 'David Lee', '555-0104', '321 Pine Rd, Miami FL', '2023-04-05', 12, 'active'),
(1007, 'alice@email.com', 'Alice Johnson', '555-0199', '123 Main St, Austin TX', '2023-06-01', 1, 'active'),  -- Another duplicate
(1008, 'eve@email.com', 'Eve Brown', '555-0105', '654 Maple Dr, Seattle WA', '2023-05-20', 20, 'active'),
(1009, 'frank@email.com', 'Frank Miller', '555-0106', '987 Cedar Ln, Boston MA', '2023-07-15', 0, 'inactive');

DROP TABLE IF EXISTS thc9_orders;
CREATE TABLE thc9_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    status VARCHAR(20)
);

INSERT INTO thc9_orders VALUES
(5001, 1001, '2024-01-10', 250.00, 'completed'),
(5002, 1002, '2024-01-15', 175.50, 'completed'),  -- Should point to 1001
(5003, 1003, '2024-02-01', 425.00, 'completed'),
(5004, 1004, '2024-02-15', 89.99, 'completed'),
(5005, 1005, '2024-02-20', 150.00, 'shipped'),    -- Should point to 1004
(5006, 1001, '2024-03-01', 320.00, 'completed'),
(5007, 1007, '2024-03-10', 75.00, 'processing'),  -- Should point to 1001
(5008, 1006, '2024-03-15', 500.00, 'completed'),
(5009, 1008, '2024-04-01', 680.00, 'completed');

DROP TABLE IF EXISTS thc9_duplicate_mapping;
CREATE TABLE thc9_duplicate_mapping (
    duplicate_id INT PRIMARY KEY,
    master_id INT,
    merged_date DATE
);
```

### Parts

**A) Identify Duplicates**  
Write a query to find all duplicate customer records based on matching email addresses. Show: `email`, count of duplicates, list of `customer_id`s (comma-separated if possible), earliest `created_date`, total combined `total_orders`.

**B) Merge Customer Records**  
For each duplicate group:
1. Keep the record with the earliest `created_date` as the master
2. Update the master record to have the best available data (most complete address, phone if missing, sum of `total_orders`)
3. Record the merge in `thc9_duplicate_mapping`
4. Do NOT delete duplicates yet (orders still reference them)

**C) Update Referential Integrity**  
Update all orders that reference duplicate customers to point to their master customer record instead. Then safely delete the duplicate customer records.

**D) Open-Ended: Validation**  
Write queries to validate:
- No orders reference deleted customer IDs
- Total order counts per customer match actual order records
- No duplicate emails remain
- All merges are logged in the mapping table

### Solutions and Notes

<details>
<summary>Click to reveal solutions</summary>

```sql
-- A) Identify duplicates
SELECT 
    email,
    COUNT(*) as duplicate_count,
    GROUP_CONCAT(customer_id ORDER BY customer_id) as customer_ids,
    MIN(created_date) as earliest_created,
    SUM(total_orders) as combined_orders
FROM thc9_customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, email;

/*
Expected output:
alice@email.com: 3 duplicates (1001,1002,1007), created 2023-01-15, 19 orders
carol@email.com: 2 duplicates (1004,1005), created 2023-03-10, 7 orders
*/

-- B) Merge customer records
START TRANSACTION;

-- Step 1: For Alice (email=alice@email.com), master is 1001
-- Update master with best data
UPDATE thc9_customers
SET 
    full_name = 'Alice M Johnson',  -- Most complete name
    address = '123 Main Street, Austin TX 78701',  -- Most complete address
    total_orders = 19  -- Sum of 15+3+1
WHERE customer_id = 1001;

-- Step 2: Record the merges
INSERT INTO thc9_duplicate_mapping VALUES
(1002, 1001, '2025-11-06'),
(1007, 1001, '2025-11-06');

-- Step 3: For Carol (email=carol@email.com), master is 1004
-- Update master with best data
UPDATE thc9_customers
SET 
    phone = '555-0103',  -- Phone was NULL, now filled from duplicate
    address = '789 Elm St, Houston TX',  -- Keep this one (1005 had NULL)
    total_orders = 7  -- Sum of 5+2
WHERE customer_id = 1004;

-- Step 4: Record the merge
INSERT INTO thc9_duplicate_mapping VALUES
(1005, 1004, '2025-11-06');

COMMIT;

-- C) Update referential integrity and delete duplicates
START TRANSACTION;

-- Reassign orders from duplicates to masters
UPDATE thc9_orders
SET customer_id = 1001
WHERE customer_id IN (1002, 1007);

UPDATE thc9_orders
SET customer_id = 1004
WHERE customer_id = 1005;

-- Now safe to delete duplicate customers
DELETE FROM thc9_customers
WHERE customer_id IN (1002, 1005, 1007);

COMMIT;

-- D) Validation queries

-- 1. Check no orders reference deleted customers
SELECT 'Orphaned orders check:' as validation;
SELECT o.order_id, o.customer_id
FROM thc9_orders o
LEFT JOIN thc9_customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
-- Should return 0 rows

-- 2. Verify order counts match
SELECT 'Order count validation:' as validation;
SELECT 
    c.customer_id,
    c.full_name,
    c.total_orders as recorded_count,
    COUNT(o.order_id) as actual_count,
    c.total_orders - COUNT(o.order_id) as difference
FROM thc9_customers c
LEFT JOIN thc9_orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.total_orders
HAVING c.total_orders != COUNT(o.order_id);
-- Should return 0 rows (or update total_orders to match)

-- 3. Check no duplicate emails remain
SELECT 'Duplicate email check:' as validation;
SELECT email, COUNT(*) as count
FROM thc9_customers
GROUP BY email
HAVING COUNT(*) > 1;
-- Should return 0 rows

-- 4. Verify all merges logged
SELECT 'Merge log summary:' as validation;
SELECT 
    m.duplicate_id,
    m.master_id,
    m.merged_date,
    cm.full_name as master_name,
    cm.email
FROM thc9_duplicate_mapping m
JOIN thc9_customers cm ON m.master_id = cm.customer_id
ORDER BY m.master_id, m.duplicate_id;
-- Should show 3 merges (1002→1001, 1007→1001, 1005→1004)
```

### Trade-offs and Notes

1. **Master Selection Strategy:** We chose the earliest `created_date` as the master record. Alternative strategies:
   - Most recent activity
   - Highest order count
   - Most complete data fields

2. **Data Merging Logic:** 
   - Manually selected "best" data from duplicates
   - In production, you might need business rules (e.g., always prefer verified addresses)
   - Consider creating a data quality score to automate selection

3. **Soft Delete Alternative:**
   - Instead of DELETE, could set `status = 'merged'` and `merged_to = master_id`
   - Preserves audit trail but complicates queries

4. **Performance:** 
   - For large datasets, batch updates by email groups
   - Use indexed columns for WHERE clauses
   - Consider temporary tables for complex merges

5. **Testing Strategy:**
   - Always test on copy of production data first
   - Use transactions to allow rollback
   - Validate at each step before proceeding

</details>

---

## Challenge 2: Incremental Data Sync (45–55 min)

**Scenario:** Your application has a `staging` table that receives nightly data feeds from external systems. You need to sync this data to your production `inventory` table, handling inserts for new products, updates for existing products, and logging all changes for audit purposes.

### Schema and Sample Data

```sql
-- Production inventory table (current state)
DROP TABLE IF EXISTS thc9_inventory;
CREATE TABLE thc9_inventory (
    product_id INT PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(100),
    category VARCHAR(50),
    quantity INT,
    price DECIMAL(10,2),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO thc9_inventory VALUES
(1, 'LAP-001', 'Business Laptop', 'Electronics', 50, 1200.00, '2025-10-01 08:00:00'),
(2, 'MOU-001', 'Wireless Mouse', 'Electronics', 200, 25.00, '2025-10-15 09:30:00'),
(3, 'KEY-001', 'Mechanical Keyboard', 'Electronics', 150, 75.00, '2025-10-20 10:15:00'),
(4, 'MON-001', '27-inch Monitor', 'Electronics', 75, 300.00, '2025-10-25 11:00:00'),
(5, 'DES-001', 'Standing Desk', 'Furniture', 30, 450.00, '2025-10-10 14:00:00'),
(6, 'CHA-001', 'Office Chair', 'Furniture', 45, 275.00, '2025-10-05 15:30:00');

-- Staging table (new nightly feed)
DROP TABLE IF EXISTS thc9_staging;
CREATE TABLE thc9_staging (
    sku VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    quantity INT,
    price DECIMAL(10,2),
    feed_date DATE
);

INSERT INTO thc9_staging VALUES
('LAP-001', 'Business Laptop Pro', 'Electronics', 55, 1250.00, '2025-11-06'),  -- Price/name change, qty increase
('MOU-001', 'Wireless Mouse', 'Electronics', 200, 25.00, '2025-11-06'),       -- No change
('KEY-001', 'Mechanical Keyboard', 'Electronics', 125, 75.00, '2025-11-06'),  -- Qty decrease
('MON-001', '27-inch Monitor', 'Electronics', 75, 280.00, '2025-11-06'),      -- Price decrease
('WEB-001', 'HD Webcam', 'Electronics', 100, 89.99, '2025-11-06'),            -- NEW product
('DES-002', 'Electric Standing Desk', 'Furniture', 25, 550.00, '2025-11-06'), -- NEW product
('CHA-001', 'Office Chair', 'Furniture', 35, 275.00, '2025-11-06');           -- Qty decrease

-- Audit log table
DROP TABLE IF EXISTS thc9_audit_log;
CREATE TABLE thc9_audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    sku VARCHAR(50),
    action VARCHAR(20),
    field_changed VARCHAR(50),
    old_value VARCHAR(200),
    new_value VARCHAR(200),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sync statistics table
DROP TABLE IF EXISTS thc9_sync_stats;
CREATE TABLE thc9_sync_stats (
    sync_id INT AUTO_INCREMENT PRIMARY KEY,
    sync_date DATE,
    records_inserted INT,
    records_updated INT,
    records_unchanged INT,
    sync_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Parts

**A) Identify Changes**  
Write queries to identify:
1. Products in staging that don't exist in inventory (need INSERT)
2. Products that exist in both but have different values (need UPDATE)
3. Products unchanged (for statistics)

**B) Perform Sync**  
Execute the sync operation:
1. INSERT new products (assign next available product_id)
2. UPDATE existing products with changes
3. Log each change to the audit table with before/after values
4. Update last_updated timestamp for modified records

**C) Track Sync Statistics**  
Record sync statistics in `thc9_sync_stats` showing how many records were inserted, updated, and unchanged.

**D) Open-Ended: Delta Report**  
Create a summary report showing:
- All price changes with percentage difference
- Products with quantity increases vs decreases
- New products added
- Total inventory value before and after sync

### Solutions and Notes

<details>
<summary>Click to reveal solutions</summary>

```sql
-- A) Identify changes

-- 1. New products (in staging, not in inventory)
SELECT 'New products to insert:' as analysis;
SELECT s.sku, s.product_name, s.category, s.quantity, s.price
FROM thc9_staging s
LEFT JOIN thc9_inventory i ON s.sku = i.sku
WHERE i.sku IS NULL;
-- Expected: WEB-001, DES-002

-- 2. Products with changes
SELECT 'Products requiring updates:' as analysis;
SELECT 
    i.product_id,
    i.sku,
    CASE 
        WHEN s.product_name != i.product_name THEN 'name_changed'
        WHEN s.price != i.price THEN 'price_changed'
        WHEN s.quantity != i.quantity THEN 'quantity_changed'
        ELSE 'multiple_changes'
    END as change_type,
    i.product_name as old_name, s.product_name as new_name,
    i.price as old_price, s.price as new_price,
    i.quantity as old_qty, s.quantity as new_qty
FROM thc9_inventory i
JOIN thc9_staging s ON i.sku = s.sku
WHERE s.product_name != i.product_name
   OR s.price != i.price
   OR s.quantity != i.quantity;
-- Expected: LAP-001, KEY-001, MON-001, CHA-001

-- 3. Unchanged products
SELECT 'Unchanged products:' as analysis;
SELECT i.sku, i.product_name
FROM thc9_inventory i
JOIN thc9_staging s ON i.sku = s.sku
WHERE s.product_name = i.product_name
  AND s.price = i.price
  AND s.quantity = i.quantity;
-- Expected: MOU-001

-- B) Perform sync
START TRANSACTION;

-- Step 1: INSERT new products
INSERT INTO thc9_inventory (product_id, sku, product_name, category, quantity, price, last_updated)
SELECT 
    (SELECT COALESCE(MAX(product_id), 0) + 1 FROM thc9_inventory) + ROW_NUMBER() OVER (ORDER BY s.sku) - 1,
    s.sku,
    s.product_name,
    s.category,
    s.quantity,
    s.price,
    NOW()
FROM thc9_staging s
LEFT JOIN thc9_inventory i ON s.sku = i.sku
WHERE i.sku IS NULL;

-- Log inserts
INSERT INTO thc9_audit_log (product_id, sku, action, field_changed, old_value, new_value)
SELECT 
    i.product_id,
    i.sku,
    'INSERT',
    'new_product',
    NULL,
    CONCAT(i.product_name, ' | Qty:', i.quantity, ' | Price:', i.price)
FROM thc9_inventory i
WHERE i.sku IN (SELECT sku FROM thc9_staging WHERE sku NOT IN (SELECT sku FROM thc9_inventory WHERE product_id < 7));

-- Step 2: UPDATE existing products with logging
-- Update product names
INSERT INTO thc9_audit_log (product_id, sku, action, field_changed, old_value, new_value)
SELECT i.product_id, i.sku, 'UPDATE', 'product_name', i.product_name, s.product_name
FROM thc9_inventory i
JOIN thc9_staging s ON i.sku = s.sku
WHERE s.product_name != i.product_name;

UPDATE thc9_inventory i
JOIN thc9_staging s ON i.sku = s.sku
SET i.product_name = s.product_name,
    i.last_updated = NOW()
WHERE s.product_name != i.product_name;

-- Update prices
INSERT INTO thc9_audit_log (product_id, sku, action, field_changed, old_value, new_value)
SELECT i.product_id, i.sku, 'UPDATE', 'price', i.price, s.price
FROM thc9_inventory i
JOIN thc9_staging s ON i.sku = s.sku
WHERE s.price != i.price;

UPDATE thc9_inventory i
JOIN thc9_staging s ON i.sku = s.sku
SET i.price = s.price,
    i.last_updated = NOW()
WHERE s.price != i.price;

-- Update quantities
INSERT INTO thc9_audit_log (product_id, sku, action, field_changed, old_value, new_value)
SELECT i.product_id, i.sku, 'UPDATE', 'quantity', i.quantity, s.quantity
FROM thc9_inventory i
JOIN thc9_staging s ON i.sku = s.sku
WHERE s.quantity != i.quantity;

UPDATE thc9_inventory i
JOIN thc9_staging s ON i.sku = s.sku
SET i.quantity = s.quantity,
    i.last_updated = NOW()
WHERE s.quantity != i.quantity;

-- C) Track sync statistics
INSERT INTO thc9_sync_stats (sync_date, records_inserted, records_updated, records_unchanged)
SELECT 
    CURDATE(),
    (SELECT COUNT(*) FROM thc9_staging s LEFT JOIN thc9_inventory i ON s.sku = i.sku WHERE i.sku IS NULL AND i.product_id > 6),
    (SELECT COUNT(DISTINCT i.product_id) 
     FROM thc9_inventory i 
     JOIN thc9_staging s ON i.sku = s.sku 
     WHERE s.product_name != i.product_name OR s.price != i.price OR s.quantity != i.quantity),
    (SELECT COUNT(*) 
     FROM thc9_inventory i 
     JOIN thc9_staging s ON i.sku = s.sku 
     WHERE s.product_name = i.product_name AND s.price = i.price AND s.quantity = i.quantity);

COMMIT;

-- Verify sync
SELECT * FROM thc9_sync_stats ORDER BY sync_id DESC LIMIT 1;
-- Expected: 2 inserted, 4 updated, 1 unchanged

-- D) Delta Report
SELECT '=== SYNC SUMMARY REPORT ===' as report;

-- Price changes
SELECT 'Price Changes:' as section;
SELECT 
    a.sku,
    i.product_name,
    CAST(a.old_value AS DECIMAL(10,2)) as old_price,
    CAST(a.new_value AS DECIMAL(10,2)) as new_price,
    CAST(a.new_value AS DECIMAL(10,2)) - CAST(a.old_value AS DECIMAL(10,2)) as price_diff,
    ROUND(((CAST(a.new_value AS DECIMAL(10,2)) - CAST(a.old_value AS DECIMAL(10,2))) / CAST(a.old_value AS DECIMAL(10,2))) * 100, 2) as percent_change
FROM thc9_audit_log a
JOIN thc9_inventory i ON a.product_id = i.product_id
WHERE a.field_changed = 'price'
  AND a.change_date >= CURDATE()
ORDER BY percent_change DESC;

-- Quantity changes
SELECT 'Quantity Changes:' as section;
SELECT 
    a.sku,
    i.product_name,
    CAST(a.old_value AS SIGNED) as old_qty,
    CAST(a.new_value AS SIGNED) as new_qty,
    CAST(a.new_value AS SIGNED) - CAST(a.old_value AS SIGNED) as qty_change,
    CASE 
        WHEN CAST(a.new_value AS SIGNED) > CAST(a.old_value AS SIGNED) THEN 'Increase'
        ELSE 'Decrease'
    END as direction
FROM thc9_audit_log a
JOIN thc9_inventory i ON a.product_id = i.product_id
WHERE a.field_changed = 'quantity'
  AND a.change_date >= CURDATE()
ORDER BY qty_change DESC;

-- New products
SELECT 'New Products Added:' as section;
SELECT 
    i.sku,
    i.product_name,
    i.category,
    i.quantity,
    i.price
FROM thc9_inventory i
WHERE i.last_updated >= CURDATE()
  AND i.product_id > 6;

-- Inventory value comparison
SELECT 'Inventory Value Summary:' as section;
SELECT 
    'Before Sync' as timing,
    SUM(quantity * price) as total_value
FROM (
    SELECT 
        CASE 
            WHEN al.product_id IS NOT NULL AND al.field_changed = 'quantity' THEN CAST(al.old_value AS SIGNED)
            ELSE i.quantity
        END as quantity,
        CASE 
            WHEN al2.product_id IS NOT NULL AND al2.field_changed = 'price' THEN CAST(al2.old_value AS DECIMAL(10,2))
            ELSE i.price
        END as price
    FROM thc9_inventory i
    LEFT JOIN thc9_audit_log al ON i.product_id = al.product_id AND al.field_changed = 'quantity' AND al.change_date >= CURDATE()
    LEFT JOIN thc9_audit_log al2 ON i.product_id = al2.product_id AND al2.field_changed = 'price' AND al2.change_date >= CURDATE()
    WHERE i.product_id <= 6
) before_data

UNION ALL

SELECT 
    'After Sync' as timing,
    SUM(quantity * price) as total_value
FROM thc9_inventory;
```

### Trade-offs and Notes

1. **Sync Strategy:**
   - Current approach: Direct UPDATE/INSERT
   - Alternative: REPLACE INTO or INSERT ... ON DUPLICATE KEY UPDATE (simpler but less audit detail)
   - Consider: Soft deletes for products removed from feed

2. **Performance Optimization:**
   - For large datasets, batch operations
   - Use staging table indexes on sku
   - Consider MERGE statement if database supports it

3. **Audit Granularity:**
   - Current: Logs each field change separately
   - Alternative: Single audit row with JSON of all changes (less normalized but simpler queries)

4. **Concurrency:**
   - Use transaction isolation level REPEATABLE READ
   - Consider locking strategy for high-traffic systems
   - Schedule syncs during low-activity periods

5. **Error Handling:**
   - Should validate data quality before sync (price > 0, quantity >= 0)
   - Log sync failures for investigation
   - Implement alerting for unusual changes (e.g., price drops > 50%)

</details>

---

## Challenge 3: Complex Multi-Table Update Cascade (50–60 min)

**Scenario:** You're implementing a promotional pricing system where discounts cascade through multiple tables. When a category discount is applied, it should update product prices, recalculate order totals for pending orders, adjust customer loyalty points, and maintain an audit trail of all changes.

### Schema and Sample Data

```sql
-- Categories with discount rates
DROP TABLE IF EXISTS thc9_categories;
CREATE TABLE thc9_categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50),
    discount_rate DECIMAL(5,2) DEFAULT 0.00,
    discount_start DATE,
    discount_end DATE
);

INSERT INTO thc9_categories VALUES
(1, 'Electronics', 0.00, NULL, NULL),
(2, 'Furniture', 0.00, NULL, NULL),
(3, 'Office Supplies', 0.00, NULL, NULL);

-- Products
DROP TABLE IF EXISTS thc9_products;
CREATE TABLE thc9_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    base_price DECIMAL(10,2),
    current_price DECIMAL(10,2),
    is_discounted BOOLEAN DEFAULT FALSE
);

INSERT INTO thc9_products VALUES
(101, 'Laptop', 1, 1200.00, 1200.00, FALSE),
(102, 'Mouse', 1, 25.00, 25.00, FALSE),
(103, 'Monitor', 1, 300.00, 300.00, FALSE),
(104, 'Desk', 2, 450.00, 450.00, FALSE),
(105, 'Chair', 2, 275.00, 275.00, FALSE),
(106, 'Notebook', 3, 5.00, 5.00, FALSE),
(107, 'Pen Set', 3, 12.00, 12.00, FALSE);

-- Orders (some pending, some completed)
DROP TABLE IF EXISTS thc9_orders;
CREATE TABLE thc9_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    subtotal DECIMAL(10,2),
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2)
);

INSERT INTO thc9_orders VALUES
(1001, 201, '2025-11-01', 'completed', 1525.00, 0.00, 1525.00),
(1002, 202, '2025-11-03', 'pending', 725.00, 0.00, 725.00),
(1003, 203, '2025-11-04', 'pending', 1200.00, 0.00, 1200.00),
(1004, 204, '2025-11-05', 'processing', 450.00, 0.00, 450.00),
(1005, 205, '2025-11-05', 'pending', 287.00, 0.00, 287.00);

-- Order items (details of what's in each order)
DROP TABLE IF EXISTS thc9_order_items;
CREATE TABLE thc9_order_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    line_total DECIMAL(10,2)
);

INSERT INTO thc9_order_items VALUES
(1, 1001, 101, 1, 1200.00, 1200.00),
(2, 1001, 102, 2, 25.00, 50.00),
(3, 1001, 104, 1, 275.00, 275.00),
(4, 1002, 101, 1, 1200.00, 1200.00),  -- pending order
(5, 1002, 103, 1, 300.00, 300.00),     -- pending order
(6, 1003, 102, 1, 25.00, 25.00),       -- pending order
(7, 1003, 103, 1, 300.00, 300.00),     -- pending order
(8, 1004, 104, 1, 450.00, 450.00),     -- processing order
(9, 1005, 105, 1, 275.00, 275.00),     -- pending order
(10, 1005, 106, 1, 5.00, 5.00),        -- pending order
(11, 1005, 107, 1, 12.00, 12.00);      -- pending order (actually 107 is wrong - should be 7.00 total issue)

-- Customers with loyalty points
DROP TABLE IF EXISTS thc9_customers;
CREATE TABLE thc9_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    loyalty_points INT DEFAULT 0,
    lifetime_savings DECIMAL(10,2) DEFAULT 0.00
);

INSERT INTO thc9_customers VALUES
(201, 'Alice Johnson', 1500, 150.00),
(202, 'Bob Smith', 500, 45.00),
(203, 'Carol White', 800, 75.00),
(204, 'David Lee', 300, 25.00),
(205, 'Eve Brown', 1200, 100.00);

-- Price change audit
DROP TABLE IF EXISTS thc9_price_audit;
CREATE TABLE thc9_price_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    reason VARCHAR(100),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Parts

**A) Apply Category Discount**  
A Black Friday sale starts on 2025-11-06 and runs through 2025-11-10:
- Electronics: 15% off
- Furniture: 20% off
- Office Supplies: 10% off

Update the `thc9_categories` table with these discounts and dates. Then cascade the discount to all products in these categories (update `current_price` and `is_discounted` flag). Log all price changes to the audit table.

**B) Recalculate Pending Orders**  
Update all pending orders to reflect the new discounted prices:
1. Update `unit_price` and `line_total` in `thc9_order_items` for pending orders only
2. Recalculate order `subtotal`, `discount_amount`, and `total_amount` in `thc9_orders`
3. Only affect orders with status 'pending' (not 'completed' or 'processing')

**C) Update Customer Loyalty**  
For each customer with pending orders that received discounts:
1. Award bonus loyalty points: 10 points for every $10 saved
2. Add the discount amount to their `lifetime_savings`

**D) Open-Ended: Discount Impact Report**  
Create a comprehensive report showing:
- Total revenue impact (original vs discounted)
- Products by category with before/after prices
- Customer savings summary
- Orders affected with detailed breakdown
- Recommend which products should have stock increased based on discount attractiveness

### Solutions and Notes

<details>
<summary>Click to reveal solutions</summary>

```sql
-- A) Apply category discount
START TRANSACTION;

-- Step 1: Update category discount information
UPDATE thc9_categories
SET 
    discount_rate = CASE 
        WHEN category_name = 'Electronics' THEN 15.00
        WHEN category_name = 'Furniture' THEN 20.00
        WHEN category_name = 'Office Supplies' THEN 10.00
    END,
    discount_start = '2025-11-06',
    discount_end = '2025-11-10'
WHERE category_name IN ('Electronics', 'Furniture', 'Office Supplies');

-- Step 2: Log price changes before updating
INSERT INTO thc9_price_audit (product_id, old_price, new_price, reason)
SELECT 
    p.product_id,
    p.current_price,
    ROUND(p.base_price * (1 - c.discount_rate / 100), 2),
    CONCAT('Black Friday Sale: ', c.discount_rate, '% off ', c.category_name)
FROM thc9_products p
JOIN thc9_categories c ON p.category_id = c.category_id
WHERE c.discount_rate > 0;

-- Step 3: Apply discounts to products
UPDATE thc9_products p
JOIN thc9_categories c ON p.category_id = c.category_id
SET 
    p.current_price = ROUND(p.base_price * (1 - c.discount_rate / 100), 2),
    p.is_discounted = TRUE
WHERE c.discount_rate > 0;

-- Verify product price updates
SELECT 
    p.product_name,
    c.category_name,
    p.base_price,
    p.current_price,
    c.discount_rate,
    p.base_price - p.current_price as savings
FROM thc9_products p
JOIN thc9_categories c ON p.category_id = c.category_id
ORDER BY c.category_id, p.product_id;

COMMIT;

-- B) Recalculate pending orders
START TRANSACTION;

-- Step 1: Update order item prices for pending orders
UPDATE thc9_order_items oi
JOIN thc9_orders o ON oi.order_id = o.order_id
JOIN thc9_products p ON oi.product_id = p.product_id
SET 
    oi.unit_price = p.current_price,
    oi.line_total = p.current_price * oi.quantity
WHERE o.status = 'pending'
  AND p.is_discounted = TRUE;

-- Step 2: Recalculate order subtotals and totals
UPDATE thc9_orders o
SET 
    subtotal = (
        SELECT SUM(line_total)
        FROM thc9_order_items oi
        WHERE oi.order_id = o.order_id
    ),
    discount_amount = (
        SELECT SUM((oi_old.line_total - oi_new.line_total))
        FROM (
            SELECT order_id, product_id, quantity * base_price as line_total
            FROM thc9_order_items oi2
            JOIN thc9_products p ON oi2.product_id = p.product_id
            WHERE oi2.order_id = o.order_id
        ) oi_old
        JOIN thc9_order_items oi_new ON oi_old.order_id = oi_new.order_id AND oi_old.product_id = oi_new.product_id
    ),
    total_amount = (
        SELECT SUM(line_total)
        FROM thc9_order_items oi
        WHERE oi.order_id = o.order_id
    )
WHERE o.status = 'pending';

-- Simplified alternative for discount_amount calculation
UPDATE thc9_orders o
JOIN (
    SELECT 
        oi.order_id,
        SUM((p.base_price - p.current_price) * oi.quantity) as total_discount
    FROM thc9_order_items oi
    JOIN thc9_products p ON oi.product_id = p.product_id
    WHERE p.is_discounted = TRUE
    GROUP BY oi.order_id
) discounts ON o.order_id = discounts.order_id
SET 
    o.discount_amount = discounts.total_discount
WHERE o.status = 'pending';

-- Verify order updates
SELECT 
    o.order_id,
    o.customer_id,
    o.status,
    o.subtotal,
    o.discount_amount,
    o.total_amount,
    ROUND((o.discount_amount / (o.subtotal + o.discount_amount)) * 100, 1) as discount_percent
FROM thc9_orders o
WHERE o.status = 'pending'
ORDER BY o.order_id;

COMMIT;

-- C) Update customer loyalty
START TRANSACTION;

UPDATE thc9_customers c
JOIN (
    SELECT 
        o.customer_id,
        SUM(o.discount_amount) as total_saved,
        FLOOR(SUM(o.discount_amount) / 10) * 10 as bonus_points
    FROM thc9_orders o
    WHERE o.status = 'pending' AND o.discount_amount > 0
    GROUP BY o.customer_id
) savings ON c.customer_id = savings.customer_id
SET 
    c.loyalty_points = c.loyalty_points + savings.bonus_points,
    c.lifetime_savings = c.lifetime_savings + savings.total_saved;

-- Verify customer updates
SELECT 
    c.customer_id,
    c.customer_name,
    c.loyalty_points,
    c.lifetime_savings,
    o.order_id,
    o.discount_amount
FROM thc9_customers c
LEFT JOIN thc9_orders o ON c.customer_id = o.customer_id AND o.status = 'pending'
ORDER BY c.customer_id;

COMMIT;

-- D) Discount Impact Report

-- 1. Total revenue impact
SELECT '=== REVENUE IMPACT ANALYSIS ===' as report;

SELECT 
    'Revenue Comparison' as metric,
    SUM(p.base_price * oi.quantity) as original_revenue,
    SUM(oi.line_total) as discounted_revenue,
    SUM(p.base_price * oi.quantity) - SUM(oi.line_total) as revenue_loss,
    ROUND(((SUM(p.base_price * oi.quantity) - SUM(oi.line_total)) / SUM(p.base_price * oi.quantity)) * 100, 2) as discount_percent
FROM thc9_order_items oi
JOIN thc9_orders o ON oi.order_id = o.order_id
JOIN thc9_products p ON oi.product_id = p.product_id
WHERE o.status = 'pending';

-- 2. Products by category with price changes
SELECT '=== PRODUCT PRICING DETAIL ===' as report;

SELECT 
    c.category_name,
    p.product_name,
    p.base_price,
    p.current_price,
    p.base_price - p.current_price as savings_per_unit,
    c.discount_rate as discount_pct,
    CASE WHEN p.is_discounted THEN 'Yes' ELSE 'No' END as on_sale
FROM thc9_products p
JOIN thc9_categories c ON p.category_id = c.category_id
ORDER BY c.category_id, p.product_id;

-- 3. Customer savings summary
SELECT '=== CUSTOMER SAVINGS SUMMARY ===' as report;

SELECT 
    c.customer_name,
    COUNT(DISTINCT o.order_id) as pending_orders,
    SUM(o.discount_amount) as total_savings,
    SUM(o.total_amount) as discounted_total,
    c.loyalty_points,
    c.lifetime_savings
FROM thc9_customers c
LEFT JOIN thc9_orders o ON c.customer_id = o.customer_id AND o.status = 'pending'
GROUP BY c.customer_id, c.customer_name, c.loyalty_points, c.lifetime_savings
HAVING COUNT(DISTINCT o.order_id) > 0
ORDER BY total_savings DESC;

-- 4. Orders affected with detailed breakdown
SELECT '=== AFFECTED ORDERS DETAIL ===' as report;

SELECT 
    o.order_id,
    c.customer_name,
    GROUP_CONCAT(CONCAT(p.product_name, ' (', oi.quantity, 'x)') SEPARATOR ', ') as items,
    o.subtotal + o.discount_amount as original_total,
    o.discount_amount,
    o.total_amount as final_total,
    ROUND((o.discount_amount / (o.subtotal + o.discount_amount)) * 100, 1) as discount_pct
FROM thc9_orders o
JOIN thc9_customers c ON o.customer_id = c.customer_id
JOIN thc9_order_items oi ON o.order_id = oi.order_id
JOIN thc9_products p ON oi.product_id = p.product_id
WHERE o.status = 'pending' AND o.discount_amount > 0
GROUP BY o.order_id, c.customer_name, o.subtotal, o.discount_amount, o.total_amount
ORDER BY o.discount_amount DESC;

-- 5. Stock recommendations based on discount attractiveness
SELECT '=== STOCK RECOMMENDATIONS ===' as report;

SELECT 
    c.category_name,
    p.product_name,
    c.discount_rate as discount_pct,
    COUNT(oi.item_id) as times_ordered_pending,
    SUM(oi.quantity) as total_qty_pending,
    p.base_price - p.current_price as savings_per_unit,
    CASE 
        WHEN c.discount_rate >= 15 AND COUNT(oi.item_id) >= 2 THEN 'HIGH PRIORITY - Increase stock significantly'
        WHEN c.discount_rate >= 15 OR COUNT(oi.item_id) >= 2 THEN 'MEDIUM - Moderate stock increase'
        WHEN c.discount_rate >= 10 THEN 'LOW - Monitor demand'
        ELSE 'HOLD - No action needed'
    END as recommendation
FROM thc9_products p
JOIN thc9_categories c ON p.category_id = c.category_id
LEFT JOIN thc9_order_items oi ON p.product_id = oi.product_id
LEFT JOIN thc9_orders o ON oi.order_id = o.order_id AND o.status = 'pending'
WHERE p.is_discounted = TRUE
GROUP BY c.category_name, p.product_name, c.discount_rate, p.base_price, p.current_price
ORDER BY c.discount_rate DESC, times_ordered_pending DESC;

-- 6. Audit trail verification
SELECT '=== PRICE CHANGE AUDIT ===' as report;

SELECT 
    pa.product_id,
    p.product_name,
    pa.old_price,
    pa.new_price,
    pa.old_price - pa.new_price as price_reduction,
    pa.reason,
    pa.change_date
FROM thc9_price_audit pa
JOIN thc9_products p ON pa.product_id = p.product_id
WHERE DATE(pa.change_date) = CURDATE()
ORDER BY pa.change_date DESC;
```

### Trade-offs and Notes

1. **Cascade Complexity:**
   - Updates span 6 tables with complex dependencies
   - Must maintain referential integrity throughout
   - Order of operations critical (products → order items → orders → customers)

2. **Performance Considerations:**
   - For large datasets, batch updates by category
   - Consider temporary tables for complex calculations
   - Index on status, product_id, order_id critical for performance

3. **Business Logic:**
   - Only pending orders affected (not completed/processing)
   - Loyalty points rounded to nearest 10
   - Discounts compound (no additional discount on already-discounted items)

4. **Alternative Approaches:**
   - Could use triggers to auto-update cascades
   - Stored procedure to encapsulate entire promotion logic
   - Materialized views for faster reporting

5. **Safety & Rollback:**
   - Critical to use transactions for multi-table updates
   - Test on copy of production data first
   - Consider implementing "dry run" mode to preview changes
   - Keep backup before applying promotional pricing

6. **Audit & Compliance:**
   - Price changes fully logged
   - Customer savings tracked for tax/accounting
   - Can reconstruct original prices from audit trail
   - Consider adding user_id to audit for accountability

</details>

---

## 🎯 Summary

These challenges demonstrate real-world DML scenarios:

1. **Challenge 1 (Deduplication):** Data quality and referential integrity
2. **Challenge 2 (Data Sync):** ETL operations and change tracking
3. **Challenge 3 (Cascade Updates):** Complex multi-table updates with business logic

**Key Takeaways:**
- Always use transactions for complex DML
- Test with SELECT before UPDATE/DELETE
- Log changes for audit trails
- Consider performance for large datasets
- Validate results at each step
- Have rollback plan ready

**Production Best Practices:**
- Backup before major changes
- Test on non-production data first
- Monitor affected row counts
- Implement error handling
- Document business logic
- Schedule intensive operations during off-peak hours
