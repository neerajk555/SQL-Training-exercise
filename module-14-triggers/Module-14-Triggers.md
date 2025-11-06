# Module 14 · Triggers

## 🎯 What You'll Learn
Triggers are special stored programs that **automatically execute** when specific database events occur (INSERT, UPDATE, or DELETE). Think of them as "automatic watchers" that spring into action when data changes!

## 📚 What Are Triggers?

### Simple Explanation
Imagine you have a security guard (trigger) watching a door (table). Every time someone enters (INSERT), leaves (DELETE), or changes something (UPDATE), the guard automatically takes action—like writing in a log book or checking their ID. You don't need to tell the guard to do this each time; they do it automatically!

### Key Points for Beginners
- **Automatic Execution**: Triggers run by themselves—no need to CALL them
- **Event-Driven**: They respond to INSERT, UPDATE, or DELETE operations
- **Timing Options**: Can run BEFORE or AFTER the event
- **Row-Level**: Execute once FOR EACH ROW affected
- **Access to Data**: Can see OLD values (before change) and NEW values (after change)

## 🔑 Key Concepts

### 1. Trigger Timing
```sql
-- BEFORE triggers: Run BEFORE the data is saved
--   Use for: Validation, modification, computed values
--   Can modify NEW values before they're saved

-- AFTER triggers: Run AFTER the data is saved
--   Use for: Auditing, logging, updating related tables
--   Cannot modify the row that was just saved
```

### 2. Trigger Events
- **INSERT**: Fires when new rows are added
- **UPDATE**: Fires when existing rows are modified
- **DELETE**: Fires when rows are removed

### 3. OLD vs NEW Values
```sql
-- INSERT: Only NEW is available (the new row being inserted)
-- UPDATE: Both OLD (before) and NEW (after) are available
-- DELETE: Only OLD is available (the row being deleted)
```

## 💡 Common Use Cases

### Example 1: BEFORE INSERT Trigger (Validation)
**Purpose**: Prevent invalid data from being inserted
```sql
-- This trigger checks if a price is negative BEFORE inserting
DELIMITER //
CREATE TRIGGER validate_price 
BEFORE INSERT ON products
FOR EACH ROW
BEGIN
  -- NEW.price refers to the price being inserted
  IF NEW.price < 0 THEN
    -- SIGNAL raises an error and stops the INSERT
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Price cannot be negative';
  END IF;
END //
DELIMITER ;

-- How it works:
-- 1. User tries: INSERT INTO products VALUES (1, 'Item', -50);
-- 2. Trigger fires BEFORE the insert happens
-- 3. Checks: Is -50 < 0? Yes!
-- 4. Raises error and INSERT is cancelled
```

**Beginner Tip**: SQLSTATE '45000' is a user-defined error code. Think of it as your custom error message that stops the operation!

### Example 2: AFTER INSERT Trigger (Audit Log)
**Purpose**: Record who inserted what and when
```sql
-- First, create the audit table to store logs
CREATE TABLE audit_log (
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  table_name VARCHAR(50),
  action VARCHAR(10),
  record_id INT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- This trigger logs every new order AFTER it's inserted
DELIMITER //
CREATE TRIGGER log_new_order 
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
  -- NEW.order_id refers to the order that was just inserted
  INSERT INTO audit_log (table_name, action, record_id, timestamp)
  VALUES ('orders', 'INSERT', NEW.order_id, NOW());
END //
DELIMITER ;

-- How it works:
-- 1. User inserts: INSERT INTO orders VALUES (100, 'Customer1', 250.00);
-- 2. Order is saved to database
-- 3. Trigger fires AFTER the insert succeeds
-- 4. Audit log records: "Order #100 was inserted at 2025-11-06 10:30:00"
```

**Beginner Tip**: Use AFTER triggers for logging because the data is already saved. If the INSERT fails, the trigger won't run!

