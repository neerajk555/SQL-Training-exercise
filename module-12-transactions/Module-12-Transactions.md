# Module 12 · Transactions & Concurrency

Transactions group operations into atomic units. Either all succeed or all fail.

## Key Operations:
```sql
-- Basic transaction
START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;  -- or ROLLBACK to undo

-- Savepoint
START TRANSACTION;
INSERT INTO orders VALUES (1, 100);
SAVEPOINT sp1;
INSERT INTO orders VALUES (2, 200);
ROLLBACK TO sp1;  -- Undoes second INSERT only
COMMIT;

-- Isolation level
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

## ACID Properties:
- **Atomicity**: All or nothing
- **Consistency**: Valid state transitions
- **Isolation**: Concurrent transactions don't interfere
- **Durability**: Committed data persists
