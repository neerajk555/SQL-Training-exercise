# Speed Drills: DML Operations (10 questions, 2–3 min each)

**How to use:** Try to answer each question quickly. Answers immediately follow each question for self-scoring.

**⚠️ Safety First:** All answers assume you're testing in a safe environment with backups and transactions!

---

## Drill 1: Basic INSERT Syntax

**Question:** Write an INSERT statement to add a product: ID=100, Name='Mouse Pad', Price=9.99 into table `products` with columns `(product_id, name, price)`.

<details>
<summary>✅ Answer</summary>

```sql
INSERT INTO products (product_id, name, price)
VALUES (100, 'Mouse Pad', 9.99);
```

**Key points:**
- Specify column names in parentheses
- Match values in same order
- Use quotes for strings, not for numbers
</details>

---

## Drill 2: Multiple Row INSERT

**Question:** Insert 3 customers in ONE statement into `customers (id, name, city)`: 
- (1, 'Alice', 'Austin')
- (2, 'Bob', 'Dallas')
- (3, 'Carol', 'Houston')

<details>
<summary>✅ Answer</summary>

```sql
INSERT INTO customers (id, name, city)
VALUES 
    (1, 'Alice', 'Austin'),
    (2, 'Bob', 'Dallas'),
    (3, 'Carol', 'Houston');
```

**Key points:**
- Separate value sets with commas
- More efficient than 3 separate INSERTs
- All succeed or all fail (atomic)
</details>

---

## Drill 3: UPDATE with WHERE

**Question:** Write UPDATE to change price to 1100.00 for product_id = 5 in table `products`.

<details>
<summary>✅ Answer</summary>

```sql
UPDATE products
SET price = 1100.00
WHERE product_id = 5;
```

**Key points:**
- WHERE is CRITICAL (without it, ALL rows update!)
- SET specifies new value
- Test with SELECT first
</details>

---

## Drill 4: UPDATE Multiple Columns

**Question:** Update product_id 10 to set name='Laptop Pro' AND price=1299.99 in one statement.

<details>
<summary>✅ Answer</summary>

```sql
UPDATE products
SET name = 'Laptop Pro', price = 1299.99
WHERE product_id = 10;
```

**Key points:**
- Separate multiple SET clauses with commas
- All updates happen together (atomic)
- Still needs WHERE clause
</details>

---

## Drill 5: DELETE with WHERE

**Question:** Delete all orders with status='cancelled' from table `orders`.

<details>
<summary>✅ Answer</summary>

```sql
DELETE FROM orders
WHERE status = 'cancelled';
```

**Key points:**
- WHERE is MANDATORY (without it, ALL rows deleted!)
- No SET clause (unlike UPDATE)
- Test with SELECT first: `SELECT * FROM orders WHERE status = 'cancelled'`
</details>

---

## Drill 6: INSERT...SELECT

**Question:** Copy all completed orders from `orders` to `orders_archive` table (both have same structure).

<details>
<summary>✅ Answer</summary>

```sql
INSERT INTO orders_archive
SELECT * FROM orders
WHERE status = 'completed';
```

**Alternative (explicit columns):**
```sql
INSERT INTO orders_archive (order_id, customer_id, order_date, status, total)
SELECT order_id, customer_id, order_date, status, total
FROM orders
WHERE status = 'completed';
```

**Key points:**
- INSERT...SELECT copies data from query results
- No VALUES clause needed
- WHERE clause filters source data
- Column counts must match
</details>

---

## Drill 7: REPLACE vs INSERT

**Question:** What's the difference between `REPLACE INTO` and `INSERT INTO`?

<details>
<summary>✅ Answer</summary>

**INSERT INTO:**
- Fails if primary/unique key already exists
- Error: "Duplicate entry"
- Safe: won't accidentally delete data

**REPLACE INTO:**
- If key exists: **deletes old row**, then inserts new one
- If key doesn't exist: acts like regular INSERT
- Dangerous: can lose data (e.g., columns not specified in REPLACE)

