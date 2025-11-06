# Guided Step-by-Step — Triggers

## 📚 Overview
These activities guide you through building complete, real-world trigger systems. Each activity includes detailed steps, explanations, and testing procedures.

---

## Activity 1: Complete Audit System — 20 min

**🎯 Objective**: Build a comprehensive audit logging system that tracks all changes (INSERT, UPDATE, DELETE) to a users table.

**📖 What You'll Learn**:
- Creating multiple triggers for complete audit coverage
- Logging different types of operations
- Storing old and new data for comparison
- Querying audit trails

**💭 Real-World Use Case**: 
Compliance requirements often mandate tracking who changed what and when. This audit system automatically logs every modification to user records—essential for security, compliance, and debugging!

### Setup: Create Tables

```sql
-- Clean up previous attempts
DROP TABLE IF EXISTS gs14_users, gs14_user_audit;

-- Main table: User accounts
CREATE TABLE gs14_users (
  user_id INT PRIMARY KEY, 
  email VARCHAR(100), 
  status VARCHAR(20)  -- e.g., 'active', 'suspended', 'deleted'
);

-- Audit table: Tracks all changes
CREATE TABLE gs14_user_audit (
  audit_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  action VARCHAR(20),        -- 'INSERT', 'UPDATE', or 'DELETE'
  old_data TEXT,             -- Data before change (JSON format)
  new_data TEXT,             -- Data after change (JSON format)
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Step 1: Create AFTER INSERT Trigger (5 min)

**Purpose**: Log when new users are created.

```sql
DELIMITER //
CREATE TRIGGER tr_audit_user_insert
AFTER INSERT ON gs14_users
FOR EACH ROW
BEGIN
  -- Log the insert with only NEW data (no OLD data for inserts)
  INSERT INTO gs14_user_audit (user_id, action, old_data, new_data, timestamp)
  VALUES (
    NEW.user_id,
    'INSERT',
    NULL,  -- No old data for inserts
    CONCAT('{"email":"', NEW.email, '", "status":"', NEW.status, '"}'),
    NOW()
  );
END //
DELIMITER ;
```

**Explanation**:
- Fires AFTER successful insert (data is already saved)
- NEW.user_id, NEW.email, NEW.status contain the inserted values
- old_data is NULL because there was no previous data
- new_data stores a JSON-like string of the inserted values

**Test**:
```sql
-- Insert test user
INSERT INTO gs14_users VALUES (1, 'alice@example.com', 'active');

-- Check audit log
SELECT * FROM gs14_user_audit;
-- Expected: action='INSERT', new_data contains alice's info, old_data is NULL
```

### Step 2: Create AFTER UPDATE Trigger (5 min)

**Purpose**: Log when user data is modified.

```sql
DELIMITER //
CREATE TRIGGER tr_audit_user_update
AFTER UPDATE ON gs14_users
FOR EACH ROW
BEGIN
  -- Log the update with both OLD and NEW data
  INSERT INTO gs14_user_audit (user_id, action, old_data, new_data, timestamp)
  VALUES (
    NEW.user_id,
    'UPDATE',
    CONCAT('{"email":"', OLD.email, '", "status":"', OLD.status, '"}'),
    CONCAT('{"email":"', NEW.email, '", "status":"', NEW.status, '"}'),
    NOW()
  );
END //
DELIMITER ;
```

**Explanation**:
- Captures both OLD (before) and NEW (after) values
- Allows you to see exactly what changed
- Useful for auditing and rollback scenarios

**Test**:
```sql
-- Update user status
UPDATE gs14_users SET status = 'suspended' WHERE user_id = 1;

-- Check audit log
SELECT * FROM gs14_user_audit ORDER BY timestamp;
-- Expected: Two records (INSERT and UPDATE)
-- UPDATE record shows old_data="active", new_data="suspended"
```

### Step 3: Create AFTER DELETE Trigger (5 min)

**Purpose**: Log when users are deleted (archive the data before it's gone).

```sql
DELIMITER //
CREATE TRIGGER tr_audit_user_delete
AFTER DELETE ON gs14_users
FOR EACH ROW
BEGIN
  -- Log the deletion with OLD data (record what was deleted)
  INSERT INTO gs14_user_audit (user_id, action, old_data, new_data, timestamp)
  VALUES (
    OLD.user_id,
    'DELETE',
    CONCAT('{"email":"', OLD.email, '", "status":"', OLD.status, '"}'),
    NULL,  -- No new data for deletes
    NOW()
  );
