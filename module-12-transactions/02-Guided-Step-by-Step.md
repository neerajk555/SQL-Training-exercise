# Guided Step-by-Step — Transactions

## Activity 1: Bank Transfer with Error Handling

### Business Context
Implement secure money transfer between accounts. Must be atomic: both debit and credit succeed or neither happens.

**Beginner Explanation:** When transferring money, you CANNOT have a situation where money leaves one account but never arrives in the other! Transactions ensure both operations happen together or neither happens.

### Setup
```sql
DROP TABLE IF EXISTS gs12_accounts;
CREATE TABLE gs12_accounts (
  account_id INT PRIMARY KEY,
  account_holder VARCHAR(100),
  balance DECIMAL(10,2) CHECK (balance >= 0)
);
INSERT INTO gs12_accounts VALUES
(1, 'Alice', 1000.00),
(2, 'Bob', 500.00),
(3, 'Carol', 250.00);
```

### Steps

**Step 1:** Start transaction and debit source
**What's Happening:** We're removing $200 from Alice's account, but it's not final yet!

```sql
START TRANSACTION;

-- Remove money from Alice's account
UPDATE gs12_accounts SET balance = balance - 200 WHERE account_id = 1;

-- Check the temporary state
SELECT * FROM gs12_accounts WHERE account_id = 1;
-- Balance is 800, but not committed yet (other users still see 1000!)
```

**Step 2:** Credit destination
**What's Happening:** Now add $200 to Bob's account (still temporary!)

```sql
-- Add money to Bob's account
UPDATE gs12_accounts SET balance = balance + 200 WHERE account_id = 2;

-- Check the temporary state
SELECT * FROM gs12_accounts WHERE account_id = 2;
-- Balance is 700 (was 500, now 700)
```

**Step 3:** Commit transaction
**What's Happening:** Make both changes permanent! This is the moment of truth.

```sql
COMMIT;
-- Both changes are now permanent and visible to everyone!

-- Verify the final result
SELECT * FROM gs12_accounts;
-- Alice: 800 (was 1000)
-- Bob: 700 (was 500)
-- Total money in system still the same: 1550
```

**Why This is Safe:** If ANY error happened between START TRANSACTION and COMMIT, we could ROLLBACK and nothing would change! ✅

**Step 4:** Test rollback scenario
**What's Happening:** Practice the "undo" button!

```sql
START TRANSACTION;

-- Transfer $300 (but we'll undo this)
UPDATE gs12_accounts SET balance = balance - 300 WHERE account_id = 1;
UPDATE gs12_accounts SET balance = balance + 300 WHERE account_id = 2;

-- Check temporary state
SELECT * FROM gs12_accounts WHERE account_id IN (1, 2);
-- Alice: 500, Bob: 1000

-- Oops, wrong amount! Cancel everything
ROLLBACK;

-- Verify nothing changed
SELECT * FROM gs12_accounts;
-- Alice: 800 (back to before!), Bob: 700
```

**Step 5:** Handle insufficient funds
**What's Happening:** See how constraints protect us from bad data!

```sql
START TRANSACTION;

-- Try to debit more than Alice's balance
UPDATE gs12_accounts SET balance = balance - 2000 WHERE account_id = 1;
-- ERROR: Check constraint violation (balance would be negative!)

-- The transaction is automatically rolled back by MySQL
-- But it's good practice to explicitly ROLLBACK
ROLLBACK;

-- Verify Alice's balance is unchanged
SELECT * FROM gs12_accounts WHERE account_id = 1;
-- Still 800 (protected by CHECK constraint!)
```

### Key Takeaways
- ✅ Transactions ensure **atomicity** (all or nothing) - perfect for money transfers!
- ✅ CHECK constraints provide **data integrity** - no negative balances allowed!
- ✅ Always handle errors and **ROLLBACK** on failure
- ✅ Test both success and failure scenarios
- ✅ Other users don't see changes until COMMIT (isolation!)

