# Real-World Project: E-commerce Database Migration (60–90 min)

## 📋 Before You Start

### Learning Objectives
By completing this real-world project, you will:
- Apply INSERT, UPDATE, DELETE to data migration scenarios
- Practice data cleaning and transformation during migration
- Work with realistic legacy data issues (duplicates, NULLs, invalid refs)
- Build safe migration scripts with transactions and validation
- Develop skills for production data operations

### Project Approach
**Time Allocation (60-90 minutes):**
- 📖 **10 min**: Read migration requirements, identify data issues
- 🔧 **10 min**: Run setup, explore legacy data problems
- 💻 **40-60 min**: Execute migration phases with validation
- ✅ **10 min**: Review results, verify data integrity

**Critical Safety Practices:**
- ⚠️ **ALWAYS test with SELECT before UPDATE/DELETE**
- ⚠️ **Use transactions** (START TRANSACTION, COMMIT, ROLLBACK)
- ⚠️ **Verify row counts** after each operation
- ⚠️ **Back up data** before major changes
- ⚠️ **Test rollback scenarios** to ensure safety

**Success Tips:**
- ✅ Complete phases in order (they build on each other)
- ✅ Validate data after each phase
- ✅ Use WHERE carefully to target correct rows
- ✅ Document assumptions and decisions
- ✅ Test edge cases (NULL, duplicates, invalid FKs)

---

## 📋 Company Background

**ShopLegacy Inc.** is modernizing their 10-year-old e-commerce database. The legacy system has:
- Inconsistent data formats (mixed case, NULLs in critical fields)
- Duplicate customer records
- Orders with invalid product references
- No audit trail for data changes

## 🎯 Business Problem

Migrate data from legacy tables to a new normalized schema with:
- Data cleaning and standardization
- Deduplication of customer records
- Validation of referential integrity
- Audit logging for all changes
- Archival of invalid/old data

## 📊 Database Schema

### Legacy Tables (Source - DO NOT MODIFY)

```sql
-- Legacy customers (messy data!)
DROP TABLE IF EXISTS rwp_legacy_customers;
CREATE TABLE rwp_legacy_customers (
    old_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(30),
    city VARCHAR(50),
    status VARCHAR(20),
    created DATE
);
INSERT INTO rwp_legacy_customers VALUES
(1001, 'alice johnson', 'alice@email.com', '555-0101', 'austin', 'active', '2023-01-15'),
(1002, 'Alice Johnson', 'alice@email.com', '555-0101', 'Austin', 'active', '2023-01-16'),  -- DUPLICATE!
(1003, 'bob smith', NULL, '555-0102', 'dallas', 'active', '2023-02-01'),  -- Missing email
(1004, 'CAROL WHITE', 'carol@email.com', NULL, 'houston', 'inactive', '2023-03-10'),
(1005, 'david lee', 'david@email.com', '555-0104', 'MIAMI', 'active', '2023-04-05'),
(1006, 'Eve Brown', 'eve@email.com', '555-0105', 'Seattle', 'deleted', '2022-12-01'),  -- Old deleted
(1007, 'frank miller', 'frank@email.com', '555-0106', 'boston', 'active', '2023-05-20'),
(1008, 'ALICE JOHNSON', 'alice.j@email.com', '555-0101', 'Austin', 'active', '2023-06-01');  -- Another duplicate!

-- Legacy products
DROP TABLE IF EXISTS rwp_legacy_products;
CREATE TABLE rwp_legacy_products (
    old_product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    is_active INT
);
INSERT INTO rwp_legacy_products VALUES
(2001, 'Laptop Pro', 'electronics', 1200.00, 1),
(2002, 'wireless mouse', 'electronics', 25.00, 1),
(2003, 'DESK CHAIR', 'furniture', 199.99, 1),
(2004, 'notebook set', 'stationery', 15.00, 0),  -- Inactive
(2005, 'Monitor 24"', 'electronics', 300.00, 1),
(2006, 'Keyboard RGB', 'electronics', 89.99, 1),
(2007, 'OLD PRODUCT', 'discontinued', 50.00, 0);  -- Discontinued

-- Legacy orders
DROP TABLE IF EXISTS rwp_legacy_orders;
CREATE TABLE rwp_legacy_orders (
    old_order_id INT PRIMARY KEY,
    customer_id INT,  -- References old_id from customers
    product_id INT,   -- References old_product_id from products
    quantity INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    order_status VARCHAR(20)
);
INSERT INTO rwp_legacy_orders VALUES
(3001, 1001, 2001, 1, '2024-01-10', 1200.00, 'completed'),
(3002, 1002, 2002, 2, '2024-01-15', 50.00, 'completed'),  -- Duplicate customer
(3003, 1003, 2003, 1, '2024-02-01', 199.99, 'completed'),
(3004, 1005, 2005, 1, '2024-02-10', 300.00, 'pending'),
(3005, 1006, 2004, 3, '2023-11-20', 45.00, 'completed'),  -- Deleted customer, inactive product
(3006, 1007, 2001, 1, '2024-03-01', 1200.00, 'shipped'),
(3007, 9999, 2002, 1, '2024-03-05', 25.00, 'pending'),  -- INVALID customer_id!
(3008, 1005, 8888, 2, '2024-03-10', 100.00, 'pending'),  -- INVALID product_id!
(3009, 1001, 2006, 1, '2024-03-15', 89.99, 'completed');

-- Legacy metadata (for audit purposes)
DROP TABLE IF EXISTS rwp_legacy_system_info;
CREATE TABLE rwp_legacy_system_info (
    info_key VARCHAR(50) PRIMARY KEY,
    info_value VARCHAR(100),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO rwp_legacy_system_info VALUES
('version', '1.0', '2023-01-01 00:00:00'),
('total_customers', '8', '2023-06-01 10:00:00'),
('total_products', '7', '2023-05-01 10:00:00'),
('total_orders', '9', '2024-03-15 10:00:00');
```

