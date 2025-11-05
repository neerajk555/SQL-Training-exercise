# Module 09 · DML Operations

## 🎯 What is DML?

**Simple Explanation:** DML (Data Manipulation Language) is how you **change** data in your database. Think of it as the "editing" commands for your data.

**Real-World Analogy:** If your database is a filing cabinet:
- **INSERT**: Adding new documents to a folder
- **UPDATE**: Editing information on existing documents
- **DELETE**: Removing documents you no longer need
- **SELECT** (not DML): Just looking at documents without changing them

**⚠️ CRITICAL SAFETY WARNING:** Unlike SELECT (which only reads data), DML commands **permanently change** your data! Always:
- Test with SELECT first
- Use WHERE clauses carefully
- Work in transactions when possible
- Have backups!

DML (Data Manipulation Language) statements modify data in tables: INSERT adds rows, UPDATE modifies existing rows, DELETE removes rows, and REPLACE handles upserts.

## Topics Covered

### 1. INSERT - Adding New Data

**Simple Explanation:** INSERT adds new rows to a table. Like adding a new entry to a spreadsheet.

**Three Ways to INSERT:**

```sql
-- 1. Single row INSERT
INSERT INTO products (name, price) VALUES ('Laptop', 1200.00);
-- Adds one product to the table

-- 2. Multiple rows INSERT (more efficient!)
INSERT INTO products (name, price) VALUES 
  ('Mouse', 25.00), 
  ('Keyboard', 75.00),
  ('Monitor', 300.00);
-- Adds three products in one statement (faster than 3 separate INSERTs)

-- 3. INSERT from SELECT (copy data from another query)
INSERT INTO archive_orders 
SELECT * FROM orders 
WHERE order_date < '2024-01-01';
-- Copies old orders to archive table
```

**💡 MySQL Tip:** Always specify column names `INSERT INTO table (col1, col2)` instead of `INSERT INTO table VALUES (...)`. This prevents errors if table structure changes.

**Common INSERT Options:**
- `INSERT IGNORE`: Skip rows that would cause errors (like duplicates)
- `INSERT ... ON DUPLICATE KEY UPDATE`: Update if key exists, insert if not (upsert)
- `REPLACE INTO`: Delete existing row and insert new one

---

### 2. UPDATE - Modifying Existing Data

**Simple Explanation:** UPDATE changes values in existing rows. Like editing cells in a spreadsheet.

**⚠️ DANGER ZONE:** UPDATE without WHERE affects **ALL ROWS**!

```sql
-- ❌ DANGEROUS: Updates ALL products!
UPDATE products SET price = 100;

-- ✅ SAFE: Updates only laptops
UPDATE products SET price = 100 WHERE name = 'Laptop';
```

**Common UPDATE Patterns:**

```sql
-- Simple UPDATE (one column)
UPDATE products 
SET price = 1300.00 
WHERE name = 'Laptop';

-- Multiple columns
UPDATE products 
SET price = 1300.00, stock = 50 
WHERE name = 'Laptop';

-- Conditional UPDATE with CASE
UPDATE products 
SET discount = CASE 
  WHEN price > 1000 THEN 0.10
  WHEN price > 500 THEN 0.05
  ELSE 0
END
WHERE category = 'Electronics';

-- UPDATE with calculation
UPDATE products 
SET price = price * 1.10 
WHERE category = 'Electronics';
-- Increases prices by 10%

-- UPDATE with JOIN (advanced)
UPDATE inventory i 
JOIN products p ON i.product_id = p.product_id
SET i.quantity = i.quantity - 1 
WHERE p.name = 'Laptop';
-- Reduces inventory based on product name
```

**💡 MySQL Tip:** Always test your WHERE clause with SELECT first!
```sql
-- Step 1: Test which rows will be affected
SELECT * FROM products WHERE category = 'Electronics';

-- Step 2: If correct, change SELECT to UPDATE
UPDATE products SET price = price * 1.10 WHERE category = 'Electronics';
```

---

### 3. DELETE - Removing Data

**Simple Explanation:** DELETE removes rows from a table. Like deleting rows from a spreadsheet.

**⚠️ EXTREME DANGER:** DELETE without WHERE removes **ALL ROWS**!

```sql
-- ❌ CATASTROPHIC: Deletes ALL orders!
DELETE FROM orders;

-- ✅ SAFE: Deletes only cancelled orders
DELETE FROM orders WHERE status = 'cancelled';
```

**Safe DELETE Pattern (ALWAYS use this!):**

