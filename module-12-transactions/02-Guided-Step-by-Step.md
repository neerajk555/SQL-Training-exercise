# Guided Step-by-Step — Transactions (15–20 min each)

## Activity 1: Bank Transfer with Error Handling — 18 min

### Business Context
Implement secure money transfer between accounts. Must be atomic: both debit and credit succeed or neither happens.

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
```sql
START TRANSACTION;
UPDATE gs12_accounts SET balance = balance - 200 WHERE account_id = 1;
SELECT * FROM gs12_accounts WHERE account_id = 1;
-- Balance is 800, but not committed yet
```

**Step 2:** Credit destination
```sql
UPDATE gs12_accounts SET balance = balance + 200 WHERE account_id = 2;
SELECT * FROM gs12_accounts WHERE account_id = 2;
-- Balance is 700
```

**Step 3:** Commit transaction
```sql
COMMIT;
-- Both changes are now permanent
SELECT * FROM gs12_accounts;
```

**Step 4:** Test rollback scenario
```sql
START TRANSACTION;
UPDATE gs12_accounts SET balance = balance - 300 WHERE account_id = 1;
UPDATE gs12_accounts SET balance = balance + 300 WHERE account_id = 2;
-- Oops, wrong amount!
ROLLBACK;
-- All changes undone
SELECT * FROM gs12_accounts;
```

**Step 5:** Handle insufficient funds
```sql
START TRANSACTION;
-- Try to debit more than balance
UPDATE gs12_accounts SET balance = balance - 2000 WHERE account_id = 1;
-- This violates CHECK constraint!
-- Transaction is automatically rolled back
ROLLBACK;
```

### Key Takeaways
- Transactions ensure atomicity (all or nothing)
- CHECK constraints provide data integrity
- Always handle errors and rollback on failure
- Test both success and failure scenarios

---

## Activity 2: Order Processing with Inventory — 20 min

### Business Context
When customer places order, must: create order record, deduct inventory, all in one transaction.

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
```sql
START TRANSACTION;
SELECT * FROM gs12_products WHERE product_id IN (1, 2) FOR UPDATE;
-- Locks products to prevent concurrent orders
```

**Step 3:** Create order
```sql
INSERT INTO gs12_orders (customer_id, total_amount) VALUES (101, 324.98);
SET @order_id = LAST_INSERT_ID();
```

**Step 4:** Add order details and deduct inventory
```sql
INSERT INTO gs12_order_details (order_id, product_id, quantity, unit_price)
VALUES (@order_id, 1, 1, 299.99);

UPDATE gs12_products SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;

INSERT INTO gs12_order_details (order_id, product_id, quantity, unit_price)
VALUES (@order_id, 2, 1, 24.99);

UPDATE gs12_products SET stock_quantity = stock_quantity - 1 WHERE product_id = 2;
```

**Step 5:** Commit
```sql
COMMIT;
SELECT * FROM gs12_orders;
SELECT * FROM gs12_order_details WHERE order_id = @order_id;
SELECT * FROM gs12_products WHERE product_id IN (1, 2);
```

### Common Mistakes
- Forgetting FOR UPDATE (allows concurrent stock depletion)
- Not checking stock before order
- Committing too early
- Not handling errors

---

## Activity 3: Savepoints for Complex Operations — 18 min

### Business Context
Batch import with ability to rollback individual records but keep successful ones.

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
```sql
SAVEPOINT sp_record_1;
INSERT INTO gs12_customers_import VALUES (1, 'alice@example.com', 'Alice');
INSERT INTO gs12_import_log (record_number, status, message) VALUES (1, 'success', 'Imported');
```

**Step 3:** Import second record (duplicate email - error!)
```sql
SAVEPOINT sp_record_2;
-- This fails due to duplicate email
-- INSERT INTO gs12_customers_import VALUES (2, 'alice@example.com', 'Alice Duplicate');
ROLLBACK TO sp_record_2;  -- Undo only this record
INSERT INTO gs12_import_log (record_number, status, message) VALUES (2, 'failed', 'Duplicate email');
```

**Step 4:** Import third record successfully
```sql
SAVEPOINT sp_record_3;
INSERT INTO gs12_customers_import VALUES (3, 'bob@example.com', 'Bob');
INSERT INTO gs12_import_log (record_number, status, message) VALUES (3, 'success', 'Imported');
```

**Step 5:** Commit all successful imports
```sql
COMMIT;
SELECT * FROM gs12_customers_import;
SELECT * FROM gs12_import_log;
-- Records 1 and 3 imported, record 2 failed but logged
```

### Key Takeaways
- Savepoints allow partial rollback
- Useful for batch operations
- Log both successes and failures
- Commit after processing all records