### New Tables (Target - YOU WILL POPULATE THESE)

```sql
-- New customers (clean, normalized)
DROP TABLE IF EXISTS rwp_customers;
CREATE TABLE rwp_customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(30),
    city VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active',
    created_date DATE,
    legacy_id INT,  -- Track original ID
    INDEX idx_email (email),
    INDEX idx_legacy (legacy_id)
);

-- New products (standardized)
DROP TABLE IF EXISTS rwp_products;
CREATE TABLE rwp_products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2),
    is_active BOOLEAN DEFAULT TRUE,
    legacy_product_id INT,
    INDEX idx_legacy_product (legacy_product_id)
);

-- New orders (with foreign keys)
DROP TABLE IF EXISTS rwp_orders;
CREATE TABLE rwp_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    order_date DATE,
    total_amount DECIMAL(10,2),
    order_status VARCHAR(20),
    legacy_order_id INT,
    FOREIGN KEY (customer_id) REFERENCES rwp_customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES rwp_products(product_id),
    INDEX idx_legacy_order (legacy_order_id)
);

-- Archive table for invalid/deleted records
DROP TABLE IF EXISTS rwp_archive;
CREATE TABLE rwp_archive (
    archive_id INT AUTO_INCREMENT PRIMARY KEY,
    record_type VARCHAR(50),  -- 'customer', 'product', 'order'
    original_id INT,
    reason VARCHAR(200),
    data_snapshot TEXT,
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit log for migration tracking
DROP TABLE IF EXISTS rwp_migration_log;
CREATE TABLE rwp_migration_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    operation VARCHAR(50),
    record_count INT,
    status VARCHAR(20),
    notes TEXT,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🎯 Deliverables

### Part 1: Customer Migration with Deduplication (15–20 min)

**Requirements:**
1. Migrate ONLY 'active' customers to `rwp_customers`
2. Standardize names using INITCAP (first letter uppercase)
3. Standardize cities (proper case)
4. Handle duplicate emails by keeping the EARLIEST created record
5. Archive 'inactive' and 'deleted' customers
6. Log the operation

**Acceptance Criteria:**
- Alice Johnson appears only ONCE (oldest record wins)
- All names and cities are properly capitalized
- NULL emails are preserved (but noted)
- Inactive/deleted customers go to archive
- Migration log entry created

**Hints:**
- Use CONCAT and SUBSTRING functions for capitalization
- Use ROW_NUMBER() or GROUP BY to identify duplicates
- Consider using a temporary table for dedup logic

<details>
<summary>💡 Solution</summary>

```sql
START TRANSACTION;

-- Step 1: Archive inactive/deleted customers first
INSERT INTO rwp_archive (record_type, original_id, reason, data_snapshot)
SELECT 
    'customer',
    old_id,
    CONCAT('Status: ', status),
    CONCAT('ID:', old_id, ' Name:', name, ' Email:', COALESCE(email, 'NULL'), ' Status:', status)
FROM rwp_legacy_customers
WHERE status IN ('inactive', 'deleted');