```sql
-- Step 1: Test with SELECT first
SELECT * FROM orders 
WHERE status = 'cancelled' 
  AND order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);
-- Review: Are these the right rows to delete?

-- Step 2: If confirmed, change SELECT to DELETE
DELETE FROM orders 
WHERE status = 'cancelled' 
  AND order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);
```

**Common DELETE Patterns:**

```sql
-- DELETE with date condition
DELETE FROM sessions 
WHERE expires_at < NOW();

-- DELETE with subquery
DELETE FROM order_items 
WHERE order_id IN (
  SELECT order_id FROM orders WHERE status = 'cancelled'
);

-- DELETE with JOIN (MySQL-specific syntax)
DELETE oi 
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'cancelled';
```

**Alternative: Soft Delete (Recommended for Important Data!)**
```sql
-- Instead of deleting, mark as deleted
ALTER TABLE orders ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;

-- "Delete" by updating flag
UPDATE orders SET is_deleted = TRUE WHERE status = 'cancelled';

-- Query active orders
SELECT * FROM orders WHERE is_deleted = FALSE;
```

**💡 Why soft delete?**
- Can recover accidentally deleted data
- Maintains referential integrity
- Keeps audit trail
- Safer for production systems

---

### 4. TRUNCATE vs DELETE

**TRUNCATE:** Removes ALL rows, fast but can't be rolled back in transaction.
**DELETE:** Can use WHERE clause, slower but transaction-safe.

```sql
-- TRUNCATE: Fast, removes all rows, resets AUTO_INCREMENT
TRUNCATE TABLE temp_data;
-- Can't use WHERE, can't rollback

-- DELETE: Slower, can use WHERE, transaction-safe
DELETE FROM temp_data;
-- Can add WHERE clause
```

**When to use each:**
- **TRUNCATE**: Empty entire table, don't need rollback (e.g., clearing temp tables)
- **DELETE**: Remove specific rows or need transaction safety

---

### 5. ON DUPLICATE KEY UPDATE (Upsert)

**Simple Explanation:** "Insert if new, update if exists" - like a smart merge.

**Real-World Use:** Tracking user stats (increment if exists, start at 1 if new).

```sql
-- Setup: user_stats table with PRIMARY KEY on user_id
CREATE TABLE user_stats (
  user_id INT PRIMARY KEY,
  visit_count INT DEFAULT 0,
  last_visit DATETIME
);

-- Upsert: Insert new user or increment existing
INSERT INTO user_stats (user_id, visit_count, last_visit) 
VALUES (123, 1, NOW())
ON DUPLICATE KEY UPDATE 
  visit_count = visit_count + 1,
  last_visit = NOW();

-- First run: Inserts user 123 with visit_count = 1
-- Second run: Updates user 123, visit_count becomes 2
-- Third run: Updates user 123, visit_count becomes 3
```

**Common Upsert Patterns:**

```sql
-- Accumulate totals
INSERT INTO daily_sales (date, total) VALUES ('2025-11-06', 500)
ON DUPLICATE KEY UPDATE total = total + VALUES(total);

-- Update timestamp
INSERT INTO user_activity (user_id, last_seen) VALUES (123, NOW())
ON DUPLICATE KEY UPDATE last_seen = NOW();
```

---

### 6. Transaction Safety

**Simple Explanation:** Transactions let you test changes before making them permanent. Like "undo" functionality.

**Transaction Commands:**
- `START TRANSACTION` (or `BEGIN`): Start a transaction
- `COMMIT`: Make changes permanent
- `ROLLBACK`: Undo all changes since START TRANSACTION

```sql
-- Safe workflow for important changes
START TRANSACTION;

  -- Make changes
  UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
  UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
  
  -- Verify results
  SELECT * FROM accounts WHERE account_id IN (1, 2);
  -- If wrong, type: ROLLBACK;
  -- If correct, type: COMMIT;

COMMIT;  -- Makes changes permanent
-- OR
ROLLBACK;  -- Undoes all changes
```

**💡 MySQL Autocommit:** By default, MySQL auto-commits each statement. Use `START TRANSACTION` to disable this temporarily.

---

### 7. Bulk Operations & Performance

**Tip 1: Batch Inserts (Much Faster!)**
```sql
-- ❌ SLOW: 1000 separate statements
INSERT INTO products VALUES (1, 'Item 1');
INSERT INTO products VALUES (2, 'Item 2');
-- ... 998 more times

-- ✅ FAST: One statement with multiple rows
INSERT INTO products VALUES 
  (1, 'Item 1'),
  (2, 'Item 2'),
  (3, 'Item 3'),
  -- ... up to 1000 rows
  (1000, 'Item 1000');
-- Up to 100x faster!
```

