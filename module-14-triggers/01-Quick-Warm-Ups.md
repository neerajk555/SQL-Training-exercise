# Quick Warm-Ups — Triggers

## 📋 Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Create triggers that fire on INSERT/UPDATE/DELETE operations
- Use BEFORE triggers for data validation and modification
- Use AFTER triggers for auditing and logging
- Access OLD and NEW row values in triggers
- Understand trigger timing and events
- Practice proper MySQL trigger syntax with DELIMITER

### 🎓 Key Trigger Concepts for Beginners

**What are Triggers?**
Triggers are like **automatic security guards** for your database. They watch specific tables and automatically take action when something happens (insert, update, or delete). You don't need to remember to call them—they just work!

**Real-World Analogy:**
Think of a trigger like a motion sensor light:
- **Event**: Someone walks by (= INSERT/UPDATE/DELETE)
- **Automatic Action**: Light turns on (= trigger executes)
- **No manual switch needed**: It just happens automatically!

**Trigger Components:**
- **Event**: What action activates the trigger? (INSERT, UPDATE, or DELETE)
- **Timing**: When does it run? (BEFORE or AFTER the event)
- **Table**: Which table is being watched?
- **Body**: What SQL code runs when triggered?

**OLD vs NEW - Understanding the Magic Variables:**
- `NEW.column`: The NEW value being inserted or the value AFTER an update
- `OLD.column`: The OLD value BEFORE an update or the value being deleted
- **INSERT**: Only NEW exists (there's no old data yet!)
- **DELETE**: Only OLD exists (the row is being removed)
- **UPDATE**: Both OLD and NEW exist (before and after values)

**Common Use Cases:**
- ✅ **Validation**: BEFORE triggers reject invalid data (e.g., negative prices)
- ✅ **Audit trails**: AFTER triggers log who changed what and when
- ✅ **Computed columns**: BEFORE triggers calculate values automatically (e.g., total = quantity × price)
- ✅ **Cascade actions**: AFTER triggers update related tables (e.g., deduct inventory when order placed)
- ✅ **Timestamps**: BEFORE triggers auto-set created_at and updated_at
- ✅ **Data archiving**: BEFORE DELETE triggers save data before it's removed

### 🛠️ Execution Tips

1. **Always drop before creating**: Use `DROP TRIGGER IF EXISTS trigger_name;` to avoid "trigger already exists" errors
2. **Use DELIMITER for MySQL**: Triggers contain semicolons, so change delimiter temporarily:
   ```sql
   DELIMITER //
   CREATE TRIGGER ... BEGIN ... END //
   DELIMITER ;
   ```
3. **Test with data**: After creating trigger, run INSERT/UPDATE/DELETE to see it in action
4. **Check results**: Query audit tables or use SELECT to verify trigger worked
5. **Name triggers clearly**: Use prefixes like `tr_` and descriptive names (e.g., `tr_validate_price`)

### ⚠️ Safety Warnings
- Triggers run **automatically** and can't be skipped during normal operations
- Bad trigger logic can cause **infinite loops** (trigger A calls trigger B which calls trigger A...)
- Complex triggers slow down every INSERT/UPDATE/DELETE operation
- Triggers fail **silently** sometimes—always test thoroughly!

### 💡 Beginner Pro Tips
- **BEFORE triggers** = "Check and fix data BEFORE saving"
- **AFTER triggers** = "Record what happened AFTER saving"
- **Test incrementally**: Create trigger, test with one row, then try multiple rows
- **Check SHOW TRIGGERS**: Use `SHOW TRIGGERS;` to see all your triggers
- **Read error messages carefully**: MySQL error messages tell you exactly what's wrong

---

## 1) Simple AFTER INSERT Trigger

**🎯 Goal**: Create a trigger that automatically logs a message whenever a new user is inserted.

**📖 What You'll Learn**: 
- How AFTER INSERT triggers work
- Using NEW to access inserted values
- Basic audit logging pattern

**💭 The Scenario**: 
Every time someone creates a new user account, you want to automatically record "New user: [username]" in an audit log. Instead of remembering to manually insert into the log every time, a trigger does it automatically!

```sql
-- Step 1: Create the tables
DROP TABLE IF EXISTS wu14_users, wu14_audit_log;

-- Main table: stores users
CREATE TABLE wu14_users (
  user_id INT PRIMARY KEY, 
  username VARCHAR(50)
);

-- Audit table: stores log messages
CREATE TABLE wu14_audit_log (
  log_id INT AUTO_INCREMENT PRIMARY KEY, 
  message VARCHAR(255), 
  logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Create the trigger
DELIMITER //
CREATE TRIGGER tr_user_insert 
AFTER INSERT ON wu14_users  -- Fires AFTER a row is inserted into wu14_users
FOR EACH ROW                -- Runs once for each inserted row
BEGIN
  -- NEW.username refers to the username that was just inserted
  INSERT INTO wu14_audit_log (message) 
  VALUES (CONCAT('New user: ', NEW.username));
END //
DELIMITER ;

-- Step 3: Test the trigger
INSERT INTO wu14_users VALUES (1, 'alice');

-- Step 4: Verify the trigger worked
SELECT * FROM wu14_audit_log;
-- Expected: You should see "New user: alice" with a timestamp

-- Try another one!
INSERT INTO wu14_users VALUES (2, 'bob');
SELECT * FROM wu14_audit_log;
-- Expected: Now you see TWO log entries (alice and bob)
```

**🔍 How It Works**:
1. User inserts: `INSERT INTO wu14_users VALUES (1, 'alice');`
2. The row is saved to `wu14_users` table
3. **Trigger automatically fires** AFTER the insert succeeds
4. Trigger inserts a log message into `wu14_audit_log`
5. All done—no manual logging needed!

**✅ Success Check**: Run `SELECT * FROM wu14_audit_log;` and you should see one log entry for each user you inserted.

---

## 2) BEFORE INSERT Validation

**🎯 Goal**: Create a trigger that prevents negative prices from being inserted into the products table.

**📖 What You'll Learn**: 
- How BEFORE INSERT triggers work
- Using NEW to validate data before it's saved
- Raising errors with SIGNAL to stop invalid inserts

**💭 The Scenario**: 
You're building an e-commerce system and want to ensure no product can ever have a negative price. Instead of checking this in application code, you enforce it directly in the database!

```sql
-- Step 1: Create the products table
DROP TABLE IF EXISTS wu14_products;
CREATE TABLE wu14_products (
  product_id INT PRIMARY KEY, 
  name VARCHAR(100), 
  price DECIMAL(10,2)
);

-- Step 2: Create validation trigger
DELIMITER //
CREATE TRIGGER tr_validate_price 
BEFORE INSERT ON wu14_products  -- Fires BEFORE the row is inserted
FOR EACH ROW
BEGIN
  -- Check if the price being inserted is negative
  IF NEW.price < 0 THEN
    -- SIGNAL raises an error and stops the INSERT
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Price cannot be negative';
  END IF;
END //
DELIMITER ;

-- Step 3: Test with valid data
INSERT INTO wu14_products VALUES (1, 'Laptop', 1200);  
-- ✅ Success! Price is positive, trigger allows it

SELECT * FROM wu14_products;
-- Expected: Product #1 with Laptop, price 1200.00

-- Step 4: Test with invalid data (uncomment one line at a time to test)
-- INSERT INTO wu14_products VALUES (2, 'Invalid', -10);  
-- ❌ Error! "Price cannot be negative"
-- The INSERT is completely prevented—no row is saved

-- Note: In MySQL, you'll see an error like:
-- Error Code: 1644. Price cannot be negative

-- Step 5: Try edge cases
INSERT INTO wu14_products VALUES (3, 'Free Item', 0);
-- ✅ Success! Zero is allowed (not negative)
-- Many databases allow $0 items (free samples, promotional items, etc.)

SELECT * FROM wu14_products;
-- Expected: Two products (Laptop and Free Item), no negative prices!
```

**🔍 How It Works**:
1. User tries: `INSERT INTO wu14_products VALUES (2, 'Invalid', -10);`
2. **Trigger fires BEFORE** the data is saved
3. Trigger checks: Is `NEW.price` (which is -10) less than 0? YES!
4. Trigger raises error using SIGNAL
5. INSERT is **completely cancelled**—no row is added to the table

**🎓 Understanding SIGNAL**:
- `SQLSTATE '45000'`: This is the standard MySQL error code for user-defined errors (think of it as "custom error code")
- `MESSAGE_TEXT`: Your custom error message that users will see when the error occurs
- Effect: Stops the current operation (INSERT/UPDATE/DELETE) immediately and rolls back any changes
- It's like pressing an emergency stop button - everything halts right there!

**✅ Success Check**: 
- Valid inserts (positive prices) should work
- Invalid inserts (negative prices) should produce an error
- Table should only contain products with price >= 0

---

## 3) AFTER UPDATE Trigger

**🎯 Goal**: Track all inventory changes by automatically recording the old and new stock levels whenever inventory is updated.

**📖 What You'll Learn**: 
- How AFTER UPDATE triggers work
- Using both OLD and NEW values
- Conditional logic in triggers (IF statement)
- Creating history/audit tables

**💭 The Scenario**: 
Your warehouse wants to track every time inventory levels change. When stock goes from 100 to 90 units, you want to record: "Product #1 changed from 100 to 90 on [timestamp]". This helps with auditing and troubleshooting!

```sql
-- Step 1: Create the tables
DROP TABLE IF EXISTS wu14_inventory, wu14_inventory_history;

-- Main table: current inventory levels
CREATE TABLE wu14_inventory (
  product_id INT PRIMARY KEY, 
  stock INT
);

-- History table: tracks all changes
CREATE TABLE wu14_inventory_history (
  hist_id INT AUTO_INCREMENT PRIMARY KEY, 
  product_id INT, 
  old_stock INT,           -- Stock level BEFORE the change
  new_stock INT,           -- Stock level AFTER the change
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Insert initial inventory
INSERT INTO wu14_inventory VALUES (1, 100);

-- Step 3: Create the tracking trigger
DELIMITER //
CREATE TRIGGER tr_track_stock_change 
AFTER UPDATE ON wu14_inventory  -- Fires AFTER inventory is updated
FOR EACH ROW
BEGIN
  -- Only log if stock actually changed (not other columns)
  IF OLD.stock != NEW.stock THEN
    -- OLD.stock = stock level before update
    -- NEW.stock = stock level after update
    INSERT INTO wu14_inventory_history (product_id, old_stock, new_stock)
    VALUES (NEW.product_id, OLD.stock, NEW.stock);
  END IF;
END //
DELIMITER ;

-- Step 4: Test the trigger
UPDATE wu14_inventory SET stock = 90 WHERE product_id = 1;

-- Step 5: Check the history
SELECT * FROM wu14_inventory_history;
-- Expected: hist_id=1, product_id=1, old_stock=100, new_stock=90, timestamp

-- Step 6: Make another change
UPDATE wu14_inventory SET stock = 85 WHERE product_id = 1;

-- Step 7: Check history again
SELECT * FROM wu14_inventory_history ORDER BY changed_at;
-- Expected: Two records showing the progression: 100→90→85

-- Step 8: Try updating without changing stock (same value)
UPDATE wu14_inventory SET stock = 85 WHERE product_id = 1;
-- Stock didn't change (85 to 85), so trigger's IF condition is false
-- No history record created - this keeps your history table clean!

SELECT * FROM wu14_inventory_history;
-- Expected: Still only two records (the IF statement prevented logging)
-- This is smart! Why log when nothing actually changed?
```

**🔍 How It Works**:
1. User updates: `UPDATE wu14_inventory SET stock = 90 WHERE product_id = 1;`
2. Inventory table is updated (stock changes from 100 to 90)
3. **Trigger fires AFTER** the update is saved
4. Trigger compares: OLD.stock (100) != NEW.stock (90)? YES!
5. Trigger inserts a history record with both old and new values
6. Done—complete audit trail maintained automatically!

**🎓 Understanding OLD vs NEW in UPDATE**:
- **OLD.stock**: The value BEFORE the update (100)
- **NEW.stock**: The value AFTER the update (90)
- Both are available only in UPDATE triggers
- The IF statement prevents logging when stock didn't actually change

**✅ Success Check**: 
- History table should show old_stock and new_stock for each change
- Updates that don't change stock shouldn't create history records
- Each history entry should have an automatic timestamp

---

## 4) BEFORE UPDATE Validation

**🎯 Goal**: Prevent account balances from ever going negative using a BEFORE UPDATE trigger.

**📖 What You'll Learn**: 
- How BEFORE UPDATE triggers work
- Validating changes before they're saved
- Protecting critical business rules in the database

**💭 The Scenario**: 
You're building a banking system. It's critical that no account ever has a negative balance. Even if the application has a bug, the database itself should refuse to allow negative balances!

```sql
-- Step 1: Create accounts table
DROP TABLE IF EXISTS wu14_accounts;
CREATE TABLE wu14_accounts (
  account_id INT PRIMARY KEY, 
  balance DECIMAL(10,2)
);

-- Step 2: Create initial account with $1000
INSERT INTO wu14_accounts VALUES (1, 1000);

SELECT * FROM wu14_accounts;
-- Expected: Account #1 with balance 1000.00

-- Step 3: Create validation trigger
DELIMITER //
CREATE TRIGGER tr_prevent_negative_balance 
BEFORE UPDATE ON wu14_accounts  -- Fires BEFORE the update is saved
FOR EACH ROW
BEGIN
  -- Check if the NEW balance (after update) would be negative
  IF NEW.balance < 0 THEN
    -- Stop the update and show error message
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Balance cannot be negative';
  END IF;
END //
DELIMITER ;

-- Step 4: Test with valid update
UPDATE wu14_accounts SET balance = 500 WHERE account_id = 1;  
-- ✅ Success! Balance goes from 1000 to 500 (still positive)

SELECT * FROM wu14_accounts;
-- Expected: Account #1 now has balance 500.00

-- Step 5: Test with invalid update (uncomment to test)
-- UPDATE wu14_accounts SET balance = -100 WHERE account_id = 1;  
-- ❌ Error! "Balance cannot be negative"
-- The update is prevented—balance stays at 500

SELECT * FROM wu14_accounts;
-- Expected: Balance is still 500.00 (the invalid update was blocked)

-- Step 6: Try edge case - exactly zero
UPDATE wu14_accounts SET balance = 0 WHERE account_id = 1;
-- ✅ Success! Zero is allowed (not negative)

SELECT * FROM wu14_accounts;
-- Expected: Balance is now 0.00

-- Step 7: Try to go negative from zero (uncomment to test)
-- UPDATE wu14_accounts SET balance = -0.01 WHERE account_id = 1;
-- ❌ Error! Even tiny negative amounts are blocked
-- This is database-level protection - even $0.01 negative is caught!
```

**🔍 How It Works**:
1. User tries: `UPDATE wu14_accounts SET balance = -100 WHERE account_id = 1;`
2. **Trigger fires BEFORE** the update is applied
3. Trigger checks: Is NEW.balance (-100) less than 0? YES!
4. Trigger raises error using SIGNAL
5. UPDATE is **cancelled**—balance remains unchanged
6. User sees error message: "Balance cannot be negative"

**🎓 BEFORE UPDATE vs AFTER UPDATE**:
- **BEFORE**: Can prevent the update from happening (validation)
- **AFTER**: Update already happened, can't stop it (logging only)
- For validation, always use BEFORE triggers!

**💡 Business Logic Protection**:
This trigger enforces a critical business rule at the database level:
- Even if application code has bugs, database won't allow negative balances
- Even if someone uses SQL directly, the rule is enforced
- Multiple applications can connect to the same database, all protected

**✅ Success Check**: 
- Valid updates (positive balances) should work
- Updates that would create negative balances should fail with error
- Balance should never be negative in the table

---

## 5) AFTER DELETE Trigger

**🎯 Goal**: Automatically archive deleted customers instead of losing their data forever.

**📖 What You'll Learn**: 
- How AFTER DELETE triggers work
- Using OLD to access deleted row values
- Implementing soft delete/archive patterns

**💭 The Scenario**: 
When customers are deleted from your system, you don't want to lose their information completely. You want to archive it with a timestamp so you can recover it later if needed or keep it for legal/audit purposes.

```sql
-- Step 1: Create the tables
DROP TABLE IF EXISTS wu14_customers, wu14_deleted_customers;

-- Main table: active customers
CREATE TABLE wu14_customers (
  customer_id INT PRIMARY KEY, 
  name VARCHAR(100)
);

-- Archive table: deleted customers
CREATE TABLE wu14_deleted_customers (
  customer_id INT,            -- No PRIMARY KEY (can have duplicates if re-added and deleted)
  name VARCHAR(100), 
  deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Tracks when deleted
);

-- Step 2: Insert a test customer
INSERT INTO wu14_customers VALUES (1, 'Alice');

SELECT * FROM wu14_customers;
-- Expected: Customer #1 Alice

-- Step 3: Create archive trigger
DELIMITER //
CREATE TRIGGER tr_archive_deleted 
AFTER DELETE ON wu14_customers  -- Fires AFTER a customer is deleted
FOR EACH ROW
BEGIN
  -- OLD contains the row that was just deleted
  -- Save it to the archive table
  INSERT INTO wu14_deleted_customers (customer_id, name) 
  VALUES (OLD.customer_id, OLD.name);
END //
DELIMITER ;

-- Step 4: Delete the customer
DELETE FROM wu14_customers WHERE customer_id = 1;

-- Step 5: Check main table
SELECT * FROM wu14_customers;
-- Expected: Empty (Alice was deleted)

-- Step 6: Check archive table
SELECT * FROM wu14_deleted_customers;
-- Expected: Customer #1 Alice with deletion timestamp

-- Step 7: Try deleting multiple customers
INSERT INTO wu14_customers VALUES (2, 'Bob'), (3, 'Charlie');
DELETE FROM wu14_customers WHERE customer_id IN (2, 3);

-- Step 8: View complete archive
SELECT * FROM wu14_deleted_customers ORDER BY deleted_at;
-- Expected: Three archived customers (Alice, Bob, Charlie) with timestamps
```

**🔍 How It Works**:
1. User deletes: `DELETE FROM wu14_customers WHERE customer_id = 1;`
2. Row is removed from wu14_customers table
3. **Trigger fires AFTER** the deletion is complete
4. Trigger accesses OLD (the deleted row data)
5. Trigger inserts the deleted data into archive table with timestamp
6. Data is preserved even though it's deleted from main table!

**🎓 Understanding OLD in DELETE**:
- **OLD**: Contains the row that was just deleted
- **NEW**: Does NOT exist in DELETE triggers (no new data!)
- OLD is your only way to access the deleted data
- If you don't capture it in the trigger, it's gone forever

**💡 Soft Delete Pattern**:
This is a common pattern called "archiving" or "soft delete":
- Hard delete: `DELETE FROM table` (data is gone)
- Soft delete: Move to archive table (data is preserved)
- Benefits: Can recover accidentally deleted data, maintain audit trail, meet legal requirements

**🔧 Alternative Approach**:
Instead of a separate archive table, many systems use a "deleted_at" column:
```sql
-- Add deleted_at column to main table
ALTER TABLE customers ADD deleted_at TIMESTAMP NULL;

-- "Delete" by setting the timestamp
UPDATE customers SET deleted_at = NOW() WHERE customer_id = 1;

-- Query only active customers
SELECT * FROM customers WHERE deleted_at IS NULL;
```

**✅ Success Check**: 
- Main table should be empty after delete
- Archive table should contain the deleted customer with timestamp
- Archive should preserve all data from deleted row

---

## 6) Auto-Update Timestamp

**🎯 Goal**: Automatically set created_at and updated_at timestamps without users having to remember to do it.

**📖 What You'll Learn**: 
- Modifying NEW values in BEFORE triggers
- Creating multiple triggers on the same table
- Implementing automatic timestamp tracking

**💭 The Scenario**: 
Every blog post should track when it was created and when it was last updated. Instead of making developers remember to set these fields, triggers do it automatically. When a post is created, both timestamps are set. When updated, only updated_at changes!

```sql
-- Step 1: Create posts table
DROP TABLE IF EXISTS wu14_posts;
CREATE TABLE wu14_posts (
  post_id INT PRIMARY KEY, 
  content TEXT, 
  created_at TIMESTAMP,    -- When post was created
  updated_at TIMESTAMP     -- When post was last modified
);

-- Step 2: Create INSERT trigger (sets both timestamps)
DELIMITER //
CREATE TRIGGER tr_set_timestamps 
BEFORE INSERT ON wu14_posts
FOR EACH ROW
BEGIN
  -- Set both timestamps when creating new post
  SET NEW.created_at = NOW();
  SET NEW.updated_at = NOW();
END //
DELIMITER ;

-- Step 3: Create UPDATE trigger (sets only updated_at)
DELIMITER //
CREATE TRIGGER tr_update_timestamp 
BEFORE UPDATE ON wu14_posts
FOR EACH ROW
BEGIN
  -- Only update the updated_at timestamp
  -- created_at stays the same!
  SET NEW.updated_at = NOW();
END //
DELIMITER ;

-- Step 4: Test INSERT trigger
-- Notice: We don't specify created_at or updated_at—trigger sets them!
INSERT INTO wu14_posts (post_id, content) 
VALUES (1, 'First post');

SELECT * FROM wu14_posts;
-- Expected: Post with both timestamps set to current time

-- Step 5: Wait a moment, then update the post
-- (In real testing, you might add a SLEEP(2) or just run UPDATE later)
UPDATE wu14_posts 
SET content = 'First post - UPDATED' 
WHERE post_id = 1;

-- Step 6: Check timestamps
SELECT 
  post_id,
  content,
  created_at,
  updated_at,
  TIMESTAMPDIFF(SECOND, created_at, updated_at) AS seconds_between
FROM wu14_posts;
-- Expected: created_at stays original, updated_at is newer

-- Step 7: Update again
UPDATE wu14_posts 
SET content = 'First post - UPDATED AGAIN' 
WHERE post_id = 1;

SELECT 
  post_id,
  created_at,
  updated_at
FROM wu14_posts;
-- Expected: created_at unchanged, updated_at reflects latest update

-- Step 8: Insert another post to verify INSERT trigger still works
INSERT INTO wu14_posts (post_id, content) 
VALUES (2, 'Second post');

SELECT * FROM wu14_posts ORDER BY post_id;
-- Expected: Post #2 has fresh timestamps, Post #1 has original created_at
```

**🔍 How It Works**:

**On INSERT:**
1. User inserts: `INSERT INTO wu14_posts (post_id, content) VALUES (1, 'First post');`
2. **tr_set_timestamps trigger fires BEFORE** insert
3. Trigger sets: `NEW.created_at = NOW()` and `NEW.updated_at = NOW()`
4. Row is saved with both timestamps automatically filled

**On UPDATE:**
1. User updates: `UPDATE wu14_posts SET content = 'Updated' WHERE post_id = 1;`
2. **tr_update_timestamp trigger fires BEFORE** update
3. Trigger sets: `NEW.updated_at = NOW()`
4. NEW.created_at keeps its original value (not modified by trigger)
5. Row is saved with updated_at changed, created_at unchanged

**🎓 Multiple Triggers on Same Table**:
- You can have multiple triggers on the same table
- Different triggers for different events (INSERT, UPDATE, DELETE)
- MySQL executes triggers in alphabetical order by name if multiple triggers exist for same event
- Best practice: Use clear naming (tr_set_timestamps, tr_update_timestamp)

**💡 Why Use BEFORE Triggers Here?**:
- BEFORE triggers can modify NEW values before they're saved
- SET NEW.column = value only works in BEFORE triggers
- AFTER triggers can't modify the row (it's already saved)

