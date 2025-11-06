# Independent Practice — Triggers

## 📚 Overview
These exercises challenge you to apply trigger concepts independently. Try to solve them on your own first, then check the solution if needed. Each exercise includes hints and a complete solution.

---

## Exercise 1: Email Validation (Easy) — 20 min

### 🎯 Problem Statement
Create a trigger that validates email addresses before inserting users. The trigger should:
- Ensure email contains '@' symbol
- Ensure email contains '.' after the '@'
- Ensure email is not empty
- Raise an error if validation fails

### 📋 Requirements
- Trigger timing: BEFORE INSERT
- Table: `ip14_users` (user_id, email, created_at)
- Validation rules:
  - Email must contain '@'
  - Email must contain '.' after '@'
  - Email cannot be NULL or empty string
  - Raise descriptive error messages

### 💡 Hints
<details>
<summary>Click to view hints</summary>

1. Use `LOCATE()` or `INSTR()` function to find '@' in email
2. Check for '.' after '@' using `SUBSTRING()` or multiple `LOCATE()`
3. Use `IF` statements for each validation
4. Use `SIGNAL SQLSTATE '45000'` to raise errors
5. Provide clear error messages for each validation failure

</details>

### 🧪 Test Cases
```sql
-- These should succeed:
INSERT INTO ip14_users VALUES (1, 'alice@example.com', NOW());
INSERT INTO ip14_users VALUES (2, 'bob.smith@company.co.uk', NOW());

-- These should fail:
-- INSERT INTO ip14_users VALUES (3, 'invalid', NOW());           -- No @
-- INSERT INTO ip14_users VALUES (4, 'invalid@', NOW());          -- No domain
-- INSERT INTO ip14_users VALUES (5, 'invalid@nodot', NOW());    -- No .
-- INSERT INTO ip14_users VALUES (6, '', NOW());                  -- Empty
-- INSERT INTO ip14_users VALUES (7, NULL, NOW());                -- NULL
```

### ✅ Solution
<details>
<summary>Click to view solution</summary>

```sql
-- Step 1: Create the table
DROP TABLE IF EXISTS ip14_users;
CREATE TABLE ip14_users (
  user_id INT PRIMARY KEY,
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Create validation trigger
DELIMITER //
CREATE TRIGGER tr_validate_email
BEFORE INSERT ON ip14_users
FOR EACH ROW
BEGIN
  -- Check if email is NULL or empty
  IF NEW.email IS NULL OR NEW.email = '' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Email cannot be empty';
  END IF;
  
  -- Check if email contains '@'
  IF LOCATE('@', NEW.email) = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Email must contain @ symbol';
  END IF;
  
  -- Check if email contains '.' after '@'
  -- Get position of '@', then check for '.' after that position
  IF LOCATE('.', NEW.email, LOCATE('@', NEW.email)) = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Email must contain . after @ symbol';
  END IF;
  
  -- Optional: Check minimum length (e.g., a@b.c = 5 chars minimum)
  IF LENGTH(NEW.email) < 5 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Email is too short';
  END IF;
END //
DELIMITER ;

-- Step 3: Test valid emails
INSERT INTO ip14_users VALUES (1, 'alice@example.com', NOW());
INSERT INTO ip14_users VALUES (2, 'bob.smith@company.co.uk', NOW());
INSERT INTO ip14_users VALUES (3, 'test@test.io', NOW());

SELECT * FROM ip14_users;
-- Expected: All three users inserted successfully

-- Step 4: Test invalid emails (uncomment one at a time to test)
-- INSERT INTO ip14_users VALUES (10, 'invalid', NOW());
-- Error: Email must contain @ symbol

-- INSERT INTO ip14_users VALUES (11, 'invalid@', NOW());
-- Error: Email must contain . after @ symbol

-- INSERT INTO ip14_users VALUES (12, 'invalid@nodot', NOW());
-- Error: Email must contain . after @ symbol

-- INSERT INTO ip14_users VALUES (13, '', NOW());
-- Error: Email cannot be empty

-- INSERT INTO ip14_users VALUES (14, 'a@b', NOW());
-- Error: Email must contain . after @ symbol

-- Verify only valid emails were inserted
SELECT * FROM ip14_users;
-- Expected: Only the 3 valid emails
```