**Example:**
```sql
-- Table has: (1, 'Laptop', 1200.00, 50) -- id, name, price, quantity

-- INSERT fails:
INSERT INTO products VALUES (1, 'Monitor', 300.00, 30);  -- ERROR: Duplicate key

-- REPLACE succeeds but DELETES old row first:
REPLACE INTO products (product_id, name, price) 
VALUES (1, 'Monitor', 300.00);  
-- Result: (1, 'Monitor', 300.00, NULL) -- quantity lost!
```

**When to use:**
- INSERT: Default choice (safe)
- REPLACE: Only when you explicitly want delete+insert behavior
- Better alternative: `INSERT...ON DUPLICATE KEY UPDATE`
</details>

---

## Drill 8: ON DUPLICATE KEY UPDATE (Upsert)

**Question:** Insert product (id=5, name='Mouse', price=25.00). If id=5 exists, update price only. Write using `ON DUPLICATE KEY UPDATE`.

<details>
<summary>✅ Answer</summary>

```sql
INSERT INTO products (product_id, name, price)
VALUES (5, 'Mouse', 25.00)
ON DUPLICATE KEY UPDATE 
    price = VALUES(price);
```

**Alternative (MySQL 8.0+ alias syntax):**
```sql
INSERT INTO products (product_id, name, price)
VALUES (5, 'Mouse', 25.00)
ON DUPLICATE KEY UPDATE 
    price = 25.00;
```

**Or update multiple columns:**
```sql
INSERT INTO products (product_id, name, price)
VALUES (5, 'Mouse', 25.00)
ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    price = VALUES(price);
```

**Key points:**
- If id=5 doesn't exist: regular INSERT
- If id=5 exists: UPDATE specified columns only (other columns preserved)
- Safer than REPLACE (doesn't delete entire row)
- VALUES(column) refers to value in INSERT clause
</details>

---

## Drill 9: DELETE vs TRUNCATE

**Question:** What's the difference between `DELETE FROM table` and `TRUNCATE TABLE`?

<details>
<summary>✅ Answer</summary>

| Feature | DELETE FROM table | TRUNCATE TABLE |
|---------|-------------------|----------------|
| **Speed** | Slower (row-by-row) | Faster (drops/recreates) |
| **WHERE** | Can use WHERE clause | No WHERE (all rows) |
| **Rollback** | Can rollback in transaction | Can't rollback (DDL) |
| **Triggers** | Fires DELETE triggers | Doesn't fire triggers |
| **Auto-increment** | Doesn't reset | Resets to 1 |
| **Logging** | Fully logged | Minimally logged |

**Examples:**
```sql
-- DELETE: Remove specific rows, can rollback
START TRANSACTION;
DELETE FROM products WHERE price < 10;  -- Can use WHERE
ROLLBACK;  -- Can undo

-- TRUNCATE: Remove all rows, faster, can't rollback
TRUNCATE TABLE products;  -- All rows gone, auto-increment reset to 1
```

**When to use:**
- **DELETE**: Removing specific rows, need rollback, need triggers
- **TRUNCATE**: Emptying entire table quickly, resetting auto-increment

**⚠️ Warning:** TRUNCATE is DDL (not DML), can't be rolled back!
</details>

---

## Drill 10: Transaction Safety

**Question:** Write a transaction that: 1) Updates product price, 2) Inserts an audit log entry, 3) Commits if both succeed, rolls back if either fails.

<details>
<summary>✅ Answer</summary>

```sql
-- Start transaction
START TRANSACTION;

-- Step 1: Update product price
UPDATE products
SET price = 1299.99
WHERE product_id = 10;

-- Step 2: Log the change
INSERT INTO audit_log (table_name, record_id, action, change_date)
VALUES ('products', 10, 'price_update', NOW());

-- Step 3: Check both succeeded (manually or programmatically)
-- If both statements succeeded:
COMMIT;

-- If anything went wrong:
-- ROLLBACK;
```