**🔧 Alternative Using DEFAULT**:
MySQL also supports automatic timestamps with DEFAULT and ON UPDATE:
```sql
CREATE TABLE posts (
  id INT PRIMARY KEY,
  content TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```
But triggers give you more control and flexibility!

**✅ Success Check**: 
- created_at should be set on INSERT and never change
- updated_at should be set on INSERT and change on every UPDATE
- Users never need to manually set timestamp fields

---

## 7) Computed Column with Trigger

**🎯 Goal**: Automatically calculate order item totals (quantity × unit_price) without requiring manual calculation.

**📖 What You'll Learn**: 
- Using triggers to compute derived values
- Maintaining data consistency automatically
- Preventing manual calculation errors

**💭 The Scenario**: 
In an order system, the total cost of an item should always be quantity × unit_price. Instead of having users calculate this or relying on application code, a trigger ensures it's always correct, even if someone updates quantity or price!

```sql
-- Step 1: Create order items table
DROP TABLE IF EXISTS wu14_order_items;
CREATE TABLE wu14_order_items (
  item_id INT PRIMARY KEY, 
  quantity INT,                  -- How many ordered
  unit_price DECIMAL(10,2),      -- Price per unit
  total DECIMAL(10,2)            -- Automatically calculated!
);

-- Step 2: Create INSERT trigger (calculates total on new orders)
DELIMITER //
CREATE TRIGGER tr_calculate_total 
BEFORE INSERT ON wu14_order_items
FOR EACH ROW
BEGIN
  -- Automatically calculate: total = quantity × unit_price
  SET NEW.total = NEW.quantity * NEW.unit_price;
END //
DELIMITER ;

-- Step 3: Create UPDATE trigger (recalculates if quantity or price changes)
DELIMITER //
CREATE TRIGGER tr_update_total 
BEFORE UPDATE ON wu14_order_items
FOR EACH ROW
BEGIN
  -- Recalculate total whenever row is updated
  SET NEW.total = NEW.quantity * NEW.unit_price;
END //
DELIMITER ;

-- Step 4: Test INSERT trigger
-- Notice: We DON'T provide total—trigger calculates it!
INSERT INTO wu14_order_items (item_id, quantity, unit_price) 
VALUES (1, 5, 10.00);

SELECT * FROM wu14_order_items;
-- Expected: item_id=1, quantity=5, unit_price=10.00, total=50.00

-- Step 5: Try different quantities and prices
INSERT INTO wu14_order_items (item_id, quantity, unit_price) 
VALUES (2, 3, 25.50);

SELECT * FROM wu14_order_items;
-- Expected: item #2 has total = 76.50 (3 × 25.50)

-- Step 6: Test UPDATE trigger - change quantity
UPDATE wu14_order_items 
SET quantity = 10 
WHERE item_id = 1;

SELECT * FROM wu14_order_items WHERE item_id = 1;
-- Expected: total automatically updated to 100.00 (10 × 10.00)

-- Step 7: Test UPDATE trigger - change price
UPDATE wu14_order_items 
SET unit_price = 15.00 
WHERE item_id = 1;

SELECT * FROM wu14_order_items WHERE item_id = 1;
-- Expected: total automatically updated to 150.00 (10 × 15.00)

-- Step 8: Try to manually set wrong total (it gets overwritten!)
UPDATE wu14_order_items 
SET quantity = 2, unit_price = 20.00, total = 999.99 
WHERE item_id = 1;

SELECT * FROM wu14_order_items WHERE item_id = 1;
-- Expected: total = 40.00 (2 × 20.00), NOT 999.99!
-- The trigger overrides any manual total value
-- This demonstrates that triggers have the "final say" - they execute AFTER your UPDATE
-- Even if you try to cheat by setting total manually, the trigger recalculates it!

-- Step 9: View all items with formatted output
SELECT 
  item_id,
  quantity,
  unit_price,
  total,
  CONCAT('$', FORMAT(total, 2)) AS formatted_total
FROM wu14_order_items
ORDER BY item_id;
-- FORMAT() adds comma separators (e.g., $1,234.56)
-- ROUND() just rounds without formatting
```

