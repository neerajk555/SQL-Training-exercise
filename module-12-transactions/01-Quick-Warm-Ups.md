# Quick Warm-Ups — Transactions (5–10 min each)

## 📋 Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Use START TRANSACTION to begin transactions
- Apply COMMIT to save changes permanently
- Use ROLLBACK to undo changes
- Understand ACID properties
- Handle errors safely with transactions

### Key Transaction Concepts for Beginners
**What are Transactions?**
- A group of SQL statements that execute as a single unit
- Either ALL statements succeed (COMMIT) or ALL fail (ROLLBACK)
- Protects data integrity during multi-step operations
- Example: Transferring money between accounts (debit one, credit other)

**Transaction Commands:**
- `START TRANSACTION;` or `BEGIN;` - Start a transaction
- `COMMIT;` - Save all changes permanently
- `ROLLBACK;` - Undo all changes since START TRANSACTION
- `SAVEPOINT name;` - Create a checkpoint within transaction
- `ROLLBACK TO SAVEPOINT name;` - Undo to specific checkpoint

**ACID Properties:**
- **Atomicity**: All or nothing (can't partially complete)
- **Consistency**: Database stays in valid state
- **Isolation**: Transactions don't interfere with each other
- **Durability**: Committed changes are permanent

**When to Use Transactions:**
- ✅ Financial transfers (debit + credit)
- ✅ Multi-table updates that must succeed together
- ✅ Any operation where partial completion would be bad
- ✅ Testing changes before committing

### Execution Tips
1. **Always START TRANSACTION** before related changes
2. **Test with SELECT** to verify results before COMMIT
3. **Use ROLLBACK** if anything looks wrong
4. **COMMIT only when certain** changes are correct

**Beginner Tip:** Transactions ensure all-or-nothing execution. Use START TRANSACTION, then COMMIT (success) or ROLLBACK (undo). Essential for data integrity!

---

## 1) Basic Transaction — 5 min
```sql
DROP TABLE IF EXISTS wu12_accounts;
CREATE TABLE wu12_accounts (
  account_id INT PRIMARY KEY,
  balance DECIMAL(10,2)
);
INSERT INTO wu12_accounts VALUES (1, 1000), (2, 500);
```

Task: Transfer $100 from account 1 to account 2 using transaction.

Solution:
```sql
START TRANSACTION;
UPDATE wu12_accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE wu12_accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;

SELECT * FROM wu12_accounts;
-- Both updates executed together!
```

---

## 2) ROLLBACK on Error — 6 min
```sql
DROP TABLE IF EXISTS wu12_inventory;
CREATE TABLE wu12_inventory (
  product_id INT PRIMARY KEY,
  stock INT CHECK (stock >= 0)
);
INSERT INTO wu12_inventory VALUES (1, 10);
```

Task: Try to set stock to -5, catch error, and rollback.

Solution:
```sql
START TRANSACTION;
UPDATE wu12_inventory SET stock = 8 WHERE product_id = 1;
-- Oops, mistake! Rollback
ROLLBACK;

SELECT * FROM wu12_inventory;
-- Stock still 10 (change was rolled back)
```

---

## 3) Multiple Operations — 7 min
```sql
DROP TABLE IF EXISTS wu12_orders, wu12_order_items;
CREATE TABLE wu12_orders (order_id INT PRIMARY KEY, total DECIMAL(10,2));
CREATE TABLE wu12_order_items (item_id INT PRIMARY KEY, order_id INT, price DECIMAL(10,2));
```

Task: Insert order and 2 items in single transaction.

Solution:
```sql
START TRANSACTION;
INSERT INTO wu12_orders VALUES (1, 150.00);
INSERT INTO wu12_order_items VALUES (1, 1, 75.00);
INSERT INTO wu12_order_items VALUES (2, 1, 75.00);
COMMIT;

-- All 3 inserts succeed or all fail together
SELECT * FROM wu12_orders;
SELECT * FROM wu12_order_items;
```

---

## 4) Savepoint — 7 min
```sql
DROP TABLE IF EXISTS wu12_logs;
CREATE TABLE wu12_logs (log_id INT PRIMARY KEY, message VARCHAR(100));
```

Task: Use savepoint to rollback part of transaction.

Solution:
```sql
START TRANSACTION;
INSERT INTO wu12_logs VALUES (1, 'First log');
SAVEPOINT sp1;
INSERT INTO wu12_logs VALUES (2, 'Second log');
ROLLBACK TO sp1;  -- Undo only second insert
COMMIT;

SELECT * FROM wu12_logs;
-- Only first log exists
```

---

## 5) Autocommit Mode — 6 min
```sql
-- Check autocommit status
SELECT @@autocommit;  -- 1 = ON (default)

-- Turn off autocommit
SET autocommit = 0;

DROP TABLE IF EXISTS wu12_test;
CREATE TABLE wu12_test (id INT PRIMARY KEY);
INSERT INTO wu12_test VALUES (1);
-- Not committed yet!

ROLLBACK;
SELECT * FROM wu12_test;  -- Empty!

SET autocommit = 1;  -- Turn back on
```

---

## 6) Isolation Level — 8 min
```sql
DROP TABLE IF EXISTS wu12_products;
CREATE TABLE wu12_products (product_id INT PRIMARY KEY, price DECIMAL(10,2));
INSERT INTO wu12_products VALUES (1, 100.00);
```

Task: Set isolation level and test.

Solution:
```sql
-- Check current level
SELECT @@transaction_isolation;

-- Set to READ COMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;
SELECT * FROM wu12_products WHERE product_id = 1;
-- Other transactions' uncommitted changes won't be visible
COMMIT;
```

---

## 7) Deadlock Scenario — 8 min
```sql
DROP TABLE IF EXISTS wu12_resources;
CREATE TABLE wu12_resources (resource_id INT PRIMARY KEY, status VARCHAR(20));
INSERT INTO wu12_resources VALUES (1, 'available'), (2, 'available');
```

Task: Understand potential deadlock (need 2 sessions to actually create one).

Solution:
```sql
-- Session 1:
START TRANSACTION;
UPDATE wu12_resources SET status = 'locked' WHERE resource_id = 1;
-- Wait...
UPDATE wu12_resources SET status = 'locked' WHERE resource_id = 2;
COMMIT;

-- Session 2 (simultaneously):
START TRANSACTION;
UPDATE wu12_resources SET status = 'locked' WHERE resource_id = 2;
-- Wait...
UPDATE wu12_resources SET status = 'locked' WHERE resource_id = 1;  -- DEADLOCK!
COMMIT;

-- MySQL detects deadlock and rolls back one transaction
```

---

## 8) Transaction with SELECT FOR UPDATE — 7 min
```sql
DROP TABLE IF EXISTS wu12_seats;
CREATE TABLE wu12_seats (seat_id INT PRIMARY KEY, reserved BOOLEAN DEFAULT FALSE);
INSERT INTO wu12_seats VALUES (1, FALSE), (2, FALSE);
```

Task: Lock row for update to prevent concurrent modification.

Solution:
```sql
START TRANSACTION;
SELECT * FROM wu12_seats WHERE seat_id = 1 AND reserved = FALSE FOR UPDATE;
-- Row is now locked

-- Update the seat
UPDATE wu12_seats SET reserved = TRUE WHERE seat_id = 1;
COMMIT;

-- Other transactions wait until this commits
```

---

**Key Takeaways:**
- START TRANSACTION groups operations
- COMMIT makes changes permanent
- ROLLBACK undoes all changes since START TRANSACTION
- SAVEPOINT allows partial rollback
- SELECT FOR UPDATE locks rows
- Isolation levels control visibility of concurrent changes
- Always handle transaction errors properly