END //
DELIMITER ;
```

**Explanation**:
- Only OLD values are available (the deleted row)
- new_data is NULL because the row no longer exists
- Critical for recovery and compliance

**Test**:
```sql
-- Delete user
DELETE FROM gs14_users WHERE user_id = 1;

-- Check audit log
SELECT * FROM gs14_user_audit ORDER BY timestamp;
-- Expected: Three records (INSERT, UPDATE, DELETE)
-- Shows complete lifecycle of user #1

-- Check main table
SELECT * FROM gs14_users;
-- Expected: Empty (user was deleted)
```

### Step 4: Comprehensive Testing (3 min)

```sql
-- Test complete lifecycle for another user
INSERT INTO gs14_users VALUES (2, 'bob@example.com', 'active');
UPDATE gs14_users SET email = 'bob.new@example.com' WHERE user_id = 2;
UPDATE gs14_users SET status = 'inactive' WHERE user_id = 2;
DELETE FROM gs14_users WHERE user_id = 2;

-- View complete audit trail
SELECT 
  audit_id,
  user_id,
  action,
  old_data,
  new_data,
  timestamp
FROM gs14_user_audit
ORDER BY user_id, timestamp;
-- Expected: Complete history of both users' lifecycles
```

### Step 5: Query Audit Trail (2 min)

**Useful queries for analysis:**

```sql
-- Find all actions for a specific user
SELECT * FROM gs14_user_audit 
WHERE user_id = 2 
ORDER BY timestamp;

-- Count actions by type
SELECT action, COUNT(*) as count
FROM gs14_user_audit
GROUP BY action;

-- Find recent changes (last hour)
SELECT * FROM gs14_user_audit
WHERE timestamp >= NOW() - INTERVAL 1 HOUR
ORDER BY timestamp DESC;

-- Find status changes
SELECT * FROM gs14_user_audit
WHERE action = 'UPDATE'
  AND old_data LIKE '%status%'
ORDER BY timestamp DESC;
```

**✅ Success Checklist**:
- [ ] All three triggers created without errors
- [ ] INSERT operations logged with new_data
- [ ] UPDATE operations logged with both old_data and new_data
- [ ] DELETE operations logged with old_data
- [ ] Complete user lifecycle visible in audit trail

**🎓 Key Takeaways**:
- AFTER triggers are perfect for audit logging (data is already saved)
- Storing old_data and new_data allows comparison
- Audit trails are essential for compliance and debugging
- Triggers provide automatic, reliable logging

---

## Activity 2: Inventory Auto-Update — 18 min

**🎯 Objective**: Automatically deduct inventory when orders are placed, with validation to prevent overselling.

**📖 What You'll Learn**:
- Triggers modifying other tables
- Cross-table data integrity
- Validation in triggers
- Preventing business rule violations

**💭 Real-World Use Case**: 
E-commerce systems must ensure inventory is updated immediately when orders are placed. This prevents overselling and keeps inventory accurate across all systems!

### Setup: Create Tables

```sql
-- Clean up previous attempts
DROP TABLE IF EXISTS gs14_inventory, gs14_orders;

-- Inventory table: Current stock levels
CREATE TABLE gs14_inventory (
  product_id INT PRIMARY KEY, 
  stock INT                     -- Current available quantity
);

-- Orders table: Customer orders
CREATE TABLE gs14_orders (
  order_id INT PRIMARY KEY, 
  product_id INT,               -- Which product ordered
  quantity INT                  -- How many ordered
);

-- Insert sample inventory
INSERT INTO gs14_inventory VALUES 
  (101, 50),   -- Product 101 has 50 units
  (102, 30),   -- Product 102 has 30 units
  (103, 100);  -- Product 103 has 100 units