**Explanation for Beginners:**
- `LOCATE('@', NEW.email)` searches for '@' in the email, returns position (1, 2, 3...) or 0 if not found
- `LOCATE('.', NEW.email, start_position)` searches for '.' starting from a specific position
- `LOCATE('.', email, LOCATE('@', email))` is nested: first finds '@', then searches for '.' after that position
- Think of LOCATE like "Find" function in a text editor - it tells you where something is located
- Multiple IF statements check each rule independently (like a checklist)
- Clear error messages help users understand what's wrong with their input

**Why these checks matter:**
- 'alice' - no @ symbol, not valid
- 'alice@' - has @ but no domain after it
- 'alice@test' - has @ but no dot in domain (should be like test.com)
- 'alice@test.com' - valid! Has @ and dot after @

**Alternative: More Robust Validation**
```sql
-- For production, consider regex or more sophisticated validation
-- This is a simple version for learning purposes
```

</details>

---

## Exercise 2: Price History Tracking (Medium) — 30 min

### 🎯 Problem Statement
Build a complete price history system that tracks all price changes for products. When a product price changes, automatically record:
- Product ID
- Old price
- New price
- Change amount (difference)
- Change percentage
- Timestamp

### 📋 Requirements
- Create `ip14_products` table (product_id, name, price)
- Create `ip14_price_history` table (history_id, product_id, old_price, new_price, change_amount, change_percent, changed_at)
- Trigger timing: BEFORE UPDATE
- Only log if price actually changed (not other columns)
- Calculate change amount (new - old)
- Calculate change percentage ((new - old) / old * 100)

### 💡 Hints
<details>
<summary>Click to view hints</summary>

1. Use BEFORE UPDATE trigger to access both OLD and NEW prices
2. Check `OLD.price != NEW.price` to only log price changes
3. Calculate change_amount as: `NEW.price - OLD.price`
4. Calculate change_percent as: `((NEW.price - OLD.price) / OLD.price) * 100`
5. Handle division by zero if old price is 0
6. Use DECIMAL for price fields to avoid floating point issues

</details>

### 🧪 Test Cases
```sql
-- Test Case 1: Price increase
UPDATE ip14_products SET price = 120.00 WHERE product_id = 1;  -- 100 -> 120

-- Test Case 2: Price decrease
UPDATE ip14_products SET price = 90.00 WHERE product_id = 1;   -- 120 -> 90

-- Test Case 3: Update non-price column (should NOT log)
UPDATE ip14_products SET name = 'Updated Name' WHERE product_id = 1;

-- Test Case 4: Multiple products
UPDATE ip14_products SET price = price * 1.1;  -- 10% increase for all
```

### ✅ Solution
<details>
<summary>Click to view solution</summary>

