# Speed Drills — Transactions (2 min each)

## Drill 1: Start Transaction
`START TRANSACTION;`

## Drill 2: Commit Changes
`COMMIT;`

## Drill 3: Rollback
`ROLLBACK;`

## Drill 4: Savepoint
`SAVEPOINT sp1; ... ROLLBACK TO sp1;`

## Drill 5: Lock Row
`SELECT * FROM table WHERE id = 1 FOR UPDATE;`

## Drill 6: Check Autocommit
`SELECT @@autocommit;`

## Drill 7: Set Isolation Level
`SET TRANSACTION ISOLATION LEVEL READ COMMITTED;`

## Drill 8: Simple Transfer
```sql
START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
```

## Drill 9: Check Transaction Status
`SELECT * FROM information_schema.innodb_trx;`

## Drill 10: Rollback on Error
```sql
START TRANSACTION;
-- ... operations ...
-- IF error THEN
ROLLBACK;
-- ELSE
COMMIT;
-- END IF;
```

