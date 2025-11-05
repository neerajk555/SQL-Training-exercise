# Quick Warm-Ups — DML Operations

## 📋 Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Insert data with INSERT INTO statements
- Update existing records with UPDATE and WHERE
- Delete records safely with DELETE
- Use INSERT...ON DUPLICATE KEY UPDATE for upserts
- Understand transaction safety for data modifications

### Key DML Concepts for Beginners
**DML = Data Manipulation Language:**
- `INSERT`: Add new rows to a table
- `UPDATE`: Modify existing rows
- `DELETE`: Remove rows from a table
- These operations CHANGE data (unlike SELECT which only reads)

**Critical Safety Rules:**
- ⚠️ **ALWAYS use WHERE with UPDATE/DELETE** (or you'll affect ALL rows!)
- ⚠️ **Test with SELECT first** to verify which rows will be affected
- ⚠️ **Use transactions** for important changes (START TRANSACTION, COMMIT, ROLLBACK)
- ⚠️ **Backup data** before bulk modifications

**INSERT Patterns:**
- Single row: `INSERT INTO table (col1, col2) VALUES (val1, val2)`
- Multiple rows: `INSERT INTO table (col1, col2) VALUES (v1, v2), (v3, v4)`
- From query: `INSERT INTO table SELECT ... FROM other_table`
- Upsert: `INSERT ... ON DUPLICATE KEY UPDATE ...`

**UPDATE Pattern:**
- `UPDATE table SET column = new_value WHERE condition`
- Without WHERE = updates ALL rows (dangerous!)
- Can update multiple columns: `SET col1 = val1, col2 = val2`

**DELETE Pattern:**
- `DELETE FROM table WHERE condition`
- Without WHERE = deletes ALL rows (very dangerous!)
- Consider soft deletes (UPDATE is_deleted = 1) for important data

### Execution Tips
1. **Always test with SELECT first**: `SELECT * FROM table WHERE condition` 
2. **Use transactions for safety**: Wrap changes in START TRANSACTION / COMMIT
3. **Verify affected rows**: Check the "rows affected" message
4. **Have backups**: Before bulk modifications, backup your data

**Beginner Tip:** DML operations change your data permanently! Always double-check your WHERE clauses. When in doubt, use transactions so you can ROLLBACK if something goes wrong.

---

## Exercise 1: Insert New Product — 6 min ⏱️

**Scenario:** You're setting up a new e-commerce database. The first step is adding products to your inventory.

**Real-World Analogy:** Think of INSERT like adding items to an online shopping catalog - you're creating new entries that didn't exist before.

**Your Task:** Insert 3 products into the `wu9_products` table using a **single INSERT statement** with multiple value sets.

### Setup Code (Run This First)
```sql
DROP TABLE IF EXISTS wu9_products;
CREATE TABLE wu9_products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(60),
    price DECIMAL(8,2)
);
```

### Your Challenge
Insert these 3 products in **ONE statement**:
- Laptop for $1200
- Mouse for $25
- Keyboard for $75

<details>
<summary>💡 Hint #1: Multiple Values Syntax</summary>

To insert multiple rows in one statement:
```sql
INSERT INTO table (col1, col2) 
VALUES (val1, val2), (val3, val4), (val5, val6);
```
Use commas to separate each value set!
</details>

<details>
<summary>💡 Hint #2: Column Order</summary>

You don't need to specify `product_id` - it's AUTO_INCREMENT so MySQL will generate it automatically! Just provide `name` and `price`.
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Insert 3 products in one statement
INSERT INTO wu9_products (name, price) 
VALUES 
    ('Laptop', 1200),
    ('Mouse', 25),
    ('Keyboard', 75);

-- Verify the insert worked
SELECT * FROM wu9_products;
```

**Expected Output:**
```
+------------+----------+---------+
| product_id | name     | price   |
+------------+----------+---------+
|          1 | Laptop   | 1200.00 |
|          2 | Mouse    |   25.00 |
|          3 | Keyboard |   75.00 |
+------------+----------+---------+
3 rows in set
```

**What Happened:**
- MySQL automatically assigned `product_id` values (1, 2, 3) due to AUTO_INCREMENT
- All 3 rows were inserted in a single atomic operation
- The `price` values were stored with 2 decimal places (DECIMAL(8,2))

**Beginner Tip:** Inserting multiple rows at once is more efficient than running separate INSERT statements. It's one database transaction instead of three!
</details>

**Why This Matters:** Bulk inserts are common when importing product catalogs, loading sample data, or migrating from other systems. One statement = faster + safer!

---

## Exercise 2: Update Prices — 7 min ⏱️

**Scenario:** Your company is increasing all product prices by 10% due to inflation. You need to update every product in the database.

**Real-World Analogy:** This is like when a store puts up new price tags on ALL items - you're changing existing information, not adding or removing products.

**Your Task:** Increase all product prices by 10% using an UPDATE statement.

### Setup Code (If Starting Fresh)
```sql
-- Only run this if you didn't do Exercise 1
DROP TABLE IF EXISTS wu9_products;
CREATE TABLE wu9_products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(60),
    price DECIMAL(8,2)
);
INSERT INTO wu9_products (name, price) 
VALUES ('Laptop', 1200), ('Mouse', 25), ('Keyboard', 75);
```

### Your Challenge
Write an UPDATE statement that multiplies every price by 1.10 (which adds 10%).

<details>
<summary>💡 Hint #1: Math in SQL</summary>

You can use the current column value in calculations:
```sql
UPDATE table SET column = column * 1.10;  -- Increases by 10%
UPDATE table SET column = column + 5;     -- Adds 5
```
</details>

<details>
<summary>💡 Hint #2: No WHERE Clause?</summary>

In this case, we WANT to update all rows! Normally you'd use WHERE to target specific rows, but here we intentionally update everything. This is one of the rare exceptions where omitting WHERE is correct.
</details>

<details>
<summary>⚠️ Safety Check: Test First!</summary>

**Professional Tip:** Before running any UPDATE, test with SELECT to see what will change:
```sql
-- Test: Preview the calculation
SELECT 
    product_id, 
    name, 
    price AS old_price, 
    price * 1.10 AS new_price,
    price * 1.10 - price AS increase
