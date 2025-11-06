# Quick Warm-Ups — Transactions

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

## 1) Basic Transaction
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

## 2) ROLLBACK on Error

**What You'll Learn:** How to undo changes when something goes wrong.

**Beginner Explanation:**
ROLLBACK is like an "Undo" button that cancels all changes since START TRANSACTION. Use it when you make a mistake or an error occurs.

```sql
DROP TABLE IF EXISTS wu12_inventory;
CREATE TABLE wu12_inventory (
  product_id INT PRIMARY KEY,
  stock INT CHECK (stock >= 0)  -- Ensures stock never goes negative
);
INSERT INTO wu12_inventory VALUES (1, 10);
```

**Task:** Make a change, realize it's wrong, and rollback.

**Solution:**
```sql
START TRANSACTION;

-- Make a change
UPDATE wu12_inventory SET stock = 8 WHERE product_id = 1;

-- Check what happened
SELECT * FROM wu12_inventory;  -- Shows stock = 8 (temporarily)

-- Oops, this was a mistake! Undo it
ROLLBACK;

-- Verify the rollback worked
SELECT * FROM wu12_inventory;
-- Stock is still 10 (change was cancelled!)
```

**Key Concept:** Changes inside a transaction are temporary until COMMIT. ROLLBACK cancels them all!

---

## 3) Multiple Operations

**What You'll Learn:** How to group multiple related changes together.

**Beginner Explanation:**
When you need to update multiple tables for one business operation (like creating an order with items), use a transaction to ensure ALL changes succeed or ALL fail together.

**Real-World Example:** When you order pizza online, the system must:
1. Create the order record
2. Add each item you ordered

