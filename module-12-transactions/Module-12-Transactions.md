# Module 12 · Transactions & Concurrency

## 📚 What You'll Learn

Transactions are the foundation of reliable database systems. They ensure that multiple operations either all succeed together or all fail together - no partial results! This module teaches you how to protect data integrity, handle concurrent users, and build bulletproof database operations.

---

## 🎯 Learning Objectives

By the end of this module, you will:
- ✅ Understand what transactions are and why they're critical
- ✅ Use START TRANSACTION, COMMIT, and ROLLBACK correctly
- ✅ Master the ACID properties of transactions
- ✅ Handle concurrent access with proper locking
- ✅ Implement safe money transfers and order processing
- ✅ Debug common transaction errors (deadlocks, lost updates)

---

## 🔑 Key Concepts

### What Are Transactions?

**Simple Explanation:**
A transaction is a group of SQL statements that must all succeed together or all fail together. No half-done operations!

**Real-World Analogy:**
Think of transferring money between bank accounts:
1. Deduct $100 from Account A
2. Add $100 to Account B

If step 1 succeeds but step 2 fails, you'd lose $100! Transactions prevent this.

**Without Transactions (DANGEROUS!):**
```sql
-- ❌ BAD: Two separate operations
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;  -- Succeeds
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;  -- Fails!
-- Result: $100 disappeared! 😱
```

**With Transactions (SAFE!):**
```sql
-- ✅ GOOD: One atomic operation
START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;  -- Both succeed together, or both fail together!
```

---

### Basic Transaction Syntax

```sql
-- Start a transaction
START TRANSACTION;  -- or use: BEGIN;

-- Execute your SQL statements
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;

-- Save changes permanently (success)
COMMIT;

-- OR undo all changes (failure)
-- ROLLBACK;
```

**Key Commands:**

| Command | Purpose |
|---------|---------|
| `START TRANSACTION;` | Begin a transaction |
| `COMMIT;` | Save all changes permanently |
| `ROLLBACK;` | Undo all changes |
| `SAVEPOINT name;` | Create a checkpoint |
| `ROLLBACK TO SAVEPOINT name;` | Undo to checkpoint |

---

### ACID Properties

Every transaction must follow the **ACID** principles:

#### 🅰️ **Atomicity** - All or Nothing
```sql
START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;  -- Debit
UPDATE accounts SET balance = balance + 100 WHERE id = 2;  -- Credit
COMMIT;  -- Both happen, or neither happens!
```

#### 🅲 **Consistency** - Valid States Only
```sql
CREATE TABLE accounts (
  account_id INT PRIMARY KEY,
  balance DECIMAL(10,2) CHECK (balance >= 0)
);
-- Transaction fails if balance would go negative!
```

#### 🅸 **Isolation** - No Interference
```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- Each transaction sees consistent data
```

#### 🅳 **Durability** - Permanent Changes
```sql
COMMIT;  -- Changes survive system crashes!
```

---

### Savepoints

```sql
START TRANSACTION;
INSERT INTO orders VALUES (1, 100);
SAVEPOINT order1_complete;

INSERT INTO orders VALUES (2, 200);
ROLLBACK TO SAVEPOINT order1_complete;  -- Undoes order 2 only

COMMIT;  -- Saves order 1
```

---

### Locking for Concurrent Access

```sql
START TRANSACTION;

-- Lock row for update (others must wait)
SELECT * FROM products 
WHERE product_id = 1 
FOR UPDATE;

-- Now safe to update
UPDATE products SET stock = stock - 1 WHERE product_id = 1;

COMMIT;  -- Lock released
```

---

## 📋 Best Practices

1. **Keep Transactions Short** - Long transactions block others
2. **Always Handle Errors** - Use ROLLBACK on failures
3. **Lock in Consistent Order** - Prevents deadlocks
4. **Use Appropriate Isolation Level** - READ COMMITTED for most cases
5. **Test Concurrent Scenarios** - Simulate real conflicts

---

## 🚀 Quick Reference

```sql
-- Start/End
START TRANSACTION;
COMMIT;
ROLLBACK;

-- Savepoints
SAVEPOINT checkpoint1;
ROLLBACK TO SAVEPOINT checkpoint1;

-- Locking
SELECT * FROM table WHERE id = 1 FOR UPDATE;

-- Isolation
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

---

## 💡 Beginner Tips

1. Always COMMIT or ROLLBACK - don't leave transactions hanging
2. Use transactions for ANY multi-step operation
3. Test the failure path - what if step 3 fails?
4. FOR UPDATE prevents race conditions
5. Watch for deadlocks when locking multiple rows