-- Step 2: Create temporary table with cleaned data and ranking
CREATE TEMPORARY TABLE tmp_clean_customers AS
SELECT 
    old_id,
    CONCAT(UPPER(SUBSTRING(TRIM(name), 1, 1)), 
           LOWER(SUBSTRING(TRIM(name), 2))) AS full_name,
    LOWER(TRIM(email)) AS email,
    phone,
    CONCAT(UPPER(SUBSTRING(TRIM(city), 1, 1)), 
           LOWER(SUBSTRING(TRIM(city), 2))) AS city,
    status,
    created,
    ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(email)) ORDER BY created ASC) AS rn
FROM rwp_legacy_customers
WHERE status = 'active' AND email IS NOT NULL

UNION ALL

-- Handle customers with NULL emails separately (no dedup needed)
SELECT 
    old_id,
    CONCAT(UPPER(SUBSTRING(TRIM(name), 1, 1)), 
           LOWER(SUBSTRING(TRIM(name), 2))) AS full_name,
    NULL AS email,
    phone,
    CONCAT(UPPER(SUBSTRING(TRIM(city), 1, 1)), 
           LOWER(SUBSTRING(TRIM(city), 2))) AS city,
    status,
    created,
    1 AS rn
FROM rwp_legacy_customers
WHERE status = 'active' AND email IS NULL;

-- Step 3: Insert deduplicated data (only keep first occurrence per email)
INSERT INTO rwp_customers (full_name, email, phone, city, status, created_date, legacy_id)
SELECT 
    full_name,
    email,
    phone,
    city,
    status,
    created,
    old_id
FROM tmp_clean_customers
WHERE rn = 1;

-- Step 4: Log the migration
INSERT INTO rwp_migration_log (operation, record_count, status, notes)
SELECT 
    'Customer Migration',
    COUNT(*),
    'completed',
    CONCAT('Migrated ', COUNT(*), ' active customers with deduplication')
FROM rwp_customers;

-- Step 5: Verify results
SELECT 'Migrated Customers:' AS Summary, COUNT(*) AS Count FROM rwp_customers
UNION ALL
SELECT 'Archived Customers:', COUNT(*) FROM rwp_archive WHERE record_type = 'customer';

COMMIT;

-- Cleanup
DROP TEMPORARY TABLE IF EXISTS tmp_clean_customers;
```

**Expected Output:**
- ~4-5 active customers migrated (after dedup)
- 2-3 customers archived
- All names properly capitalized
- Alice Johnson appears only once

</details>

---

### Part 2: Product Migration with Standardization (10–15 min)

**Requirements:**
1. Migrate ONLY active products (is_active = 1)
2. Standardize product names (proper case, trim whitespace)
3. Standardize category names (lowercase)
4. Archive inactive products
5. Log the operation

**Acceptance Criteria:**
- Only active products migrated
- All product names properly formatted
- Categories are lowercase
- Inactive products archived
- Migration logged

<details>
<summary>💡 Solution</summary>

```sql
START TRANSACTION;

-- Step 1: Archive inactive products
INSERT INTO rwp_archive (record_type, original_id, reason, data_snapshot)
SELECT 
    'product',
    old_product_id,
    'Inactive product',
    CONCAT('ID:', old_product_id, ' Name:', product_name, ' Category:', category, ' Price:', price)
FROM rwp_legacy_products
WHERE is_active = 0;

-- Step 2: Migrate active products with standardization
INSERT INTO rwp_products (product_name, category, price, is_active, legacy_product_id)
SELECT 
    CONCAT(UPPER(SUBSTRING(TRIM(product_name), 1, 1)), 
           LOWER(SUBSTRING(TRIM(product_name), 2))) AS product_name,
    LOWER(TRIM(category)) AS category,
    price,
    TRUE,
    old_product_id
FROM rwp_legacy_products
WHERE is_active = 1;

-- Step 3: Log the migration
INSERT INTO rwp_migration_log (operation, record_count, status, notes)
SELECT 
    'Product Migration',
    COUNT(*),
    'completed',
    CONCAT('Migrated ', COUNT(*), ' active products')
FROM rwp_products;

-- Step 4: Verify
SELECT 'Migrated Products:' AS Summary, COUNT(*) AS Count FROM rwp_products
UNION ALL
SELECT 'Archived Products:', COUNT(*) FROM rwp_archive WHERE record_type = 'product';

