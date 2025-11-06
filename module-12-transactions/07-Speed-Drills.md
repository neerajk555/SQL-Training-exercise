# Speed Drills — Transactions

## 📋 Before You Start

### Learning Objectives
By completing these speed drills, you will:
- Build muscle memory for transaction commands
- Practice quick recall of COMMIT/ROLLBACK
- Develop speed with transaction blocks
- Reinforce ACID properties and safety patterns
- Test your mastery of transactional operations

### How to Use Speed Drills
**Purpose:** Rapid practice for transaction mastery. 2-3 minutes per drill!

**Process:**
1. Write command from memory
2. Check syntax
3. Practice full transaction blocks
4. Repeat until automatic
5. Always think: "Do I need a transaction?"

**Scoring:** 9-10: Transaction expert | 7-8: Solid | 5-6: Practice | <5: Review

---

## Speed Drill Questions

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