**Real-World Impact:** This pattern prevents the nightmare scenario where money disappears from one account but never arrives in the other! 💰

---

## Activity 2: Order Processing with Inventory

### Business Context
When customer places order, must: create order record, deduct inventory, all in one transaction.

**Beginner Explanation:** Imagine an online store. When someone buys a laptop, you need to:
1. Create the order record
2. Subtract the laptop from inventory
3. Record what they bought

If ANY step fails, ALL steps should be cancelled (otherwise you'd have orders without inventory changes, or inventory changes without orders!).

### Setup
```sql
DROP TABLE IF EXISTS gs12_products, gs12_orders, gs12_order_details;

CREATE TABLE gs12_products (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(100),
  stock_quantity INT CHECK (stock_quantity >= 0)
);

CREATE TABLE gs12_orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  total_amount DECIMAL(10,2)
);

CREATE TABLE gs12_order_details (
  detail_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  unit_price DECIMAL(10,2)
);

INSERT INTO gs12_products VALUES
(1, 'Laptop', 50),
(2, 'Mouse', 200),
(3, 'Keyboard', 150);
```

### Steps

**Step 1:** Check stock availability
```sql
SELECT product_id, stock_quantity FROM gs12_products WHERE product_id IN (1, 2);
```

**Step 2:** Start transaction and lock rows
**What's Happening:** Lock the products so no one else can modify them while we process this order!

```sql
START TRANSACTION;

-- Lock the products (prevents race conditions!)
SELECT * FROM gs12_products WHERE product_id IN (1, 2) FOR UPDATE;
-- These products are now locked until we COMMIT or ROLLBACK
-- Other transactions trying to buy these will wait
```

**Why FOR UPDATE?** Without it, two customers could both see "50 laptops available" and both place orders, even if there's only 50 total!

**Step 3:** Create order
**What's Happening:** Insert the main order record and capture its ID.

```sql
-- Create the order
INSERT INTO gs12_orders (customer_id, total_amount) VALUES (101, 324.98);

-- Get the order ID that was just created
SET @order_id = LAST_INSERT_ID();

-- Check what order_id was assigned
SELECT @order_id;
```

**Step 4:** Add order details and deduct inventory
**What's Happening:** Record what was ordered AND update inventory counts.

```sql
-- Add first item to order (Laptop)
INSERT INTO gs12_order_details (order_id, product_id, quantity, unit_price)
VALUES (@order_id, 1, 1, 299.99);

-- Subtract 1 laptop from inventory
UPDATE gs12_products SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;

-- Add second item to order (Mouse)
INSERT INTO gs12_order_details (order_id, product_id, quantity, unit_price)
VALUES (@order_id, 2, 1, 24.99);

-- Subtract 1 mouse from inventory
UPDATE gs12_products SET stock_quantity = stock_quantity - 1 WHERE product_id = 2;

-- All 6 operations are part of one transaction!
```

**Step 5:** Commit and verify
**What's Happening:** Make everything permanent and check the results!

```sql
COMMIT;
-- All 6 operations are now permanent!
-- Products are unlocked

-- Verify the order was created
SELECT * FROM gs12_orders;

-- Check what was ordered
SELECT * FROM gs12_order_details WHERE order_id = @order_id;

-- Verify inventory was updated
SELECT * FROM gs12_products WHERE product_id IN (1, 2);
-- Laptop: 49 (was 50), Mouse: 199 (was 200)
```

### Common Mistakes
- ❌ Forgetting `FOR UPDATE` → Race condition! Two customers could oversell inventory
- ❌ Not checking stock before order → Could sell items you don't have
- ❌ Committing too early → Partial order processing (some items but not others)
- ❌ Not handling errors → Failed inventory update but order still created

**Real-World Disaster Without Transactions:** Customer orders 3 laptops. Order record created successfully. Inventory update fails (network issue). Now you have an order for 3 laptops but inventory still shows 50. You've oversold! 😱

**With Transactions:** If inventory update fails, the entire order is rolled back. Customer sees "order failed" and inventory is accurate. ✅

---

## Activity 3: Savepoints for Complex Operations

### Business Context
Batch import with ability to rollback individual records but keep successful ones.

**Beginner Explanation:** When importing 1000 customer records, you don't want 1 bad record to cancel all 999 good ones! Savepoints let you rollback just the bad record while keeping the good ones.

**Analogy:** Like "undo" in a word processor - you can undo the last sentence without deleting the entire document.

### Setup
```sql
DROP TABLE IF EXISTS gs12_import_log, gs12_customers_import;

CREATE TABLE gs12_customers_import (
  customer_id INT PRIMARY KEY,
  email VARCHAR(100) UNIQUE,
  name VARCHAR(100)
);

CREATE TABLE gs12_import_log (
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  record_number INT,
  status VARCHAR(20),
  message VARCHAR(255)
);
```

### Steps

**Step 1:** Start import transaction
```sql
START TRANSACTION;
```

**Step 2:** Import first record with savepoint
**What's Happening:** Create a checkpoint before each record.

```sql
-- Checkpoint before record 1
SAVEPOINT sp_record_1;

-- Import first customer
INSERT INTO gs12_customers_import VALUES (1, 'alice@example.com', 'Alice');
INSERT INTO gs12_import_log (record_number, status, message) VALUES (1, 'success', 'Imported');

-- Record 1 imported successfully!
```

**Step 3:** Import second record (duplicate email - error!)
**What's Happening:** Handle errors gracefully without losing previous work.

```sql
-- Checkpoint before record 2
SAVEPOINT sp_record_2;

-- Try to import duplicate email (this would fail!)
-- INSERT INTO gs12_customers_import VALUES (2, 'alice@example.com', 'Alice Duplicate');
-- ERROR: Duplicate entry 'alice@example.com' for key 'email'

-- Undo ONLY record 2 (record 1 is still safe!)
ROLLBACK TO sp_record_2;

-- Log the failure instead
INSERT INTO gs12_import_log (record_number, status, message) 
VALUES (2, 'failed', 'Duplicate email');
```

**Why This is Powerful:** Record 1 is still in the transaction! We only rolled back record 2.

**Step 4:** Import third record successfully
**What's Happening:** Continue processing after handling the error.

```sql
-- Checkpoint before record 3
SAVEPOINT sp_record_3;

-- Import third customer (different email)
INSERT INTO gs12_customers_import VALUES (3, 'bob@example.com', 'Bob');
INSERT INTO gs12_import_log (record_number, status, message) VALUES (3, 'success', 'Imported');

-- Record 3 imported successfully!
```

**Step 5:** Commit all successful imports
**What's Happening:** Save all the good records!

```sql
-- Make everything permanent
COMMIT;

-- Check imported customers
SELECT * FROM gs12_customers_import;
-- Shows records 1 and 3 (Alice and Bob)
-- Record 2 was rolled back, so it's not here

-- Check import log
SELECT * FROM gs12_import_log;
-- Shows all 3 records:
-- Record 1: success
-- Record 2: failed (logged but not imported)
-- Record 3: success
```

**The Result:** 2 customers imported, 1 failed but logged. Perfect for real-world imports!

### Key Takeaways
- ✅ **Savepoints** allow partial rollback within a transaction
- ✅ Perfect for **batch operations** (importing many records)
- ✅ Always **log both successes and failures** for auditing
- ✅ **COMMIT after processing all records** to save the good ones
- ✅ Without savepoints, 1 bad record would cancel ALL imports!

**Real-World Use Case:** Importing 10,000 customer records from a CSV file. With savepoints, you can import 9,950 good records and skip 50 bad ones, rather than failing the entire batch! 📊