COMMIT;
```

**Expected Output:**
- 5 active products migrated
- 2 inactive products archived
- All names and categories standardized

</details>

---

### Part 3: Order Migration with Validation (20–25 min)

**Requirements:**
1. Migrate orders with VALID customer and product references
2. Map legacy IDs to new IDs using the legacy_id fields
3. Archive orders with invalid references
4. Update order amounts if they don't match (product price × quantity)
5. Log the operation with breakdown

**Acceptance Criteria:**
- Only valid orders migrated (customer and product exist)
- Legacy IDs correctly mapped to new IDs
- Invalid orders archived with reason
- Amounts verified/corrected
- Detailed migration log

<details>
<summary>💡 Solution</summary>

```sql
START TRANSACTION;

-- Step 1: Create temporary table with validation
CREATE TEMPORARY TABLE tmp_order_validation AS
SELECT 
    lo.old_order_id,
    lo.customer_id AS legacy_customer_id,
    lo.product_id AS legacy_product_id,
    lo.quantity,
    lo.order_date,
    lo.total_amount,
    lo.order_status,
    c.customer_id AS new_customer_id,
    p.product_id AS new_product_id,
    p.price,
    (p.price * lo.quantity) AS calculated_amount,
    CASE 
        WHEN c.customer_id IS NULL THEN 'Invalid customer reference'
        WHEN p.product_id IS NULL THEN 'Invalid product reference'
        WHEN lc.status IN ('deleted', 'inactive') THEN 'Customer deleted/inactive'
        WHEN lp.is_active = 0 THEN 'Product inactive'
        ELSE 'valid'
    END AS validation_status
FROM rwp_legacy_orders lo
LEFT JOIN rwp_customers c ON lo.customer_id = c.legacy_id
LEFT JOIN rwp_products p ON lo.product_id = p.legacy_product_id
LEFT JOIN rwp_legacy_customers lc ON lo.customer_id = lc.old_id
LEFT JOIN rwp_legacy_products lp ON lo.product_id = lp.old_product_id;

-- Step 2: Archive invalid orders
INSERT INTO rwp_archive (record_type, original_id, reason, data_snapshot)
SELECT 
    'order',
    old_order_id,
    validation_status,
    CONCAT('OrderID:', old_order_id, ' Customer:', legacy_customer_id, 
           ' Product:', legacy_product_id, ' Qty:', quantity, ' Amount:', total_amount)
FROM tmp_order_validation
WHERE validation_status != 'valid';

-- Step 3: Insert valid orders (use calculated amount if original is wrong)
INSERT INTO rwp_orders (customer_id, product_id, quantity, order_date, total_amount, order_status, legacy_order_id)
SELECT 
    new_customer_id,
    new_product_id,
    quantity,
    order_date,
    calculated_amount,  -- Use calculated amount for consistency
    order_status,
    old_order_id
FROM tmp_order_validation
WHERE validation_status = 'valid';

-- Step 4: Log migration with breakdown
INSERT INTO rwp_migration_log (operation, record_count, status, notes)
SELECT 
    'Order Migration - Valid',
    COUNT(*),
    'completed',
    CONCAT('Migrated ', COUNT(*), ' valid orders')
FROM tmp_order_validation
WHERE validation_status = 'valid';

INSERT INTO rwp_migration_log (operation, record_count, status, notes)
SELECT 
    'Order Migration - Invalid Customer',
    COUNT(*),
    'archived',
    CONCAT('Archived ', COUNT(*), ' orders with invalid customer references')
FROM tmp_order_validation
WHERE validation_status = 'Invalid customer reference';

INSERT INTO rwp_migration_log (operation, record_count, status, notes)
SELECT 
    'Order Migration - Invalid Product',
    COUNT(*),
    'archived',
    CONCAT('Archived ', COUNT(*), ' orders with invalid product references')
FROM tmp_order_validation
WHERE validation_status = 'Invalid product reference';

-- Step 5: Verify results
SELECT 'Migration Summary' AS Report;
SELECT 'Migrated Orders:' AS Summary, COUNT(*) AS Count FROM rwp_orders
UNION ALL
SELECT 'Archived Orders:', COUNT(*) FROM rwp_archive WHERE record_type = 'order';

SELECT '---' AS Divider;
SELECT * FROM rwp_migration_log ORDER BY executed_at;

COMMIT;

-- Cleanup
DROP TEMPORARY TABLE IF EXISTS tmp_order_validation;
```

**Expected Output:**
- 5-6 valid orders migrated
- 3-4 invalid orders archived
- All amounts corrected
- Detailed breakdown in log

</details>

---

### Part 4: Data Validation and Reporting (10–15 min)

**Requirements:**
1. Generate a migration summary report
2. Verify referential integrity
3. Check for any data anomalies
4. Compare record counts with legacy system

**Queries to Run:**

```sql
-- Summary Report
SELECT '=== MIGRATION SUMMARY REPORT ===' AS Report;