```sql
-- Step 1: Create tables
DROP TABLE IF EXISTS ip14_products, ip14_price_history;

CREATE TABLE ip14_products (
  product_id INT PRIMARY KEY,
  name VARCHAR(100),
  price DECIMAL(10,2)
);

CREATE TABLE ip14_price_history (
  history_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT,
  old_price DECIMAL(10,2),
  new_price DECIMAL(10,2),
  change_amount DECIMAL(10,2),    -- How much it changed (can be negative)
  change_percent DECIMAL(10,2),   -- Percentage change
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_product (product_id),
  INDEX idx_timestamp (changed_at)
);

-- Step 2: Insert sample products
INSERT INTO ip14_products VALUES
  (1, 'Laptop', 100.00),
  (2, 'Mouse', 25.00),
  (3, 'Keyboard', 50.00);

-- Step 3: Create price tracking trigger
DELIMITER //
CREATE TRIGGER tr_track_price_changes
BEFORE UPDATE ON ip14_products
FOR EACH ROW
BEGIN
  -- Only log if price actually changed
  IF OLD.price != NEW.price THEN
    -- Insert into history table
    INSERT INTO ip14_price_history (
      product_id,
      old_price,
      new_price,
      change_amount,
      change_percent,
      changed_at
    )
    VALUES (
      NEW.product_id,
      OLD.price,
      NEW.price,
      NEW.price - OLD.price,  -- Change amount (positive or negative)
      -- Calculate percentage: (new - old) / old * 100
      -- Handle division by zero: if old is 0, show NULL
      CASE 
        WHEN OLD.price = 0 THEN NULL
        ELSE ((NEW.price - OLD.price) / OLD.price) * 100
      END,
      NOW()
    );
  END IF;
END //
DELIMITER ;

-- Step 4: Test price increase
UPDATE ip14_products 
SET price = 120.00 
WHERE product_id = 1;

SELECT * FROM ip14_price_history;
-- Expected: old_price=100, new_price=120, change_amount=20, change_percent=20.00

-- Step 5: Test price decrease
UPDATE ip14_products 
SET price = 90.00 
WHERE product_id = 1;

SELECT * FROM ip14_price_history ORDER BY changed_at;
-- Expected: Two records
-- Record 2: old_price=120, new_price=90, change_amount=-30, change_percent=-25.00

-- Step 6: Test updating non-price column (should NOT create history)
UPDATE ip14_products 
SET name = 'Laptop Pro' 
WHERE product_id = 1;

SELECT COUNT(*) AS history_count FROM ip14_price_history;
-- Expected: Still 2 records (no new entry because price didn't change)

-- Step 7: Test multiple products with percentage increase
UPDATE ip14_products 
SET price = ROUND(price * 1.10, 2)  -- 10% increase
WHERE product_id IN (2, 3);

SELECT 
  h.history_id,
  p.name,
  h.old_price,
  h.new_price,
  h.change_amount,
  h.change_percent,
  h.changed_at
FROM ip14_price_history h
JOIN ip14_products p ON h.product_id = p.product_id
ORDER BY h.changed_at;
-- Expected: 4 records total (2 for Laptop, 1 for Mouse, 1 for Keyboard)

-- Step 8: Analyze price changes
SELECT 
  p.product_id,
  p.name,
  p.price AS current_price,
  COUNT(h.history_id) AS num_changes,
  MIN(h.old_price) AS lowest_price,
  MAX(h.new_price) AS highest_price
FROM ip14_products p
LEFT JOIN ip14_price_history h ON p.product_id = h.product_id
GROUP BY p.product_id, p.name, p.price
ORDER BY p.product_id;

-- Step 9: Find biggest price increases
SELECT 
  p.name,
  h.old_price,
  h.new_price,
  h.change_amount,
  h.change_percent,
  h.changed_at
FROM ip14_price_history h
JOIN ip14_products p ON h.product_id = p.product_id
WHERE h.change_amount > 0  -- Only increases
ORDER BY h.change_percent DESC;

-- Step 10: Price change timeline for specific product
SELECT 
  old_price,
  new_price,
  change_amount,
  CONCAT(
    CASE WHEN change_amount > 0 THEN '+' ELSE '' END,
    ROUND(change_percent, 1), 
    '%'
  ) AS change_pct,
  changed_at
FROM ip14_price_history
WHERE product_id = 1
ORDER BY changed_at;
-- Shows complete price history for product 1
```

**Explanation for Beginners:**
- **BEFORE UPDATE** trigger captures both OLD and NEW prices before the change is saved
- `IF OLD.price != NEW.price` is crucial - it prevents logging when you update the name but price stays the same
- **CASE statement** handles division by zero: if old_price is 0, we can't divide (0/0 = error), so return NULL
- **Negative change_amount** indicates price decrease (e.g., $120 → $90 = -$30)
- **Positive change_amount** indicates price increase (e.g., $100 → $120 = +$20)
- **Indexes** on product_id and changed_at make queries faster (like an index in a book)