If step 2 fails, step 1 should be cancelled too (otherwise you'd have an empty order!).

```sql
DROP TABLE IF EXISTS wu12_orders, wu12_order_items;
CREATE TABLE wu12_orders (order_id INT PRIMARY KEY, total DECIMAL(10,2));
CREATE TABLE wu12_order_items (item_id INT PRIMARY KEY, order_id INT, price DECIMAL(10,2));
```

**Task:** Insert an order and 2 items in a single transaction.

**Solution:**
```sql
START TRANSACTION;

-- Step 1: Create the order
INSERT INTO wu12_orders VALUES (1, 150.00);

-- Step 2: Add items to the order
INSERT INTO wu12_order_items VALUES (1, 1, 75.00);
INSERT INTO wu12_order_items VALUES (2, 1, 75.00);

-- Everything worked! Save all changes
COMMIT;

-- All 3 inserts succeed or all fail together
SELECT * FROM wu12_orders;
SELECT * FROM wu12_order_items;
```

**Why This Matters:** Without a transaction, if the second item insert failed, you'd have an incomplete order! 🛒

---

## 4) Savepoint

**What You'll Learn:** How to create "checkpoints" within a transaction.

**Beginner Explanation:**
Savepoints are like save points in a video game. You can rollback to a specific checkpoint without losing ALL your progress. This lets you undo part of a transaction while keeping earlier changes.

**Real-World Example:** When filling out a long form, you might want to undo just the last section without clearing the entire form.

```sql
DROP TABLE IF EXISTS wu12_logs;
CREATE TABLE wu12_logs (log_id INT PRIMARY KEY, message VARCHAR(100));
```

**Task:** Use savepoint to rollback part of a transaction while keeping earlier changes.

**Solution:**
```sql
START TRANSACTION;

-- Make first change
INSERT INTO wu12_logs VALUES (1, 'First log');

-- Create a checkpoint here
SAVEPOINT sp1;

-- Make second change
INSERT INTO wu12_logs VALUES (2, 'Second log');

-- Check current state
SELECT * FROM wu12_logs;  -- Shows both logs

-- Oops, second log was wrong. Go back to checkpoint
ROLLBACK TO sp1;

-- Save the good changes
COMMIT;

-- Final result
SELECT * FROM wu12_logs;
-- Only first log remains (second was undone!)
```

**Key Concept:** You can undo mistakes without losing all your work! 🎯

---

## 5) Autocommit Mode
```sql
-- Check autocommit status
SELECT @@autocommit;  -- 1 = ON (default)

-- Turn off autocommit
SET autocommit = 0;

DROP TABLE IF EXISTS wu12_test;
CREATE TABLE wu12_test (id INT PRIMARY KEY);
INSERT INTO wu12_test VALUES (1);

-- Check the data
SELECT * FROM wu12_test;  -- Shows the row

-- Not committed yet! Let's undo it
ROLLBACK;

-- Check again
SELECT * FROM wu12_test;  -- Empty! (Change was rolled back)

-- Turn autocommit back on
SET autocommit = 1;
```

**When to Use:** Turn autocommit OFF when you want fine control over multiple related changes. ⚙️

---

## 6) Isolation Level

**What You'll Learn:** How to control what changes your transaction can see from others.

**Beginner Explanation:**
Isolation levels control whether your transaction can see uncommitted changes from other transactions. It's like choosing whether to see "draft" versions of documents or only "published" versions.

**Common Isolation Levels:**
- **READ UNCOMMITTED:** Can see other transactions' uncommitted changes (risky!)
- **READ COMMITTED:** Only see committed changes (safer, default in many databases)
- **REPEATABLE READ:** Same data throughout your transaction (MySQL default)
- **SERIALIZABLE:** Strongest isolation (slowest)

```sql
DROP TABLE IF EXISTS wu12_products;
CREATE TABLE wu12_products (product_id INT PRIMARY KEY, price DECIMAL(10,2));
INSERT INTO wu12_products VALUES (1, 100.00);
```

**Task:** Check and change the isolation level for your session.

**Solution:**
```sql
-- Check current isolation level
SELECT @@transaction_isolation;
-- Shows 'REPEATABLE-READ' (MySQL default)

-- Set to READ COMMITTED for this session
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Verify the change
SELECT @@transaction_isolation;
-- Now shows 'READ-COMMITTED'

-- Use the new isolation level
START TRANSACTION;
SELECT * FROM wu12_products WHERE product_id = 1;
-- With READ COMMITTED, you'll see changes after others COMMIT
-- Other transactions' uncommitted changes won't be visible
COMMIT;
```

**Real-World Tip:** Higher isolation = more consistency but slower performance. Choose based on your needs! 🎚️

---

## 7) Deadlock Scenario

**What You'll Learn:** What deadlocks are and how they occur.

**Beginner Explanation:**
A deadlock happens when two transactions are waiting for each other to release locks - like two people in a narrow hallway, each waiting for the other to move first. Nobody can proceed!

**Real-World Example:**
- Transaction A locks Resource 1, needs Resource 2
- Transaction B locks Resource 2, needs Resource 1
- Both are stuck waiting! MySQL will detect this and kill one transaction.

```sql
DROP TABLE IF EXISTS wu12_resources;
CREATE TABLE wu12_resources (resource_id INT PRIMARY KEY, status VARCHAR(20));
INSERT INTO wu12_resources VALUES (1, 'available'), (2, 'available');
```

**Task:** Understand how deadlocks occur (requires 2 database sessions to actually create one).

**Solution Demonstration:**

**Session 1 (run this first):**
```sql
START TRANSACTION;

-- Lock resource 1 first
UPDATE wu12_resources SET status = 'locked' WHERE resource_id = 1;

-- Wait 5 seconds here (to let Session 2 lock resource 2)

-- Now try to lock resource 2
UPDATE wu12_resources SET status = 'locked' WHERE resource_id = 2;

COMMIT;
```

**Session 2 (run immediately after Session 1 starts):**
```sql
START TRANSACTION;

-- Lock resource 2 first
UPDATE wu12_resources SET status = 'locked' WHERE resource_id = 2;

-- Now try to lock resource 1 (but Session 1 already has it!)
UPDATE wu12_resources SET status = 'locked' WHERE resource_id = 1;
-- DEADLOCK! MySQL will kill one transaction

COMMIT;
```

**What Happens:** MySQL detects the circular wait and automatically rolls back one transaction with error: `Deadlock found when trying to get lock; try restarting transaction`

**Prevention Strategy:** Always access resources in the same order (e.g., always lock lower ID first)! 🔄

---

## 8) SELECT FOR UPDATE

**What You'll Learn:** How to lock rows to prevent race conditions.

**Beginner Explanation:**
`SELECT FOR UPDATE` locks the rows you select, preventing other transactions from modifying them until you commit. This prevents the "double booking" problem!

**Real-World Example:** When booking a concert seat:
1. Check if seat is available
2. Reserve it
Without locking, two people could both see the seat available and both try to book it!

```sql
DROP TABLE IF EXISTS wu12_seats;
CREATE TABLE wu12_seats (seat_id INT PRIMARY KEY, reserved BOOLEAN DEFAULT FALSE);
INSERT INTO wu12_seats VALUES (1, FALSE), (2, FALSE);
```

**Task:** Lock a row before updating it to prevent concurrent modifications.

**Solution:**
```sql
START TRANSACTION;

-- Check if seat is available AND lock it
SELECT * FROM wu12_seats WHERE seat_id = 1 AND reserved = FALSE FOR UPDATE;
-- This row is now LOCKED - other transactions must wait!

-- Simulate checking something (e.g., payment processing)
-- SELECT SLEEP(5);  -- Uncomment to test

-- Reserve the seat (we know it's still available because we locked it)
UPDATE wu12_seats SET reserved = TRUE WHERE seat_id = 1;

-- Release the lock
COMMIT;

-- Verify
SELECT * FROM wu12_seats;
-- Seat 1 is now reserved
```

**What Happens to Other Transactions:** If another transaction tries `SELECT ... FOR UPDATE` on the same row, it will wait until this transaction commits or rolls back.

**Why This Matters:** Prevents race conditions where two users could reserve the same seat! 🎫

---

**Key Takeaways:**
- START TRANSACTION groups operations
- COMMIT makes changes permanent
- ROLLBACK undoes all changes since START TRANSACTION
- SAVEPOINT allows partial rollback
- SELECT FOR UPDATE locks rows
- Isolation levels control visibility of concurrent changes
- Always handle transaction errors properly

