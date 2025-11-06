# Paired Programming — Triggers

## 📋 Before You Start

### Learning Objectives
Through paired programming, you will:
- Experience collaborative trigger development
- Learn to communicate BEFORE vs AFTER timing decisions clearly
- Practice OLD vs NEW row value usage together
- Build teamwork skills for automatic data integrity enforcement
- Apply validation and audit triggers collaboratively

### Paired Programming Roles
**🚗 Driver (Controls Keyboard):**
- Types all SQL code with DELIMITER management
- Verbalizes trigger timing ("Using BEFORE to validate...")
- Asks navigator about OLD vs NEW usage
- Focuses on syntax

**🧭 Navigator (Reviews & Guides):**
- Keeps requirements visible
- Spots missing validation logic
- Suggests test cases (valid and invalid data)
- Discusses BEFORE vs AFTER trade-offs
- **Does NOT touch the keyboard**

### Execution Flow
1. **Setup**: Driver runs schema (CREATE + INSERT)
2. **Partner A**: Focus on validation (BEFORE triggers) → test → **SWITCH ROLES**
3. **Partner B**: Focus on auditing (AFTER triggers) → test → **SWITCH ROLES**
4. **Together**: Test entire system with edge cases
5. **Review**: Compare solutions, discuss trigger design

**Tip:** Test triggers with both valid and invalid data to verify they work correctly!

---

## 🤝 Overview
Pair programming helps you learn by collaborating. One person is the "driver" (writing code), the other is the "navigator" (reviewing, suggesting, catching errors). Switch roles frequently!

---

## Challenge: Complete Data Integrity System

### 🎯 Objective
Build a comprehensive trigger system for an e-commerce order management system. Partner A focuses on validation (BEFORE triggers), Partner B focuses on auditing (AFTER triggers). Then test together!

### 📋 System Requirements