**Tip 2: Use Indexes for UPDATE/DELETE**
```sql
-- Slow: No index on status column
DELETE FROM orders WHERE status = 'cancelled';

-- Fast: Add index first
CREATE INDEX idx_status ON orders(status);
DELETE FROM orders WHERE status = 'cancelled';
```

---

## Safety Checklist

Before running DML in production:
- [ ] Have a recent backup
- [ ] Tested WHERE clause with SELECT
- [ ] Verified affected row count
- [ ] Used transaction if possible
- [ ] Have rollback plan
- [ ] Run during low-traffic period
- [ ] Monitor for foreign key errors

**Remember:** With great power comes great responsibility! 🦸‍♂️

## Common Mistakes & How to Avoid Them

### Mistake 1: Forgetting WHERE Clause
```sql
-- ❌ Accidentally updates ALL rows!
UPDATE products SET price = 0;

-- ✅ Always use WHERE
UPDATE products SET price = 0 WHERE product_id = 123;
```

### Mistake 2: Not Testing First
```sql
-- ❌ Running DELETE without checking
DELETE FROM customers WHERE signup_date < '2020-01-01';

-- ✅ Test with SELECT first
SELECT COUNT(*) FROM customers WHERE signup_date < '2020-01-01';
-- Review count, then change to DELETE
```

### Mistake 3: Foreign Key Violations
```sql
-- ❌ Error: Can't delete customer with orders
DELETE FROM customers WHERE customer_id = 123;
-- ERROR: Cannot delete because orders reference this customer

-- ✅ Delete child records first (or use CASCADE)
DELETE FROM orders WHERE customer_id = 123;
DELETE FROM customers WHERE customer_id = 123;
```

### Mistake 4: Data Type Mismatch
```sql
-- ❌ String in numeric column
INSERT INTO products (price) VALUES ('expensive');
-- ERROR: Incorrect integer value

-- ✅ Use correct data type
INSERT INTO products (price) VALUES (99.99);
```

---

## MySQL-Specific Notes

**MySQL Safe Update Mode:**
```sql
-- Check if safe-update-mode is enabled
SHOW VARIABLES LIKE 'sql_safe_updates';

-- Disable temporarily (for learning only!)
SET SQL_SAFE_UPDATES = 0;

-- Re-enable (recommended for production!)
SET SQL_SAFE_UPDATES = 1;
```

**MySQL Date Functions:**
```sql
-- Current date/time
NOW()           -- 2025-11-06 14:30:00
CURDATE()       -- 2025-11-06
CURTIME()       -- 14:30:00

-- Date arithmetic
DATE_ADD(CURDATE(), INTERVAL 1 DAY)
DATE_SUB(CURDATE(), INTERVAL 1 YEAR)

-- Date comparison
WHERE order_date < CURDATE()
WHERE created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)
```

---

## Practice Strategy

**Level 1: Basics (Start Here!)**
1. Master INSERT (single, multiple, from SELECT)
2. Practice UPDATE with WHERE clauses
3. Learn safe DELETE patterns
4. Use SELECT to verify before UPDATE/DELETE

**Level 2: Intermediate**
5. Conditional updates with CASE
6. JOIN-based UPDATEs and DELETEs
7. Upserts with ON DUPLICATE KEY UPDATE
8. Transaction safety patterns

**Level 3: Advanced**
9. Bulk operations and performance
10. Complex data migrations
11. Error handling and validation
12. Production-safe deployment strategies

---

## Quick Reference

```sql
-- INSERT patterns
INSERT INTO table (col1, col2) VALUES (val1, val2);
INSERT INTO table (col1, col2) VALUES (v1, v2), (v3, v4);  -- Multiple
INSERT INTO table SELECT * FROM other WHERE condition;
INSERT INTO table VALUES (v1, v2) ON DUPLICATE KEY UPDATE col1 = v1;

-- UPDATE patterns  
UPDATE table SET col1 = val1 WHERE condition;
UPDATE table SET col1 = val1, col2 = val2 WHERE condition;
UPDATE t1 JOIN t2 ON t1.id = t2.id SET t1.col = val WHERE condition;

-- DELETE patterns
DELETE FROM table WHERE condition;
DELETE t1 FROM table1 t1 JOIN table2 t2 ON t1.id = t2.id WHERE condition;

-- Transaction pattern
START TRANSACTION;
  -- Your DML statements
  -- Check results
COMMIT;  -- or ROLLBACK;

-- Safety pattern
SELECT * FROM table WHERE condition;  -- Test first!
UPDATE table SET col = val WHERE condition;  -- Then modify
```

Remember: **Practice makes perfect, but backups make it safe!** 💾