**🔍 How It Works**:

**On INSERT:**
1. User inserts: `INSERT INTO wu14_order_items (item_id, quantity, unit_price) VALUES (1, 5, 10.00);`
2. **tr_calculate_total trigger fires BEFORE** insert
3. Trigger calculates: `NEW.total = NEW.quantity * NEW.unit_price` (5 × 10 = 50)
4. Row is saved with total automatically filled

**On UPDATE:**
1. User updates: `UPDATE wu14_order_items SET quantity = 10 WHERE item_id = 1;`
2. **tr_update_total trigger fires BEFORE** update
3. Trigger recalculates: `NEW.total = NEW.quantity * NEW.unit_price` (10 × 10 = 100)
4. Row is saved with corrected total

**🎓 Computed Columns Explained**:
- **Computed Column**: A column whose value is calculated from other columns
- **Benefit**: Always accurate, no manual calculation errors
- **Downside**: Stores redundant data (could be calculated on query)
- **Trade-off**: Storage space vs query performance

**💡 Why Not Calculate on Query?**:
You could calculate total when querying:
```sql
SELECT quantity, unit_price, (quantity * unit_price) AS total 
FROM order_items;
```
**Pros of storing with trigger:**
- Faster queries (no calculation needed)
- Consistent formatting
- Can index the computed value