**Better (with savepoints):**
```sql
START TRANSACTION;

-- Savepoint after first operation
UPDATE products SET price = 1299.99 WHERE product_id = 10;
SAVEPOINT after_update;

-- Second operation
INSERT INTO audit_log (table_name, record_id, action, change_date)
VALUES ('products', 10, 'price_update', NOW());

-- If INSERT failed, rollback to savepoint (keep UPDATE):
-- ROLLBACK TO SAVEPOINT after_update;

-- If all good:
COMMIT;
```

**Key points:**
- START TRANSACTION begins transaction
- All DML inside transaction is temporary until COMMIT
- ROLLBACK undoes all changes since START TRANSACTION
- SAVEPOINT allows partial rollback
- If connection lost before COMMIT, auto-rollback occurs
- Transactions ensure "all or nothing" (atomicity)

**Real-world template:**
```sql
START TRANSACTION;
    -- Your DML operations
    UPDATE ...;
    INSERT ...;
    DELETE ...;
    
    -- Verify results with SELECT
    SELECT * FROM ... WHERE ...;
    
    -- If everything looks good:
    COMMIT;
    -- If something's wrong:
    -- ROLLBACK;
```
</details>

---

## 🎯 Bonus Rapid-Fire Questions

### B1: What's wrong with this DELETE?
```sql
DELETE FROM users;
```
**Answer:** Missing WHERE clause! Deletes ALL users. Should be:
```sql
DELETE FROM users WHERE status = 'inactive';
```

---

### B2: What does this return?
```sql
INSERT INTO products (name, price) VALUES ('Mouse', 25.00);
SELECT LAST_INSERT_ID();
```
**Answer:** Returns the auto-generated `product_id` value from the INSERT.

---

### B3: How to update with calculation?
```sql
-- Increase all prices by 10%
UPDATE products SET price = price * 1.10;
```
**Answer:** Use column in calculation. Better with WHERE: `WHERE category = 'electronics'`

---

### B4: How to insert if not exists (without error)?
```sql
INSERT IGNORE INTO products (product_id, name, price)
VALUES (5, 'Mouse', 25.00);
```
**Answer:** `INSERT IGNORE` silently skips if duplicate key exists.

---

### B5: How to copy table structure AND data?
```sql
-- Structure + Data:
CREATE TABLE products_backup AS SELECT * FROM products;

-- Structure only:
CREATE TABLE products_backup LIKE products;
```

---

## 📝 Key Commands Summary

```sql
-- INSERT variants
INSERT INTO table (cols) VALUES (vals);                    -- Single row
INSERT INTO table (cols) VALUES (v1), (v2), (v3);         -- Multiple rows
INSERT INTO table SELECT ... FROM other_table;             -- From query
INSERT IGNORE INTO table VALUES (...);                     -- Skip duplicates
REPLACE INTO table VALUES (...);                           -- Delete + insert
INSERT ... ON DUPLICATE KEY UPDATE col=val;                -- Upsert

-- UPDATE variants
UPDATE table SET col = val WHERE condition;                -- Basic
UPDATE table SET col1 = v1, col2 = v2 WHERE condition;    -- Multiple columns
UPDATE t1 JOIN t2 ON ... SET t1.col = t2.col;             -- With JOIN

-- DELETE variants
DELETE FROM table WHERE condition;                         -- Specific rows
TRUNCATE TABLE table;                                      -- All rows (fast)

-- Transaction control
START TRANSACTION;                                         -- Begin
COMMIT;                                                    -- Save changes
ROLLBACK;                                                  -- Undo changes
SAVEPOINT name;                                            -- Checkpoint
ROLLBACK TO SAVEPOINT name;                                -- Partial undo
```

---

## 🏆 Scoring Guide

- **10/10**: DML expert! You know your INSERTs from your UPSERTs
- **8-9/10**: Strong foundation, minor details to review
- **6-7/10**: Good basics, practice safety patterns more
- **4-5/10**: Review WHERE clauses and transactions
- **0-3/10**: Revisit module materials, practice with safe test data

**Remember:** Speed is good, but safety is better! Always use transactions and WHERE clauses!