**Database Schema:**
```sql
-- Main tables
CREATE TABLE pp14_products (
  product_id INT PRIMARY KEY,
  name VARCHAR(100),
  price DECIMAL(10,2),
  stock INT,
  min_stock INT DEFAULT 10
);

CREATE TABLE pp14_customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  credit_limit DECIMAL(10,2),
  current_balance DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE pp14_orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  product_id INT,
  quantity INT,
  unit_price DECIMAL(10,2),
  total_price DECIMAL(10,2),
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) DEFAULT 'pending'
);

-- Audit tables
CREATE TABLE pp14_audit_log (
  audit_id INT AUTO_INCREMENT PRIMARY KEY,
  table_name VARCHAR(50),
  action VARCHAR(20),
  record_id INT,
  details TEXT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pp14_low_stock_alerts (
  alert_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT,
  current_stock INT,
  min_stock INT,
  alert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 👥 Role Assignment

#### Partner A: Validation Triggers (BEFORE)

**Your Responsibilities:**
Create BEFORE triggers to validate and enforce business rules:

1. **Product Validation Trigger (BEFORE INSERT/UPDATE on products)**
   - Price must be positive (> 0)
   - Stock cannot be negative (>= 0)
   - min_stock must be >= 0
   - Name cannot be empty

2. **Customer Validation Trigger (BEFORE INSERT/UPDATE on customers)**
   - Email must contain '@' and '.'
   - Credit limit must be positive
   - Current balance cannot exceed credit limit

3. **Order Validation Trigger (BEFORE INSERT on orders)**
   - Quantity must be positive (> 0)
   - Product must exist and have sufficient stock
   - Customer credit limit check (balance + order total <= credit limit)
   - Auto-calculate unit_price from products table
   - Auto-calculate total_price (quantity × unit_price)

**Hints for Partner A:**
```sql
-- Example structure for order validation
DELIMITER //
CREATE TRIGGER tr_validate_order
BEFORE INSERT ON pp14_orders
FOR EACH ROW
BEGIN
  -- Step 1: Declare variables to hold data we'll fetch
  DECLARE product_stock INT;
  DECLARE product_price DECIMAL(10,2);
  DECLARE customer_balance DECIMAL(10,2);
  DECLARE customer_limit DECIMAL(10,2);
  
  -- Step 2: Get product details from products table
  SELECT stock, price INTO product_stock, product_price
  FROM pp14_products WHERE product_id = NEW.product_id;
  
  -- Step 3: Get customer details from customers table
  SELECT current_balance, credit_limit INTO customer_balance, customer_limit
  FROM pp14_customers WHERE customer_id = NEW.customer_id;
  
  -- Step 4: Validation checks with SIGNAL
  -- IF product_stock IS NULL THEN ... (product doesn't exist)
  -- IF NEW.quantity > product_stock THEN ... (not enough stock)
  -- IF customer_balance + NEW.total_price > customer_limit THEN ... (over credit limit)
  
  -- Step 5: Calculate and set values
  -- SET NEW.unit_price = product_price;
  -- SET NEW.total_price = NEW.quantity * product_price;
END //
DELIMITER ;
```

**Beginner Tips for Partner A:**
- Use DECLARE to create variables (like creating variables in any programming language)
- SELECT INTO retrieves data from database and stores it in your variables
- Check for NULL to detect if product/customer doesn't exist
- Use SIGNAL SQLSTATE '45000' to raise errors and stop invalid orders
- BEFORE triggers can modify NEW values before they're saved

#### Partner B: Audit & Automation Triggers (AFTER)

**Your Responsibilities:**
Create AFTER triggers for logging and automation:

1. **Order Audit Trigger (AFTER INSERT on orders)**
   - Log order creation to audit_log
   - Include customer_id, product_id, quantity, total in details

2. **Inventory Update Trigger (AFTER INSERT on orders)**
   - Deduct ordered quantity from product stock
   - Check if stock drops below min_stock
   - If yes, insert alert into low_stock_alerts

3. **Customer Balance Trigger (AFTER INSERT on orders)**
   - Add order total to customer's current_balance

4. **Product Change Audit Trigger (AFTER UPDATE on products)**
   - Log price changes and stock changes
   - Include old and new values in details

**Hints for Partner B:**
```sql
-- Example structure for inventory update
DELIMITER //
CREATE TRIGGER tr_update_inventory
AFTER INSERT ON pp14_orders
FOR EACH ROW
BEGIN
  -- Step 1: Declare variables
  DECLARE new_stock INT;
  DECLARE product_min_stock INT;
  
  -- Step 2: Deduct quantity from product stock
  UPDATE pp14_products
  SET stock = stock - NEW.quantity
  WHERE product_id = NEW.product_id;
  
  -- Step 3: Get the updated stock level
  SELECT stock, min_stock INTO new_stock, product_min_stock
  FROM pp14_products WHERE product_id = NEW.product_id;
  
  -- Step 4: Check if stock dropped below minimum
  IF new_stock < product_min_stock THEN
    -- Insert alert record
    INSERT INTO pp14_low_stock_alerts (product_id, current_stock, min_stock)
    VALUES (NEW.product_id, new_stock, product_min_stock);
  END IF;
END //
DELIMITER ;
```

**Beginner Tips for Partner B:**
- AFTER triggers run after data is already saved (order is confirmed)
- Use UPDATE to modify other tables (not the table that fired the trigger!)
- Retrieve updated values with SELECT INTO after the UPDATE
- Use IF to conditionally insert alerts only when needed
- All your changes happen in one transaction - if anything fails, everything rolls back
- Remember to also log to audit_log and update customer balance!

### 🧪 Together: Testing Phase

Once both partners complete their triggers, test together:

**Test Setup:**
```sql
-- Insert test data
INSERT INTO pp14_products VALUES
  (1, 'Laptop', 1000.00, 50, 10),
  (2, 'Mouse', 25.00, 100, 20),
  (3, 'Keyboard', 75.00, 15, 10);

INSERT INTO pp14_customers VALUES
  (1, 'Alice', 'alice@example.com', 5000.00, 0),
  (2, 'Bob', 'bob@example.com', 1000.00, 500.00);
```

**Test Cases:**

1. **Valid Order (should succeed)**
```sql
INSERT INTO pp14_orders (customer_id, product_id, quantity)
VALUES (1, 2, 5);  -- Alice orders 5 mice

-- Check results:
-- - Order created with correct prices?
-- - Stock deducted (100 → 95)?
-- - Customer balance increased (0 → 125)?
-- - Audit log entry created?
```

2. **Insufficient Stock (should fail)**
```sql
-- Try to order more than available
-- INSERT INTO pp14_orders (customer_id, product_id, quantity)
-- VALUES (1, 3, 20);  -- Only 15 keyboards available
-- Expected: Error message about insufficient stock
```

3. **Credit Limit Exceeded (should fail)**
```sql
-- Bob has $500 balance and $1000 limit (only $500 available)
-- INSERT INTO pp14_orders (customer_id, product_id, quantity)
-- VALUES (2, 1, 1);  -- Laptop costs $1000
-- Expected: Error message about credit limit
```

4. **Low Stock Alert (should trigger)**
```sql
INSERT INTO pp14_orders (customer_id, product_id, quantity)
VALUES (1, 3, 10);  -- Keyboard stock: 15 → 5 (below min of 10)

-- Check alerts:
SELECT * FROM pp14_low_stock_alerts;
-- Expected: Alert for product 3
```

5. **Invalid Product Data (should fail)**
```sql
-- Try to create product with negative price
-- INSERT INTO pp14_products VALUES (4, 'Invalid', -50.00, 10, 5);
-- Expected: Error about negative price
```

6. **Invalid Customer Email (should fail)**
```sql
-- INSERT INTO pp14_customers VALUES (3, 'Charlie', 'invalid-email', 1000, 0);
-- Expected: Error about email format
```

### 🔍 Together: Analysis & Optimization

**Discussion Questions:**

1. **Trigger Execution Order**
   - What happens when order is inserted?
   - Which triggers fire in what order?
   - Draw a diagram of trigger flow

2. **Performance Considerations**
   - Which triggers are most expensive?
   - How would performance change with 1000 orders/minute?
   - What could be optimized?

3. **Error Handling**
   - What happens if product doesn't exist?
   - What if customer doesn't exist?
   - How to make error messages more helpful?

4. **Trigger vs Application Logic**
   - What should be in triggers?
   - What should be in application code?
   - When would you choose one over the other?

5. **Transaction Behavior**
   - If validation fails, what gets rolled back?
   - Are all trigger actions in one transaction?
   - How to test transaction rollback?

**Optimization Ideas to Implement:**
```sql
-- Add indexes for better performance
CREATE INDEX idx_product_id ON pp14_orders(product_id);
CREATE INDEX idx_customer_id ON pp14_orders(customer_id);

-- Consider combining validation checks
-- Instead of multiple triggers, could use one comprehensive trigger

-- Add foreign key constraints (complement triggers)
ALTER TABLE pp14_orders
  ADD FOREIGN KEY (product_id) REFERENCES pp14_products(product_id),
  ADD FOREIGN KEY (customer_id) REFERENCES pp14_customers(customer_id);
```

### 📊 Deliverables

**Code Artifacts:**
- [ ] All validation triggers (Partner A)
- [ ] All audit triggers (Partner B)
- [ ] Test data and test cases
- [ ] Comments explaining business logic

**Documentation:**
- [ ] Trigger flow diagram
- [ ] List of business rules enforced
- [ ] List of known limitations
- [ ] Performance test results

**Discussion Notes:**
- [ ] Pros/cons of trigger-based validation
- [ ] Alternative implementation approaches
- [ ] Lessons learned
- [ ] What would you do differently?

### 🎓 Learning Outcomes

After completing this exercise, you should understand:
- ✅ Coordinating multiple triggers on related tables
- ✅ BEFORE vs AFTER trigger use cases
- ✅ Cross-table validation and updates
- ✅ Audit logging patterns
- ✅ Performance implications of triggers
- ✅ When to use triggers vs application logic
- ✅ Testing strategies for complex trigger systems
- ✅ Collaboration and code review skills

### 💡 Extension Challenges

If you finish early, try these enhancements:

1. **Order Cancellation System**
   - Create trigger for order status change to 'cancelled'
   - Restore stock when order cancelled
   - Reverse customer balance changes

2. **Product Pricing Tiers**
   - Implement discount for bulk orders (>10 items)
   - Modify order trigger to apply discounts

3. **Stock Reorder Automation**
   - When stock drops below minimum, create purchase order
   - Track pending restocks

4. **Customer Loyalty Points**
   - Award points based on order total
   - Track points in customer table

5. **Comprehensive Dashboard Queries**
```sql
-- Sales summary
SELECT 
  p.name,
  COUNT(o.order_id) AS num_orders,
  SUM(o.quantity) AS total_sold,
  SUM(o.total_price) AS revenue
FROM pp14_products p
LEFT JOIN pp14_orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.name
ORDER BY revenue DESC;

-- Customer purchase history
SELECT 
  c.name,
  c.current_balance,
  c.credit_limit,
  c.credit_limit - c.current_balance AS available_credit,
  COUNT(o.order_id) AS num_orders
FROM pp14_customers c
LEFT JOIN pp14_orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.current_balance, c.credit_limit;

-- Low stock products
SELECT 
  p.product_id,
  p.name,
  p.stock AS current_stock,
  p.min_stock,
  p.min_stock - p.stock AS need_to_reorder
FROM pp14_products p
WHERE p.stock < p.min_stock
ORDER BY (p.min_stock - p.stock) DESC;
```

### 🚀 Reflection

**After completing, discuss:**
- What was the most challenging part?
- How did collaboration help?
- What did you learn from your partner?
- How would you structure this in a production system?
- What testing would you add in a real project?

**Remember:** The best code is code that's reviewed and tested thoroughly. Pair programming helps catch bugs early and spreads knowledge across the team!

