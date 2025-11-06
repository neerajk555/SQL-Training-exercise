# Speed Drills — Triggers

## 🎯 Purpose
Speed drills help you memorize common trigger patterns. Practice these until you can write them from memory in under 30 seconds each!

---

## Drill 1: Basic AFTER INSERT Trigger (30 sec)

**Pattern:** Log when new rows are inserted

```sql
DELIMITER //
CREATE TRIGGER tr_log_insert 
AFTER INSERT ON my_table
FOR EACH ROW 
BEGIN
  INSERT INTO log_table VALUES (NEW.id, NOW());
END //
DELIMITER ;
```

**What it does:** Every time a row is inserted into `my_table`, automatically log the ID and timestamp.

**Key points:**
- AFTER INSERT = runs after data is saved
- NEW.id = the ID of the inserted row
- Simple, fast audit logging pattern

---

## Drill 2: BEFORE UPDATE Timestamp (30 sec)

**Pattern:** Automatically set updated_at timestamp

```sql
DELIMITER //
CREATE TRIGGER tr_update_timestamp 
BEFORE UPDATE ON my_table
FOR EACH ROW 
BEGIN
  SET NEW.updated_at = NOW();
END //
DELIMITER ;
```

**What it does:** Automatically updates the `updated_at` column whenever any row is modified.

**Key points:**
- BEFORE UPDATE = can modify NEW values
- SET NEW.column = assigns value before save
- Users never need to manually set timestamp

---

## Drill 3: List All Triggers (10 sec)

**Command:** Show all triggers in current database

```sql
SHOW TRIGGERS;
```

**With database name:**
```sql
SHOW TRIGGERS FROM database_name;
```

**Filter by table:**
```sql
SHOW TRIGGERS WHERE `Table` = 'my_table';
```

