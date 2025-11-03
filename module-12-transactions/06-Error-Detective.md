# Error Detective — Transactions

## Error 1: Forgot COMMIT
```sql
START TRANSACTION;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 1;
-- Session ends without COMMIT - changes lost!
```
**Fix:** Always COMMIT or ROLLBACK before ending session.

## Error 2: Deadlock
```sql
-- Session 1: locks A then tries to lock B
-- Session 2: locks B then tries to lock A
-- DEADLOCK!
```
**Fix:** Always lock resources in same order.

## Error 3: Lost Update
```sql
-- Both sessions read balance = 100
-- Session 1: UPDATE SET balance = 110
-- Session 2: UPDATE SET balance = 120
-- Final: 120 (session 1's update lost!)
```
**Fix:** Use SELECT FOR UPDATE to lock before update.

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