FROM wu9_products;

-- If it looks good, then run the UPDATE
UPDATE wu9_products SET price = price * 1.10;
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Increase all prices by 10%
UPDATE wu9_products 
SET price = price * 1.10;

-- Verify the changes
SELECT * FROM wu9_products;
```

**Expected Output (After Update):**
```
+------------+----------+---------+
| product_id | name     | price   |
+------------+----------+---------+
|          1 | Laptop   | 1320.00 |  -- Was 1200, now 1200 * 1.10
|          2 | Mouse    |   27.50 |  -- Was 25, now 25 * 1.10
|          3 | Keyboard |   82.50 |  -- Was 75, now 75 * 1.10
+------------+----------+---------+
3 rows affected
```

**What Happened:**
- Laptop: 1200 × 1.10 = 1320.00
- Mouse: 25 × 1.10 = 27.50
- Keyboard: 75 × 1.10 = 82.50
- All 3 rows were modified (check "rows affected" message)

**Beginner Tip:** The expression `price * 1.10` uses the CURRENT value from each row. MySQL reads the old value, calculates the new one, and updates it.
</details>

**Why This Matters:** Bulk price updates are common in retail systems. Instead of manually changing 1000 products one-by-one, you can update them all with a single SQL statement!

**Safety Warning:** ⚠️ In real life, be VERY careful with UPDATE statements without WHERE clauses! Always double-check you want to affect ALL rows. When in doubt, use transactions:
```sql
START TRANSACTION;
UPDATE wu9_products SET price = price * 1.10;
SELECT * FROM wu9_products;  -- Check if correct
COMMIT;  -- Save changes, OR use ROLLBACK to undo
```

---

## Exercise 3: Conditional Update — 8 min ⏱️

**Scenario:** Your company has a new policy: no product should be priced below $20 (minimum viable price). You need to raise any "cheap" items to the new minimum.

**Real-World Analogy:** This is like a store manager walking through aisles saying "Any item under $20? Change the price tag to $20." You're only updating SOME rows, not all.

**Your Task:** Find all products priced under $30 and set their price to exactly $20.

### Setup Code (If Starting Fresh)
```sql
-- Only run this if you didn't do previous exercises
DROP TABLE IF EXISTS wu9_products;
CREATE TABLE wu9_products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(60),
    price DECIMAL(8,2)
);
INSERT INTO wu9_products (name, price) 
VALUES ('Laptop', 1320), ('Mouse', 27.50), ('Keyboard', 82.50);
```

### Your Challenge
Write an UPDATE statement that changes the price to $20 for any product currently priced below $30.

<details>
<summary>💡 Hint #1: The WHERE Clause</summary>

Use WHERE to filter which rows get updated:
```sql
UPDATE table 
SET column = new_value 
WHERE condition;
```

Only rows matching the condition will be modified!
</details>

<details>
<summary>💡 Hint #2: Comparison Operator</summary>

To check "less than 30", use the `<` operator:
```sql
WHERE price < 30
```
</details>

<details>
<summary>⚠️ Safety Check: SELECT First!</summary>

**ALWAYS test with SELECT before UPDATE:**
```sql
-- Step 1: See which rows will be affected
SELECT product_id, name, price 
FROM wu9_products 
WHERE price < 30;