**Pros of calculating on query:**
- No redundant storage
- Can't get out of sync
- Simpler schema

**⚠️ Important Note**:
Even if someone tries to set total manually, the trigger overrides it! The trigger is the "single source of truth" for the calculation.

**✅ Success Check**: 
- Total should always equal quantity × unit_price
- Changes to quantity or unit_price should automatically update total
- Manual attempts to set wrong total should be overridden

---

## 8) Multiple Triggers on Same Table

**🎯 Goal**: Learn how to create multiple triggers on the same table and understand their execution order.

**📖 What You'll Learn**: 
- Creating multiple triggers for the same event
- Trigger execution order (alphabetical by name)
- Combining validation and modification in different triggers

**💭 The Scenario**: 
When updating employee salaries, you want TWO things to happen automatically: (1) Validate that salary is positive, and (2) Update the last_modified timestamp. These are separate concerns, so you use separate triggers!

```sql
-- Step 1: Create employees table
DROP TABLE IF EXISTS wu14_employees;
CREATE TABLE wu14_employees (
  emp_id INT PRIMARY KEY, 
  salary DECIMAL(10,2),
  last_modified TIMESTAMP
);

-- Step 2: Create FIRST trigger - validation (alphabetically first: "emp_validate")
DELIMITER //
CREATE TRIGGER tr_emp_validate 
BEFORE UPDATE ON wu14_employees
FOR EACH ROW
BEGIN
  -- Validation: Ensure salary is not negative
  IF NEW.salary < 0 THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Salary must be positive';
  END IF;
END //
DELIMITER ;

-- Step 3: Create SECOND trigger - timestamp (alphabetically second: "emp_timestamp")
DELIMITER //
CREATE TRIGGER tr_emp_timestamp 
BEFORE UPDATE ON wu14_employees
FOR EACH ROW
BEGIN
  -- Automatic timestamp update
  SET NEW.last_modified = NOW();
END //
DELIMITER ;

-- Step 4: Insert test data
INSERT INTO wu14_employees VALUES (1, 50000, NOW());

SELECT * FROM wu14_employees;
-- Expected: emp_id=1, salary=50000, last_modified=current timestamp

-- Step 5: Test valid update (both triggers should fire)
UPDATE wu14_employees 
SET salary = 55000 
WHERE emp_id = 1;

SELECT * FROM wu14_employees;
-- Expected: salary=55000, last_modified=updated to NOW

-- Step 6: Check execution order with SHOW TRIGGERS
SHOW TRIGGERS WHERE `Table` = 'wu14_employees';
-- Expected: You'll see both triggers listed
-- Note: The output shows Timing, Event, and Statement columns
-- You can see which trigger fires when (BEFORE UPDATE) and what it does

-- Step 7: Test invalid update (validation should fail) - uncomment to test
-- UPDATE wu14_employees SET salary = -1000 WHERE emp_id = 1;
-- ❌ Error! First trigger (tr_emp_validate) catches it
-- Second trigger (tr_emp_timestamp) never runs because first trigger stopped the update
-- This is important: When one trigger raises an error, subsequent triggers don't execute
-- It's like a security checkpoint - if you fail at checkpoint 1, you never reach checkpoint 2

SELECT * FROM wu14_employees;
-- Expected: Salary still 55000 (invalid update was blocked)

-- Step 8: Test multiple updates
UPDATE wu14_employees SET salary = 60000 WHERE emp_id = 1;
-- Wait a moment (or add more operations)
UPDATE wu14_employees SET salary = 65000 WHERE emp_id = 1;

SELECT 
  emp_id,
  salary,
  last_modified,
  NOW() AS current_time
FROM wu14_employees;
-- Expected: last_modified reflects the most recent update

-- Step 9: Verify both triggers still working
INSERT INTO wu14_employees VALUES (2, 40000, NOW());
UPDATE wu14_employees SET salary = 45000 WHERE emp_id = 2;
-- Should work: validation passes, timestamp updates

SELECT * FROM wu14_employees ORDER BY emp_id;
```