SELECT 'Customers' AS Table_Name, 
       COUNT(*) AS New_Records,
       (SELECT COUNT(*) FROM rwp_legacy_customers WHERE status = 'active') AS Legacy_Active,
       (SELECT COUNT(*) FROM rwp_archive WHERE record_type = 'customer') AS Archived
UNION ALL
SELECT 'Products', 
       COUNT(*),
       (SELECT COUNT(*) FROM rwp_legacy_products WHERE is_active = 1),
       (SELECT COUNT(*) FROM rwp_archive WHERE record_type = 'product')
FROM rwp_products
UNION ALL
SELECT 'Orders', 
       COUNT(*),
       (SELECT COUNT(*) FROM rwp_legacy_orders),
       (SELECT COUNT(*) FROM rwp_archive WHERE record_type = 'order')
FROM rwp_orders;

-- Referential Integrity Check
SELECT '=== REFERENTIAL INTEGRITY CHECK ===' AS Report;

SELECT 'Orders with valid customers' AS Check_Type, COUNT(*) AS Count
FROM rwp_orders o
INNER JOIN rwp_customers c ON o.customer_id = c.customer_id
UNION ALL
SELECT 'Orders with valid products', COUNT(*) 
FROM rwp_orders o
INNER JOIN rwp_products p ON o.product_id = p.product_id;

-- Data Quality Checks
SELECT '=== DATA QUALITY CHECKS ===' AS Report;

SELECT 'Customers with email' AS Check_Type, COUNT(*) AS Count
FROM rwp_customers WHERE email IS NOT NULL
UNION ALL
SELECT 'Customers without email', COUNT(*)
FROM rwp_customers WHERE email IS NULL
UNION ALL
SELECT 'Orders with correct amounts', COUNT(*)
FROM rwp_orders o
INNER JOIN rwp_products p ON o.product_id = p.product_id
WHERE o.total_amount = (p.price * o.quantity);

-- Migration Log Review
SELECT '=== MIGRATION LOG ===' AS Report;
SELECT * FROM rwp_migration_log ORDER BY executed_at;

-- Archive Review
SELECT '=== ARCHIVE SUMMARY ===' AS Report;
SELECT record_type, reason, COUNT(*) AS count
FROM rwp_archive
GROUP BY record_type, reason
ORDER BY record_type, count DESC;
```

---

## 🎓 Evaluation Rubric (0–4 points each)

1. **Correctness** (4 pts)
   - All valid records migrated
   - Invalid records archived
   - No data loss

2. **Data Quality** (4 pts)
   - Names/cities properly formatted
   - Deduplication successful
   - Amounts corrected

3. **Referential Integrity** (4 pts)
   - All foreign keys valid
   - No orphaned orders
   - Legacy IDs properly mapped

4. **Audit Trail** (4 pts)
   - All operations logged
   - Archive has clear reasons
   - Timestamps recorded

5. **Safety** (4 pts)
   - Transactions used
   - Validation before migration
   - Rollback capability

**Total: 20 points**

---

## 💡 Bonus Challenges (Optional)

1. **Batch Processing**: Split migration into smaller batches (100 records at a time)
2. **Error Recovery**: Add rollback logic if any step fails
3. **Performance**: Add indexes after migration, measure query performance
4. **Reporting**: Create a dashboard view showing migration statistics
5. **Idempotency**: Make migration re-runnable (check if data already exists)

---

## 🚀 Real-World Applications

This project simulates actual data migration scenarios:
- **Legacy System Modernization**: Moving from old to new database schemas
- **Data Consolidation**: Merging multiple databases
- **Data Cleanup**: Standardizing messy production data
- **Compliance**: Archiving and audit trails for regulations
- **ETL Pipelines**: Extract, Transform, Load processes

## 📝 Key Takeaways

- ✅ Always validate before migrating
- ✅ Archive, don't delete (data recovery)
- ✅ Use transactions for atomicity
- ✅ Log everything (audit trail)
- ✅ Standardize data formats
- ✅ Check referential integrity
- ✅ Test with SELECT before INSERT/UPDATE/DELETE
- ✅ Map legacy IDs for traceability

**Remember:** In production, you'd also:
- Create backups before migration
- Test on staging environment first
- Have rollback procedures ready
- Monitor performance during migration
- Communicate downtime to stakeholders