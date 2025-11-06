# Error Detective — Transactions

## Error 1: Forgot COMMIT ❌

**Beginner Explanation:** Starting a transaction without committing is like writing a document but never clicking "Save"!

```sql
START TRANSACTION;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 1;
-- Oops! Session closes or crashes...
-- Changes are LOST! 😱
```

**Why This is Wrong:**
- Changes are only temporary until COMMIT
- If session disconnects, MySQL automatically rolls back
- The update never actually happened!

**Fix:** ✅
```sql
START TRANSACTION;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 1;
COMMIT;  -- Make it permanent!
```

**Real-World Impact:** Customer deposits $100, sees confirmation, but money never arrives in account!

## Error 2: Deadlock
```sql
-- Session 1: locks A then tries to lock B
-- Session 2: locks B then tries to lock A
-- DEADLOCK!
```
**Fix:** Always lock resources in same order.

## Error 3: Lost Update (Race Condition) ❌

**Beginner Explanation:** Two people editing the same document simultaneously - one person's changes get overwritten!

```sql
-- Session 1:
START TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 1;  -- Returns 100
UPDATE accounts SET balance = 110 WHERE account_id = 1;
COMMIT;

-- Session 2 (simultaneous):
START TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 1;  -- Also returns 100
UPDATE accounts SET balance = 120 WHERE account_id = 1;
COMMIT;

-- Final balance: 120 (Session 1's +10 was lost!)
```

**Why This is Wrong:**
- Both sessions read the same initial value
- Both calculate new values independently
- Last write wins, overwriting previous changes
- Lost +10 from Session 1!

**Fix:** ✅
```sql
-- Session 1:
START TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 1 FOR UPDATE;  -- LOCK IT!
-- Session 2 must wait here
UPDATE accounts SET balance = balance + 10 WHERE account_id = 1;
COMMIT;

-- Session 2 (waits for Session 1):
START TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 1 FOR UPDATE;  -- Returns 110 now!
UPDATE accounts SET balance = balance + 20 WHERE account_id = 1;
COMMIT;

-- Final balance: 130 (correct! 100 + 10 + 20)
```

**Real-World Impact:** Bank ATM withdrawals could result in incorrect balances!

## Error 4: Dirty Read
```sql
-- Session 1: UPDATE price = 50 (uncommitted)
-- Session 2: SELECT price -- sees 50
-- Session 1: ROLLBACK -- price back to 100
-- Session 2 used wrong value!
```
**Fix:** Use READ COMMITTED isolation level.

## Error 5: Wrong Isolation Level
```sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- Allows dirty reads!
```
**Fix:** Use READ COMMITTED or higher for production.