**Why this pattern is useful:**
- Historical pricing data for analytics
- Price tracking for competitive analysis  
- Compliance requirements (prove prices weren't manipulated)
- Customer service (explain why price changed)
- Rollback capability (undo price changes if needed)

**Advanced Enhancement Ideas:**
1. Add user tracking (who made the change)
2. Add reason field (sale, promotion, cost increase, etc.)
3. Create alerts for large price changes (> 50%)
4. Add rollback capability (undo price change)
5. Track price change velocity (how often prices change)

</details>

---

## Exercise 3: Cascade Update System (Hard) — 40 min

### 🎯 Problem Statement
Build a trigger system that cascades customer email updates across multiple related tables. When a customer's email changes in the `customers` table, automatically update it in:
- `orders` table
- `support_tickets` table
- `newsletter_subscriptions` table

Also maintain a log of the email change.

### 📋 Requirements
- Create 4 tables: customers, orders, support_tickets, newsletter_subscriptions
- Create email_change_log table for audit trail
- Trigger timing: AFTER UPDATE (after customer email is updated)
- Only cascade if email actually changed
- Update all related tables in a single trigger
- Log the change with old and new emails
- Handle cases where customer has no related records

### 💡 Hints
<details>
<summary>Click to view hints</summary>

1. Use AFTER UPDATE trigger on customers table
2. Check `OLD.email != NEW.email` to ensure email changed
3. Use UPDATE statements to modify other tables
4. Use WHERE clauses to find records with old email
5. INSERT into log table to track the change
6. Consider using variables for readability
7. All updates happen in the same transaction

</details>

### 🧪 Test Cases
```sql
-- Test Case 1: Customer with orders and tickets
UPDATE ip14_customers SET email = 'alice.new@example.com' WHERE customer_id = 1;

-- Test Case 2: Customer with no related records
UPDATE ip14_customers SET email = 'charlie.new@example.com' WHERE customer_id = 3;

-- Test Case 3: Update non-email field (should NOT cascade)
UPDATE ip14_customers SET name = 'Alice Updated' WHERE customer_id = 1;

-- Test Case 4: Multiple customers
UPDATE ip14_customers SET email = CONCAT('updated_', email) WHERE customer_id IN (1, 2);
```

### ✅ Solution
<details>
<summary>Click to view solution</summary>

```sql
-- Step 1: Create all tables
DROP TABLE IF EXISTS ip14_customers, ip14_orders, ip14_support_tickets, 
                      ip14_newsletter_subscriptions, ip14_email_change_log;

-- Main customers table
CREATE TABLE ip14_customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Related tables that store customer email
CREATE TABLE ip14_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  customer_email VARCHAR(100),  -- Denormalized for this exercise
  order_total DECIMAL(10,2),
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ip14_support_tickets (
  ticket_id INT PRIMARY KEY,
  customer_id INT,
  customer_email VARCHAR(100),  -- Denormalized
  subject VARCHAR(200),
  status VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ip14_newsletter_subscriptions (
  subscription_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  email VARCHAR(100),
  subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit log for email changes
CREATE TABLE ip14_email_change_log (
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  old_email VARCHAR(100),
  new_email VARCHAR(100),
  tables_updated VARCHAR(255),  -- Which tables were affected
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Insert sample data
INSERT INTO ip14_customers VALUES
  (1, 'Alice', 'alice@example.com', NOW()),
  (2, 'Bob', 'bob@example.com', NOW()),
  (3, 'Charlie', 'charlie@example.com', NOW());

INSERT INTO ip14_orders VALUES
  (101, 1, 'alice@example.com', 99.99, NOW()),
  (102, 1, 'alice@example.com', 149.99, NOW()),
  (103, 2, 'bob@example.com', 75.00, NOW());

INSERT INTO ip14_support_tickets VALUES
  (201, 1, 'alice@example.com', 'Need help', 'open', NOW()),
  (202, 2, 'bob@example.com', 'Billing question', 'closed', NOW());

INSERT INTO ip14_newsletter_subscriptions (customer_id, email) VALUES
  (1, 'alice@example.com'),
  (2, 'bob@example.com');

-- Step 3: Create cascade update trigger
DELIMITER //
CREATE TRIGGER tr_cascade_email_update
AFTER UPDATE ON ip14_customers
FOR EACH ROW
BEGIN
  -- Declare variables to count updates
  DECLARE orders_updated INT DEFAULT 0;
  DECLARE tickets_updated INT DEFAULT 0;
  DECLARE newsletters_updated INT DEFAULT 0;
  DECLARE tables_affected VARCHAR(255) DEFAULT '';
  
  -- Only proceed if email actually changed
  IF OLD.email != NEW.email THEN
    
    -- Update orders table
    UPDATE ip14_orders
    SET customer_email = NEW.email
    WHERE customer_id = NEW.customer_id 
      AND customer_email = OLD.email;
    
    SET orders_updated = ROW_COUNT();
    
    -- Update support tickets table
    UPDATE ip14_support_tickets
    SET customer_email = NEW.email
    WHERE customer_id = NEW.customer_id 
      AND customer_email = OLD.email;
    
    SET tickets_updated = ROW_COUNT();
    
    -- Update newsletter subscriptions table
    UPDATE ip14_newsletter_subscriptions
    SET email = NEW.email
    WHERE customer_id = NEW.customer_id 
      AND email = OLD.email;
    
    SET newsletters_updated = ROW_COUNT();
    
    -- Build string of affected tables
    IF orders_updated > 0 THEN
      SET tables_affected = CONCAT(tables_affected, 'orders(', orders_updated, ') ');
    END IF;
    
    IF tickets_updated > 0 THEN
      SET tables_affected = CONCAT(tables_affected, 'tickets(', tickets_updated, ') ');
    END IF;
    
    IF newsletters_updated > 0 THEN
      SET tables_affected = CONCAT(tables_affected, 'newsletters(', newsletters_updated, ')');
    END IF;
    
    IF tables_affected = '' THEN
      SET tables_affected = 'none';
    END IF;
    
    -- Log the email change
    INSERT INTO ip14_email_change_log (
      customer_id,
      old_email,
      new_email,
      tables_updated,
      changed_at
    )
    VALUES (
      NEW.customer_id,
      OLD.email,
      NEW.email,
      tables_affected,
      NOW()
    );
    
  END IF;
END //
DELIMITER ;

-- Step 4: Test cascade update for customer with related records
-- Before: Check Alice's email everywhere
SELECT 'BEFORE UPDATE' AS status;
SELECT * FROM ip14_customers WHERE customer_id = 1;
SELECT * FROM ip14_orders WHERE customer_id = 1;
SELECT * FROM ip14_support_tickets WHERE customer_id = 1;
SELECT * FROM ip14_newsletter_subscriptions WHERE customer_id = 1;

-- Perform the update
UPDATE ip14_customers 
SET email = 'alice.new@example.com' 
WHERE customer_id = 1;

-- After: Check that email was updated everywhere
SELECT 'AFTER UPDATE' AS status;
SELECT * FROM ip14_customers WHERE customer_id = 1;
-- Expected: email = 'alice.new@example.com'

SELECT * FROM ip14_orders WHERE customer_id = 1;
-- Expected: Both orders now have 'alice.new@example.com'

SELECT * FROM ip14_support_tickets WHERE customer_id = 1;
-- Expected: Ticket now has 'alice.new@example.com'

SELECT * FROM ip14_newsletter_subscriptions WHERE customer_id = 1;
-- Expected: Subscription now has 'alice.new@example.com'

-- Check the log
SELECT * FROM ip14_email_change_log;
-- Expected: Log entry showing old and new email, tables updated

-- Step 5: Test customer with no related records
UPDATE ip14_customers 
SET email = 'charlie.new@example.com' 
WHERE customer_id = 3;

SELECT * FROM ip14_email_change_log ORDER BY changed_at;
-- Expected: New log entry with tables_updated = 'none'

-- Step 6: Test updating non-email field (should NOT trigger cascade)
UPDATE ip14_customers 
SET name = 'Alice Updated' 
WHERE customer_id = 1;

SELECT COUNT(*) FROM ip14_email_change_log;
-- Expected: Still 2 entries (no new log because email didn't change)

-- Step 7: Test multiple customers
INSERT INTO ip14_orders VALUES 
  (104, 2, 'bob@example.com', 200.00, NOW());

UPDATE ip14_customers 
SET email = CONCAT('updated_', email) 
WHERE customer_id IN (1, 2);

SELECT * FROM ip14_email_change_log ORDER BY changed_at;
-- Expected: 4 total log entries (2 new ones for customers 1 and 2)

-- Step 8: Verify all cascaded updates
SELECT 
  c.customer_id,
  c.name,
  c.email AS customer_email,
  COUNT(DISTINCT o.order_id) AS num_orders,
  COUNT(DISTINCT t.ticket_id) AS num_tickets,
  COUNT(DISTINCT n.subscription_id) AS num_subscriptions
FROM ip14_customers c
LEFT JOIN ip14_orders o ON c.customer_id = o.customer_id 
  AND c.email = o.customer_email
LEFT JOIN ip14_support_tickets t ON c.customer_id = t.customer_id 
  AND c.email = t.customer_email
LEFT JOIN ip14_newsletter_subscriptions n ON c.customer_id = n.customer_id 
  AND c.email = n.email
GROUP BY c.customer_id, c.name, c.email
ORDER BY c.customer_id;
-- All related records should have matching emails

-- Step 9: Email change history for specific customer
SELECT 
  log_id,
  old_email,
  new_email,
  tables_updated,
  changed_at
FROM ip14_email_change_log
WHERE customer_id = 1
ORDER BY changed_at;

-- Step 10: Summary of all email changes
SELECT 
  COUNT(*) AS total_changes,
  COUNT(DISTINCT customer_id) AS customers_affected,
  SUM(CASE WHEN tables_updated != 'none' THEN 1 ELSE 0 END) AS changes_with_cascades
FROM ip14_email_change_log;
```

**Explanation for Beginners:**
- **AFTER UPDATE** trigger means customer email is already updated in customers table before trigger fires
- `IF OLD.email != NEW.email` prevents unnecessary cascading when you update name but not email
- **ROW_COUNT()** is a MySQL function that tells you how many rows the last UPDATE changed (0, 1, 2, etc.)
- **Variables** (orders_updated, tickets_updated) track which tables were affected - used for logging
- **Transaction Safety**: All updates happen in same transaction - think of it as "all or nothing"
  - If any UPDATE fails, MySQL automatically rolls back ALL changes (even the original customer email update)
  - This prevents partial updates that could leave data inconsistent
- **Log** provides complete audit trail - you can see exactly what changed, when, and what was affected

**How the cascade works:**
1. User updates: `UPDATE customers SET email = 'new@email.com' WHERE customer_id = 1`
2. Customer email is updated in customers table
3. Trigger fires AFTER that update
4. Trigger updates email in orders table (for that customer)
5. Trigger updates email in tickets table (for that customer)
6. Trigger updates email in newsletters table (for that customer)
7. Trigger logs the change with count of affected rows
8. All done automatically - user only updated one table!

**Important Notes:**
1. **Data Denormalization**: In this exercise, email is stored in multiple tables (denormalized). In real systems, you'd typically use customer_id as a foreign key and JOIN to get email.
2. **Transaction Safety**: All updates happen in one transaction. If any UPDATE fails, everything rolls back.
3. **Performance**: Cascading updates can be expensive. Consider whether denormalization is really needed.

**Alternative Design (Normalized)**:
```sql
-- Better approach: Don't store email in related tables
CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,  -- Only store ID, not email
  order_total DECIMAL(10,2),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Get customer email via JOIN
SELECT o.*, c.email 
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;
```

**Real-World Considerations:**
- Use foreign keys for referential integrity
- Consider stored procedures for complex cascading logic
- Add error handling and rollback on partial failures
- Log changes for compliance and auditing
- Notify applications/services of email changes
- Consider email verification workflow before cascading

</details>

---

## 🎉 Congratulations!

You've completed the independent practice exercises! You should now be comfortable with:

- ✅ Data validation in triggers
- ✅ Complex calculations and conditional logic
- ✅ Cross-table updates and cascading changes
- ✅ Audit logging and history tracking
- ✅ Error handling and edge cases

**Next Steps:**
- Try the Paired Programming exercises to collaborate
- Move to Real-World Project for a comprehensive challenge
- Review Error Detective to learn common mistakes