### Example 3: BEFORE UPDATE Trigger (Maintain History)
**Purpose**: Keep track of price changes over time
```sql
-- First, create a history table
CREATE TABLE price_history (
  history_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT,
  old_price DECIMAL(10,2),
  new_price DECIMAL(10,2),
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- This trigger saves the old price BEFORE updating to new price
DELIMITER //
CREATE TRIGGER archive_price_change 
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
  -- Check if price actually changed (not just other columns)
  IF NEW.price != OLD.price THEN
    -- OLD.price = price before update
    -- NEW.price = price after update
    INSERT INTO price_history (product_id, old_price, new_price, changed_at)
    VALUES (OLD.product_id, OLD.price, NEW.price, NOW());
  END IF;
END //
DELIMITER ;

-- How it works:
-- 1. Product #5 currently costs $100
-- 2. User updates: UPDATE products SET price = 120 WHERE product_id = 5;
-- 3. Trigger fires BEFORE the update is saved
-- 4. Records in price_history: Product #5 changed from $100 to $120
-- 5. Then the update completes and product now shows $120
```

**Beginner Tip**: The IF statement prevents logging when other columns update but price stays the same. This keeps your history table clean!

## 🛠️ MySQL Syntax Requirements

### DELIMITER Command
```sql
-- MySQL needs DELIMITER to handle multiple statements in a trigger
-- Default delimiter is ; but trigger body has ; inside it
-- So we change delimiter temporarily to //

DELIMITER //
CREATE TRIGGER my_trigger AFTER INSERT ON my_table
FOR EACH ROW
BEGIN
  INSERT INTO log VALUES (NEW.id);  -- This ; is part of trigger body
  UPDATE counter SET count = count + 1;  -- This ; too
END //  -- This // ends the trigger
DELIMITER ;  -- Change back to ; for normal SQL
```

### Error Handling with SIGNAL
```sql
-- Raise custom errors to prevent unwanted operations
SIGNAL SQLSTATE '45000'  -- '45000' = user-defined error
SET MESSAGE_TEXT = 'Your custom error message here';
```

## ⚠️ Best Practices for Beginners

### ✅ DO:
- **Keep triggers simple**: Just a few lines of code
- **Use BEFORE for validation**: Stop bad data before it enters
- **Use AFTER for auditing**: Log what happened after it's saved
- **Test thoroughly**: Run INSERT/UPDATE/DELETE and check results
- **Drop before recreating**: Use `DROP TRIGGER IF EXISTS trigger_name;`
- **Use meaningful names**: `tr_validate_price` is better than `tr1`

### ❌ DON'T:
- **Avoid complex logic**: Don't write 50 lines in a trigger
- **Don't modify the same table**: Trigger on table X shouldn't UPDATE table X (causes errors)
- **Don't create trigger chains**: Trigger A fires trigger B fires trigger C (hard to debug)
- **Don't forget DELIMITER**: You'll get syntax errors without it
- **Don't use triggers for everything**: Sometimes application code is better

## 🔍 Debugging Triggers

### How to Check Your Triggers
```sql
-- See all triggers in current database
SHOW TRIGGERS;

-- See specific trigger definition
SHOW CREATE TRIGGER trigger_name;

-- Drop a trigger
DROP TRIGGER IF EXISTS trigger_name;
```

### Common Issues
1. **Trigger doesn't fire**: Check trigger name conflicts or syntax errors
2. **Error but can't see it**: Triggers fail silently; check with SELECT statements
3. **Unexpected results**: Use audit tables to see what trigger actually did
4. **Performance slow**: Trigger runs for EVERY row; keep it fast!

## 📖 Summary Table

| Timing | Event | OLD Available? | NEW Available? | Common Use |
|--------|-------|----------------|----------------|------------|
| BEFORE | INSERT | ❌ | ✅ | Validate/modify new data |
| AFTER | INSERT | ❌ | ✅ | Audit logging |
| BEFORE | UPDATE | ✅ | ✅ | Save history, validate changes |
| AFTER | UPDATE | ✅ | ✅ | Update related tables |
| BEFORE | DELETE | ✅ | ❌ | Archive deleted data |
| AFTER | DELETE | ✅ | ❌ | Clean up related records |

## 🚀 Ready to Practice!
Now that you understand the basics, work through the exercises:
1. **Quick Warm-Ups**: Simple triggers to get comfortable
2. **Guided Step-by-Step**: Build complete systems with guidance
3. **Independent Practice**: Solve problems on your own
4. **Real-World Project**: Apply everything you learned

**Remember**: Triggers are powerful but should be used wisely. Start simple, test thoroughly, and only add complexity when needed!