**Key points:**
- Use backticks around Table (it's a keyword)
- Shows: trigger name, event, table, timing, statement

---

## Drill 4: Drop Trigger (10 sec)

**Command:** Remove a trigger

```sql
DROP TRIGGER IF EXISTS trigger_name;
```

**Why use IF EXISTS:**
- Won't error if trigger doesn't exist
- Safe for scripts that run multiple times
- Best practice for cleanup

**Example cleanup script:**
```sql
DROP TRIGGER IF EXISTS tr_validate_price;
DROP TRIGGER IF EXISTS tr_audit_insert;
DROP TRIGGER IF EXISTS tr_update_stock;
```

---

## Drill 5: Raise Error with SIGNAL (30 sec)

**Pattern:** Stop operation if validation fails

```sql
DELIMITER //
CREATE TRIGGER tr_validate 
BEFORE INSERT ON products
FOR EACH ROW 
BEGIN
  IF NEW.price < 0 THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Price cannot be negative';
  END IF;
END //
DELIMITER ;
```

**What it does:** Prevents inserting products with negative prices.

**Key points:**
- SQLSTATE '45000' = user-defined error
- MESSAGE_TEXT = your custom error message
- SIGNAL stops the INSERT completely

**Common validation patterns:**
```sql
-- Check NOT NULL
IF NEW.email IS NULL OR NEW.email = '' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email required';
END IF;

-- Check range
IF NEW.age < 0 OR NEW.age > 120 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid age';
END IF;

-- Check format
IF NEW.email NOT LIKE '%@%' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid email format';
END IF;
```

---

## Drill 6: Access OLD Values (30 sec)

**Pattern:** Save data before it changes

```sql
DELIMITER //
CREATE TRIGGER tr_save_history 
BEFORE UPDATE ON products
FOR EACH ROW 
BEGIN
  INSERT INTO price_history (product_id, old_price, changed_at)
  VALUES (OLD.product_id, OLD.price, NOW());
END //
DELIMITER ;
```

**What it does:** Before price changes, save the old price to history table.

**Key points:**
- OLD.column = value before update
- Available in UPDATE and DELETE triggers
- NOT available in INSERT triggers

**When to use OLD:**
- Saving history/audit trails
- Calculating differences (NEW.price - OLD.price)
- Archiving deleted data

---

## Drill 7: Access NEW Values (30 sec)

**Pattern:** Log new data being inserted

```sql
DELIMITER //
CREATE TRIGGER tr_log_new 
AFTER INSERT ON orders
FOR EACH ROW 
BEGIN
  INSERT INTO audit_log (order_id, customer_id, total, created_at)
  VALUES (NEW.order_id, NEW.customer_id, NEW.total, NOW());
END //
DELIMITER ;
```

**What it does:** After order is created, log its details.

**Key points:**
- NEW.column = value being inserted or updated to
- Available in INSERT and UPDATE triggers
- NOT available in DELETE triggers

**When to use NEW:**
- Audit logging new records
- Validation before insert
- Calculating derived values

---

## Drill 8: AFTER DELETE Archive (30 sec)

**Pattern:** Save deleted data before it's gone

```sql
DELIMITER //
CREATE TRIGGER tr_archive_deleted 
AFTER DELETE ON customers
FOR EACH ROW 
BEGIN
  INSERT INTO deleted_customers (customer_id, name, email, deleted_at)
  VALUES (OLD.customer_id, OLD.name, OLD.email, NOW());
END //
DELIMITER ;
```

**What it does:** When customer is deleted, archive their information.

**Key points:**
- AFTER DELETE = data is already removed from main table
- OLD.column = the deleted values
- NEW is not available (nothing new!)
- Soft delete alternative

---

## Drill 9: Conditional Logic in Triggers (45 sec)

**Pattern:** Only log when specific column changes

```sql
DELIMITER //
CREATE TRIGGER tr_status_change 
AFTER UPDATE ON orders
FOR EACH ROW 
BEGIN
  IF OLD.status != NEW.status THEN
    INSERT INTO status_log (order_id, old_status, new_status, changed_at)
    VALUES (NEW.order_id, OLD.status, NEW.status, NOW());
  END IF;
END //
DELIMITER ;
```

**What it does:** Only logs when order status changes, not when other columns update.

**Key points:**
- IF statement filters when to execute
- Prevents unnecessary logging
- More efficient and cleaner logs

**Common conditional patterns:**
```sql
-- Only if changed
IF OLD.price != NEW.price THEN ...

-- Only if crossed threshold
IF NEW.stock < 10 AND OLD.stock >= 10 THEN ...

-- Only if certain status
IF NEW.status = 'completed' THEN ...

-- Multiple conditions
IF NEW.price > OLD.price AND NEW.price > 1000 THEN ...
```

---

## Drill 10: Multiple Statements in Trigger (45 sec)

**Pattern:** Perform several actions in one trigger

```sql
DELIMITER //
CREATE TRIGGER tr_complex_action 
AFTER INSERT ON orders
FOR EACH ROW 
BEGIN
  -- Log to audit table
  INSERT INTO audit_log (action, order_id) 
  VALUES ('NEW_ORDER', NEW.order_id);
  
  -- Update customer order count
  UPDATE customers 
  SET total_orders = total_orders + 1 
  WHERE customer_id = NEW.customer_id;
  
  -- Update product popularity
  UPDATE products 
  SET times_ordered = times_ordered + 1 
  WHERE product_id = NEW.product_id;
  
  -- Update daily summary
  UPDATE daily_summary 
  SET order_count = order_count + 1,
      revenue = revenue + NEW.total
  WHERE date = CURDATE();
END //
DELIMITER ;
```

**What it does:** When order is placed, updates 4 different tables automatically.

**Key points:**
- BEGIN...END allows multiple statements
- All statements execute in one transaction
- If any fails, all rollback
- Each statement ends with semicolon

**⚠️ Performance Warning:**
- More statements = slower trigger
- Affects every insert
- Consider if all updates are really needed
- Maybe use stored procedure instead for complex logic

---

## 🏃 Speed Drill Challenges

**Time yourself on these:**

### Challenge 1: Write from memory (2 min)
Write a BEFORE INSERT trigger that:
- Validates email contains '@'
- Sets created_at to NOW()
- Sets status to 'active' if NULL

### Challenge 2: Fix the bugs (2 min)
```sql
CREATE TRIGGER tr_example AFTER UPDATE ON products
BEGIN
  IF OLD.price < NEW.price THEN
    INSERT INTO price_increases VALUES (NEW.id, NOW());
END;
```
**Bugs:** Missing DELIMITER, missing FOR EACH ROW, missing END IF

### Challenge 3: Complete the pattern (90 sec)
Create AFTER DELETE trigger that archives deleted products with all their data.

### Challenge 4: Optimization (90 sec)
This trigger is slow—how would you improve it?
```sql
CREATE TRIGGER tr_slow AFTER INSERT ON orders
FOR EACH ROW BEGIN
  UPDATE summary SET count = (SELECT COUNT(*) FROM orders);
  UPDATE summary SET total = (SELECT SUM(amount) FROM orders);
  UPDATE summary SET avg = (SELECT AVG(amount) FROM orders);
END;
```

---

## 📝 Quick Reference Card

**Print this or keep it handy:**

```
╔══════════════════════════════════════════════════════════════╗
║                    TRIGGER QUICK REFERENCE                    ║
╠══════════════════════════════════════════════════════════════╣
║ CREATE TRIGGER                                                ║
║   DELIMITER //                                                ║
║   CREATE TRIGGER name BEFORE|AFTER INSERT|UPDATE|DELETE      ║
║   ON table_name FOR EACH ROW                                  ║
║   BEGIN                                                       ║
║     -- statements here                                        ║
║   END //                                                      ║
║   DELIMITER ;                                                 ║
╠══════════════════════════════════════════════════════════════╣
║ VARIABLES                                                     ║
║   NEW.column  - New value (INSERT, UPDATE)                   ║
║   OLD.column  - Old value (UPDATE, DELETE)                   ║
╠══════════════════════════════════════════════════════════════╣
║ VALIDATION                                                    ║
║   IF condition THEN                                           ║
║     SIGNAL SQLSTATE '45000'                                   ║
║     SET MESSAGE_TEXT = 'Error message';                       ║
║   END IF;                                                     ║
╠══════════════════════════════════════════════════════════════╣
║ MODIFICATION                                                  ║
║   SET NEW.column = value;  (BEFORE triggers only)            ║
╠══════════════════════════════════════════════════════════════╣
║ MANAGEMENT                                                    ║
║   SHOW TRIGGERS;                                              ║
║   SHOW CREATE TRIGGER name;                                   ║
║   DROP TRIGGER IF EXISTS name;                                ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 🎓 Mastery Checklist

Test yourself—can you do these WITHOUT looking?

- [ ] Create AFTER INSERT trigger with logging
- [ ] Create BEFORE UPDATE trigger setting timestamp
- [ ] Use SIGNAL to prevent invalid data
- [ ] Access OLD values in UPDATE trigger
- [ ] Access NEW values in INSERT trigger
- [ ] Write trigger with IF conditional
- [ ] Write trigger with multiple statements
- [ ] List all triggers in database
- [ ] Drop a trigger safely
- [ ] Debug a trigger with syntax errors

**Goal:** Write any of these in under 60 seconds with no reference!

---

## 💡 Practice Tips

1. **Muscle Memory**: Type each drill 10 times
2. **Speed**: Time yourself, try to beat your record
3. **Variations**: Change table names, column names, logic
4. **From Memory**: Close this file, write from scratch
5. **Debug Practice**: Intentionally break them, then fix

**Remember:** Fast, confident coding comes from repetition!