-- Verify initial inventory
SELECT * FROM gs14_inventory;
```

### Step 1: Create Basic Inventory Update Trigger (5 min)

**Purpose**: Automatically deduct from inventory when order is placed.

```sql
DELIMITER //
CREATE TRIGGER tr_update_inventory
AFTER INSERT ON gs14_orders
FOR EACH ROW
BEGIN
  -- Deduct ordered quantity from inventory
  UPDATE gs14_inventory
  SET stock = stock - NEW.quantity
  WHERE product_id = NEW.product_id;
END //
DELIMITER ;
```

**Explanation**:
- Fires AFTER order is inserted (order is already saved)
- NEW.product_id and NEW.quantity come from the inserted order
- Updates a DIFFERENT table (gs14_inventory)
- This is safe because we're not modifying the table that fired the trigger

**Test**:
```sql
-- Place an order for 10 units of product 101
INSERT INTO gs14_orders VALUES (1, 101, 10);

-- Check inventory
SELECT * FROM gs14_inventory WHERE product_id = 101;
-- Expected: stock = 40 (was 50, deducted 10)

-- Place another order
INSERT INTO gs14_orders VALUES (2, 102, 5);

-- Check all inventory
SELECT * FROM gs14_inventory ORDER BY product_id;
-- Expected: Product 101 has 40, Product 102 has 25 (was 30)
```

### Step 2: Add Validation to Prevent Overselling (8 min)

**Problem**: What if someone orders more than available stock? We need validation!

```sql
-- Drop the old trigger
DROP TRIGGER IF EXISTS tr_update_inventory;

-- Create improved trigger with validation
DELIMITER //
CREATE TRIGGER tr_update_inventory_safe
AFTER INSERT ON gs14_orders
FOR EACH ROW
BEGIN
  -- Declare variable to hold current stock
  DECLARE current_stock INT;
  
  -- Get current stock for this product
  SELECT stock INTO current_stock
  FROM gs14_inventory
  WHERE product_id = NEW.product_id;
  
  -- Validate: Is there enough stock?
  IF current_stock IS NULL THEN
    -- Product doesn't exist in inventory
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Product not found in inventory';
  ELSEIF current_stock < NEW.quantity THEN
    -- Not enough stock to fulfill order
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Insufficient stock for this order';
  ELSE
    -- Stock is sufficient, deduct it
    UPDATE gs14_inventory
    SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;
  END IF;
END //
DELIMITER ;
```

**Explanation Step-by-Step**:
1. **DECLARE current_stock INT**: Creates a temporary variable to hold a number (like declaring a variable in programming)
2. **SELECT stock INTO current_stock**: Retrieves the stock from the database and stores it in our variable
3. **IF current_stock IS NULL**: Checks if product doesn't exist (SELECT returned nothing)
4. **ELSEIF current_stock < NEW.quantity**: Checks if there's not enough stock
5. **ELSE**: If all checks pass, update the inventory
6. **SIGNAL SQLSTATE '45000'**: Raises a custom error that stops everything and rolls back

Think of it like a security guard at a warehouse:
- First, check if the product exists
- Then, check if there's enough in stock
- Only if both checks pass, allow the inventory to be deducted

**Important Note for Beginners**: This is an AFTER trigger, but SIGNAL still works! Here's what happens:
- The order IS inserted into gs14_orders table
- Then the trigger fires and checks stock
- If validation fails, SIGNAL raises an error
- MySQL automatically rolls back EVERYTHING (including the order insertion)
- This is called a "transaction rollback" - it's like hitting the undo button
- So even though it's AFTER INSERT, the insert gets undone if the trigger fails!

### Step 3: Test Validation (5 min)

**Test Case 1: Valid order**
```sql
-- Product 101 has 40 units, order 15
INSERT INTO gs14_orders VALUES (3, 101, 15);