**🔍 How It Works**:

**When update occurs:**
1. User updates: `UPDATE wu14_employees SET salary = 55000 WHERE emp_id = 1;`
2. MySQL identifies all BEFORE UPDATE triggers on this table
3. **Triggers execute in alphabetical order by name:**
   - First: `tr_emp_validate` (starts with 'v')
   - Second: `tr_emp_timestamp` (starts with 't')
4. tr_emp_validate checks if NEW.salary < 0
   - If yes: Raises error, stops everything (other trigger doesn't run)
   - If no: Continues to next trigger
5. tr_emp_timestamp sets NEW.last_modified = NOW()
6. Finally, the UPDATE is applied to the table

**🎓 Multiple Trigger Rules**:

**Execution Order:**
- MySQL executes triggers **alphabetically by trigger name**
- For same event (e.g., BEFORE UPDATE), triggers run in name order
- This is why naming is important: tr_emp_**v**alidate runs before tr_emp_**t**imestamp

**Best Practices:**
- Use prefixes to control order: `tr_1_validate`, `tr_2_timestamp`
- Or use descriptive names and rely on alphabetical order
- Document why you have multiple triggers

**When to Use Multiple Triggers:**
✅ Good reasons:
- Separate concerns (validation vs logging vs calculation)
- Modular code (easier to maintain)
- Can enable/disable individual triggers

❌ Bad reasons:
- Complex logic that should be in one trigger
- Creating trigger chains (triggers calling triggers)

**💡 Alternative: Single Trigger**:
You could combine both into one trigger:
```sql
DELIMITER //
CREATE TRIGGER tr_emp_update BEFORE UPDATE ON wu14_employees
FOR EACH ROW
BEGIN
  -- Validation
  IF NEW.salary < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary must be positive';
  END IF;
  
  -- Timestamp
  SET NEW.last_modified = NOW();
END //
DELIMITER ;
```

**Pros of single trigger:**
- Simpler (fewer triggers to manage)
- Clear execution order
- Better performance (one trigger call)

**Pros of multiple triggers:**
- Modular (easier to read and maintain)
- Can drop/modify one without affecting others
- Reusable (copy validation trigger to other tables)

**🔧 Checking Your Triggers**:
```sql
-- List all triggers
SHOW TRIGGERS;

-- Show specific trigger code
SHOW CREATE TRIGGER tr_emp_validate;

-- List triggers for a specific table
SHOW TRIGGERS WHERE `Table` = 'wu14_employees';

-- Drop a specific trigger
DROP TRIGGER IF EXISTS tr_emp_validate;
```

**✅ Success Check**: 
- Both triggers should execute on valid updates
- Validation trigger should prevent invalid updates
- Timestamp should update every time salary changes
- Triggers execute in alphabetical order by name

---

## 🎉 Key Takeaways from All Exercises

### Trigger Timing & Events
- **BEFORE triggers**: Validate/modify data BEFORE it's saved (can use SET NEW.column)
- **AFTER triggers**: Audit/log AFTER data is saved (read-only access to NEW/OLD)
- **INSERT**: Only NEW values available
- **UPDATE**: Both OLD (before) and NEW (after) values available  
- **DELETE**: Only OLD values available

### Common Patterns You Learned
1. **Validation**: BEFORE triggers with SIGNAL to reject bad data
2. **Audit Logging**: AFTER triggers to record changes
3. **Computed Columns**: BEFORE triggers to calculate derived values
4. **Timestamps**: BEFORE triggers to set created_at/updated_at
5. **Archiving**: AFTER DELETE triggers to preserve deleted data
6. **History Tracking**: AFTER UPDATE triggers to record old→new changes

### MySQL Syntax Reminders
```sql
-- Always use DELIMITER
DELIMITER //
CREATE TRIGGER trigger_name BEFORE/AFTER INSERT/UPDATE/DELETE
ON table_name
FOR EACH ROW
BEGIN
  -- Trigger logic here
END //
DELIMITER ;

-- Raise errors
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error message';

-- Modify NEW values (BEFORE triggers only)
SET NEW.column = value;

-- Access OLD/NEW
OLD.column  -- Value before change
NEW.column  -- Value after change
```

### Best Practices
- ✅ Keep triggers **simple and fast** (complex logic belongs in stored procedures)
- ✅ Use **clear naming** (tr_validate_price, tr_audit_insert)
- ✅ **Test thoroughly** with various scenarios
- ✅ **Document** what each trigger does
- ✅ Use **BEFORE for validation**, **AFTER for logging**
- ❌ Don't modify the same table that fired the trigger
- ❌ Don't create trigger chains (infinite loops!)
- ❌ Don't put business logic that changes frequently in triggers

### Debugging Tips
```sql
SHOW TRIGGERS;                              -- List all triggers
SHOW CREATE TRIGGER trigger_name;           -- View trigger definition
DROP TRIGGER IF EXISTS trigger_name;        -- Remove trigger
```

**🚀 You're Ready!** Now move on to Guided Step-by-Step exercises for more complex trigger scenarios!