-- Step 2: If the right rows show up, then UPDATE
UPDATE wu9_products 
SET price = 20 
WHERE price < 30;

-- Step 3: Verify the changes
SELECT * FROM wu9_products;
```

This is the **SELECT-UPDATE-SELECT pattern** - professionals use this to avoid mistakes!
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- First, check which products will be affected
SELECT product_id, name, price 
FROM wu9_products 
WHERE price < 30;

-- Expected result: Only Mouse (27.50) should show up
-- Laptop (1320) and Keyboard (82.50) are above 30, so they're excluded

-- Now update those rows
UPDATE wu9_products 
SET price = 20 
WHERE price < 30;

-- Verify the changes
SELECT * FROM wu9_products;
```

**Expected Output (After Update):**
```
+------------+----------+---------+
| product_id | name     | price   |
+------------+----------+---------+
|          1 | Laptop   | 1320.00 |  -- Unchanged (was > 30)
|          2 | Mouse    |   20.00 |  -- CHANGED (was 27.50 < 30)
|          3 | Keyboard |   82.50 |  -- Unchanged (was > 30)
+------------+----------+---------+
1 row affected
```

**What Happened:**
- Mouse price changed: 27.50 → 20.00 (matched WHERE condition)
- Laptop stayed 1320.00 (didn't match condition)
- Keyboard stayed 82.50 (didn't match condition)
- Only 1 row was modified (check "rows affected" message)

**Beginner Tip:** The WHERE clause acts as a filter. Think of it like Excel's filter feature - you're saying "only update rows where price < 30, leave the rest alone!"
</details>

**Why This Matters:** Conditional updates are used constantly in real applications:
- E-commerce: Apply discounts to specific product categories
- HR systems: Give raises to employees with certain criteria
- Inventory: Mark items as "low stock" when quantity drops below threshold

**Common Mistake:** 
```sql
-- ❌ WRONG: Forgot WHERE clause!
UPDATE wu9_products SET price = 20;  -- Sets ALL prices to 20!

-- ✅ RIGHT: Use WHERE to target specific rows
UPDATE wu9_products SET price = 20 WHERE price < 30;
```

**Professional Tip:** MySQL has a "safe update mode" that prevents updates without WHERE clauses. If you get an error like "You are using safe update mode", it's a safety feature! To temporarily disable:
```sql
SET SQL_SAFE_UPDATES = 0;  -- Disable (for learning)
-- Run your UPDATE
SET SQL_SAFE_UPDATES = 1;  -- Re-enable (good practice!)
```

---

## Exercise 4: Delete Expired Records — 7 min ⏱️

**Scenario:** Your application stores user login sessions with expiration dates. You need to clean up old/expired sessions to keep the database tidy and secure.

**Real-World Analogy:** This is like cleaning out your fridge - you check expiration dates and throw away anything that's past its date. You're REMOVING data permanently!

**Your Task:** Delete all sessions that have expired (expiration date is in the past).

### Setup Code (Run This First)
```sql
DROP TABLE IF EXISTS wu9_sessions;
CREATE TABLE wu9_sessions (
    session_id INT,
    expires_at DATETIME
);

-- Insert test data: one expired, one future
INSERT INTO wu9_sessions VALUES 
    (1, '2025-01-01'),   -- Past date (expired)
    (2, '2025-12-31');   -- Future date (valid)
```

### Your Challenge
Write a DELETE statement that removes sessions where `expires_at` is before today's date.

<details>
<summary>💡 Hint #1: Current Date Function</summary>

MySQL has built-in functions to get the current date:
- `CURDATE()` - Returns current date (2025-11-06)
- `NOW()` - Returns current date and time (2025-11-06 14:30:00)

Compare against expiration date:
```sql
WHERE expires_at < CURDATE()
```
</details>

<details>
<summary>💡 Hint #2: DELETE Syntax</summary>

DELETE syntax is simpler than UPDATE:
```sql
DELETE FROM table WHERE condition;
```

Note: No "columns" needed - you're removing entire rows!
</details>

<details>
<summary>⚠️ CRITICAL SAFETY WARNING!</summary>

**DELETE is PERMANENT!** Once you delete data, it's gone forever (unless you have backups or transactions).

**ALWAYS follow the SELECT-DELETE-SELECT pattern:**
```sql
-- Step 1: Preview what will be deleted
SELECT * FROM wu9_sessions WHERE expires_at < CURDATE();

-- Step 2: If those are the right rows, delete them
DELETE FROM wu9_sessions WHERE expires_at < CURDATE();

-- Step 3: Verify the deletion worked
SELECT * FROM wu9_sessions;
```

**Professional Tip:** For important data, consider "soft deletes" instead:
```sql
-- Instead of DELETE, use UPDATE to mark as deleted
UPDATE wu9_sessions SET is_deleted = 1 WHERE expires_at < CURDATE();
-- Data still exists but is hidden from normal queries
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- ALWAYS test with SELECT first!
SELECT * FROM wu9_sessions WHERE expires_at < CURDATE();
-- Expected: Should show session_id 1 (2025-01-01 is past)

-- If that looks correct, then delete
DELETE FROM wu9_sessions 
WHERE expires_at < CURDATE();

-- Verify: Only the future session should remain
SELECT * FROM wu9_sessions;
```

**Expected Output (After DELETE):**
```
-- Before DELETE (SELECT shows both):
+------------+---------------------+
| session_id | expires_at          |
+------------+---------------------+
|          1 | 2025-01-01 00:00:00 |  -- Will be deleted
|          2 | 2025-12-31 00:00:00 |  -- Will remain
+------------+---------------------+

-- After DELETE (only future session remains):
+------------+---------------------+
| session_id | expires_at          |
+------------+---------------------+
|          2 | 2025-12-31 00:00:00 |
+------------+---------------------+
1 row deleted
```

**What Happened:**
- Session 1 (2025-01-01) was deleted because it's before today (2025-11-06)
- Session 2 (2025-12-31) remains because it's in the future
- 1 row was permanently removed (check "rows affected" message)

**Beginner Tip:** `CURDATE()` gets evaluated at runtime, so it always uses TODAY'S date. This query will work correctly on any date you run it!
</details>

**Why This Matters:** Expired session cleanup is a real-world maintenance task:
- Web applications: Clean up old login sessions
- E-commerce: Remove abandoned shopping carts
- Logging systems: Delete old log entries
- Data retention: Comply with privacy laws (delete data after X days)

**Common Mistakes:**
```sql
-- ❌ WRONG: Forgot WHERE clause - DELETES EVERYTHING!
DELETE FROM wu9_sessions;  -- ALL sessions gone!

-- ✅ RIGHT: Always use WHERE to target specific rows
DELETE FROM wu9_sessions WHERE expires_at < CURDATE();

-- ❌ WRONG: Hard-coded date (becomes outdated)
DELETE FROM wu9_sessions WHERE expires_at < '2025-11-06';

-- ✅ RIGHT: Use CURDATE() so it works on any date
DELETE FROM wu9_sessions WHERE expires_at < CURDATE();
```

**Transaction Safety for DELETE:**
```sql
-- Wrap in transaction so you can undo if needed
START TRANSACTION;
DELETE FROM wu9_sessions WHERE expires_at < CURDATE();
SELECT * FROM wu9_sessions;  -- Check remaining data
-- If correct: COMMIT;
-- If wrong: ROLLBACK;  (restores deleted data!)
```

**MySQL Date Comparison Cheat Sheet:**
```sql
-- Past dates
WHERE date_column < CURDATE()           -- Before today
WHERE date_column < NOW()               -- Before this moment
WHERE date_column < DATE_SUB(NOW(), INTERVAL 7 DAY)  -- Older than 7 days

-- Future dates
WHERE date_column > CURDATE()           -- After today
WHERE date_column > NOW()               -- After this moment

-- Date range
WHERE date_column BETWEEN '2025-01-01' AND '2025-12-31'
```

---

## Exercise 5: Upsert Pattern — 9 min ⏱️

**Scenario:** You're building a user login tracking system. Every time a user logs in, you need to increment their `login_count`. But if it's their first login, you need to create their record. You need ONE query that handles both cases!

**Real-World Analogy:** This is like a visitor logbook at a building entrance:
- **First visit:** Add new entry with count = 1
- **Return visit:** Find existing entry and add +1 to count
Instead of checking "Does this person exist?" first, you handle both cases in one action!

**Your Task:** Write an INSERT statement that either creates a new user record OR increments the existing login count (if the user already exists).

### Setup Code (Run This First)
```sql
DROP TABLE IF EXISTS wu9_user_stats;
CREATE TABLE wu9_user_stats (
    user_id INT PRIMARY KEY,
    login_count INT DEFAULT 0
);

-- No data yet - table is empty
```

### Your Challenge
Write an INSERT...ON DUPLICATE KEY UPDATE statement for `user_id = 1`:
- If user 1 doesn't exist: Insert with `login_count = 1`
- If user 1 exists: Increment their existing `login_count` by 1

Then run it **twice** to see both behaviors!

<details>
<summary>💡 Hint #1: Upsert Syntax</summary>

MySQL's "upsert" (INSERT or UPDATE) pattern:
```sql
INSERT INTO table (columns) VALUES (values)
ON DUPLICATE KEY UPDATE column = new_value;
```

The ON DUPLICATE KEY UPDATE clause triggers when:
- Trying to insert a PRIMARY KEY that already exists
- Or a UNIQUE key that already exists

</details>

<details>
<summary>💡 Hint #2: Incrementing Values</summary>

In the UPDATE part, you can use the column's current value:
```sql
ON DUPLICATE KEY UPDATE login_count = login_count + 1
```

This reads the existing value and adds 1 to it!
</details>

<details>
<summary>💡 Hint #3: Testing Both Behaviors</summary>

To see both INSERT and UPDATE behaviors:
```sql
-- Run #1: No user exists yet, so INSERT happens
INSERT INTO wu9_user_stats (user_id, login_count) VALUES (1, 1)
ON DUPLICATE KEY UPDATE login_count = login_count + 1;
SELECT * FROM wu9_user_stats;  -- Shows login_count = 1

-- Run #2: User exists now, so UPDATE happens
INSERT INTO wu9_user_stats (user_id, login_count) VALUES (1, 1)
ON DUPLICATE KEY UPDATE login_count = login_count + 1;
SELECT * FROM wu9_user_stats;  -- Shows login_count = 2

-- Run #3: Again!
INSERT INTO wu9_user_stats (user_id, login_count) VALUES (1, 1)
ON DUPLICATE KEY UPDATE login_count = login_count + 1;
SELECT * FROM wu9_user_stats;  -- Shows login_count = 3
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- First execution: INSERT happens (no user_id 1 exists yet)
INSERT INTO wu9_user_stats (user_id, login_count) 
VALUES (1, 1)
ON DUPLICATE KEY UPDATE login_count = login_count + 1;

SELECT * FROM wu9_user_stats;
-- Output:
-- +---------+-------------+
-- | user_id | login_count |
-- +---------+-------------+
-- |       1 |           1 |
-- +---------+-------------+
-- Message: "1 row affected" (INSERT happened)

-- Second execution: UPDATE happens (user_id 1 exists now)
INSERT INTO wu9_user_stats (user_id, login_count) 
VALUES (1, 1)
ON DUPLICATE KEY UPDATE login_count = login_count + 1;

SELECT * FROM wu9_user_stats;
-- Output:
-- +---------+-------------+
-- | user_id | login_count |
-- +---------+-------------+
-- |       1 |           2 |  -- Incremented!
-- +---------+-------------+
-- Message: "2 rows affected" (UPDATE happened - MySQL counts as 2 for upsert)

-- Third execution: UPDATE again
INSERT INTO wu9_user_stats (user_id, login_count) 
VALUES (1, 1)
ON DUPLICATE KEY UPDATE login_count = login_count + 1;

SELECT * FROM wu9_user_stats;
-- Output:
-- +---------+-------------+
-- | user_id | login_count |
-- +---------+-------------+
-- |       1 |           3 |  -- Incremented again!
-- +---------+-------------+
```

**What Happened:**
1. **First run:** Table is empty, so INSERT happens (row created with count = 1)
2. **Second run:** user_id 1 exists (PRIMARY KEY collision), so UPDATE part runs (count becomes 2)
3. **Third run:** Same - UPDATE runs again (count becomes 3)

**How It Detects Duplicates:**
- `user_id` is PRIMARY KEY
- MySQL says "I can't insert user_id=1 twice!"
- Instead of error, the ON DUPLICATE KEY UPDATE clause runs
- The UPDATE part increments the existing count

**Beginner Tip:** Notice the VALUES (1, 1) is ignored during UPDATE! The INSERT part only matters on the first run. After that, only the UPDATE part matters.
</details>

**Why This Matters:** Upserts are EXTREMELY common in real applications:
- **Analytics:** Track page views, clicks, logins (increment counts)
- **Gaming:** Update player scores, achievements
- **E-commerce:** Update product inventory without checking if exists first
- **Caching:** Insert new cache entries or update existing ones
- **Session management:** Create new session or extend existing timeout

**Alternative: REPLACE (Less Common)**
```sql
-- REPLACE = DELETE old row + INSERT new row
REPLACE INTO wu9_user_stats (user_id, login_count) VALUES (1, 5);
-- Problem: Loses old login_count! Not good for incrementing.
```

**When to Use Each Pattern:**
- **INSERT...ON DUPLICATE KEY UPDATE:** When you want to UPDATE existing data (increment, append, etc.)
- **REPLACE:** When you want to completely replace old data with new values

**Common Mistakes:**
```sql
-- ❌ WRONG: Forgot ON DUPLICATE KEY UPDATE
INSERT INTO wu9_user_stats (user_id, login_count) VALUES (1, 1);
-- Second run causes error: "Duplicate entry '1' for key 'PRIMARY'"

-- ✅ RIGHT: Include the ON DUPLICATE KEY UPDATE clause
INSERT INTO wu9_user_stats (user_id, login_count) VALUES (1, 1)
ON DUPLICATE KEY UPDATE login_count = login_count + 1;

-- ❌ WRONG: Setting to fixed value (overwrites existing count!)
ON DUPLICATE KEY UPDATE login_count = 1;  -- Always sets to 1!

-- ✅ RIGHT: Incrementing existing value
ON DUPLICATE KEY UPDATE login_count = login_count + 1;  -- Adds to current value
```

**Real-World Example: Page View Tracking**
```sql
CREATE TABLE page_views (
    page_url VARCHAR(255) PRIMARY KEY,
    view_count INT DEFAULT 0,
    last_viewed DATETIME
);

-- Every time someone visits a page:
INSERT INTO page_views (page_url, view_count, last_viewed) 
VALUES ('/products', 1, NOW())
ON DUPLICATE KEY UPDATE 
    view_count = view_count + 1,
    last_viewed = NOW();
-- First visit: Creates record with count=1
-- Subsequent visits: Increments count + updates timestamp
```

**Affected Rows Messages:**
- `1 row affected` = INSERT happened (new row created)
- `2 rows affected` = UPDATE happened (MySQL counts as 2 for upsert)
- `0 rows affected` = No change (rare, happens if UPDATE sets same value)

---

## 🎯 Wrap-Up: What You Learned

Congratulations! You've mastered the fundamentals of DML operations:

✅ **INSERT:** Adding new data (single, multiple, bulk)
✅ **UPDATE:** Modifying existing data (with WHERE clauses for safety)
✅ **DELETE:** Removing data (with SELECT-first pattern)
✅ **Upserts:** INSERT or UPDATE in one statement (ON DUPLICATE KEY UPDATE)
✅ **Safety:** Always test with SELECT, use WHERE clauses, consider transactions

**Key Takeaways:**
1. **DML = Data Manipulation** (INSERT, UPDATE, DELETE change data)
2. **WHERE clauses are critical** - without them, you affect ALL rows!
3. **Test with SELECT first** - see what will change before changing it
4. **Transactions provide safety** - ROLLBACK if something goes wrong
5. **Upserts avoid errors** - handle INSERT and UPDATE in one statement

**Next Steps:**
- Practice these patterns on different tables
- Try UPDATE/DELETE with JOINs (Module 05 knowledge)
- Experiment with transactions (START TRANSACTION, COMMIT, ROLLBACK)
- Read Module-09-DML-Operations.md for advanced patterns

**Remember:** With great power comes great responsibility! DML operations change data permanently. Always:
- 🔍 SELECT first to preview
- ✅ Use WHERE clauses (unless you REALLY want all rows)
- 💾 Backup important data
- 🔄 Use transactions for critical changes

Ready for more complex DML challenges? Move on to the **Guided Step-by-Step** exercises!