-- Check inventory
SELECT * FROM gs14_inventory WHERE product_id = 101;
-- Expected: stock = 25 (was 40, deducted 15)
```

**Test Case 2: Insufficient stock (should fail)**
```sql
-- Product 101 has 25 units, try to order 30 (uncomment to test)
-- INSERT INTO gs14_orders VALUES (4, 101, 30);
-- ❌ Error! "Insufficient stock for this order"
-- You'll see: Error Code: 1644. Insufficient stock for this order

-- Verify inventory unchanged
SELECT * FROM gs14_inventory WHERE product_id = 101;
-- Expected: stock = 25 (unchanged because order failed)

-- Verify order wasn't inserted
SELECT * FROM gs14_orders WHERE order_id = 4;
-- Expected: Empty result (order was rolled back - it never actually got saved!)
-- This is the beauty of triggers: atomic operations - either everything succeeds or nothing does
```

**Test Case 3: Non-existent product (should fail)**
```sql
-- Try to order product 999 (doesn't exist) - uncomment to test
-- INSERT INTO gs14_orders VALUES (5, 999, 10);
-- ❌ Error! "Product not found in inventory"
-- This happens when SELECT INTO returns NULL (no matching product)
-- It's like trying to buy something that doesn't exist in the store!
```

**Test Case 4: Exact stock amount**
```sql
-- Product 102 has 25 units, order exactly 25
INSERT INTO gs14_orders VALUES (6, 102, 25);

-- Check inventory
SELECT * FROM gs14_inventory WHERE product_id = 102;
-- Expected: stock = 0 (exactly depleted)
```

**Test Case 5: Try to order from depleted stock**
```sql
-- Product 102 has 0 units, try to order 1 (uncomment to test)
-- INSERT INTO gs14_orders VALUES (7, 102, 1);
-- ❌ Error! "Insufficient stock for this order"
-- Even trying to order 1 when stock is 0 fails the check: 0 < 1 is TRUE
-- This prevents "backorders" unless you specifically program that feature
```

### Complete Test Suite

```sql
-- View current state
SELECT 'Inventory' AS table_name, product_id AS id, stock AS info
FROM gs14_inventory
UNION ALL
SELECT 'Orders', order_id, CONCAT('Product ', product_id, ', Qty ', quantity)
FROM gs14_orders
ORDER BY table_name, id;

-- Summary statistics
SELECT 
  i.product_id,
  i.stock AS current_stock,
  COALESCE(SUM(o.quantity), 0) AS total_ordered
FROM gs14_inventory i
LEFT JOIN gs14_orders o ON i.product_id = o.product_id
GROUP BY i.product_id, i.stock
ORDER BY i.product_id;
```

**✅ Success Checklist**:
- [ ] Trigger automatically updates inventory when order placed
- [ ] Validation prevents ordering non-existent products
- [ ] Validation prevents ordering more than available stock
- [ ] Failed orders don't affect inventory or create order records
- [ ] Exact stock amounts can be ordered (depleting to zero)

**🎓 Key Takeaways**:
- Triggers can modify DIFFERENT tables (not the one that fired them)
- AFTER triggers can still use SIGNAL to roll back transactions
- Always validate data before modifying other tables
- Use DECLARE and SELECT INTO for complex logic
- Test edge cases: sufficient stock, insufficient stock, exact stock, zero stock

**🔧 Alternative Approach**: 
Some systems use BEFORE INSERT trigger on orders to check stock first, then AFTER INSERT to deduct. This separates validation from modification.

**⚠️ Production Considerations**:
- In real systems, consider using transactions explicitly
- Add foreign key constraints between orders and inventory
- Consider using stored procedures for complex order processing
- Add logging to track inventory changes
- Implement order status (pending, fulfilled, cancelled)

---

## 🎉 You've Completed Guided Step-by-Step!

**What You Built:**
1. ✅ Complete audit system with INSERT/UPDATE/DELETE logging
2. ✅ Automatic inventory management with validation

**Skills You Practiced:**
- Creating multiple coordinated triggers
- Using OLD and NEW values effectively
- Cross-table modifications
- Data validation in triggers
- Error handling with SIGNAL
- Comprehensive testing strategies

**Next Steps:**
Move on to **Independent Practice** to solve problems on your own, or review these activities if you need more practice!

