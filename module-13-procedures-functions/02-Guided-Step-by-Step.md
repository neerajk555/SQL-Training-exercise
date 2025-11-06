# Guided Step-by-Step — Procedures & Functions

## Activity 1: Order Total Calculator

**Goal:** Build a complete order calculator using both functions and procedures!

**Beginner Explanation:** You'll create a function for tax calculation (reusable formula) and a procedure for complete order totals (complex logic with multiple outputs).

### Setup
```sql
DROP TABLE IF EXISTS gs13_order_items;
CREATE TABLE gs13_order_items (
  order_id INT,
  product_name VARCHAR(100),
  quantity INT,
  unit_price DECIMAL(10,2)
);

-- Sample order data
INSERT INTO gs13_order_items VALUES
(1, 'Laptop', 1, 1200.00),
(1, 'Mouse', 2, 25.00),
(2, 'Keyboard', 1, 75.00);

-- Verify data
SELECT * FROM gs13_order_items;
```

### Steps

**Step 1:** Create function to calculate tax
**What's Happening:** Building a reusable tax calculator that works with any amount!
```sql
DROP FUNCTION IF EXISTS gs13_calculate_tax;

DELIMITER //
CREATE FUNCTION gs13_calculate_tax(
  amount DECIMAL(10,2),   -- Amount to calculate tax on
  rate DECIMAL(4,3)       -- Tax rate (0.08 = 8%)
)
RETURNS DECIMAL(10,2)     -- Returns money amount
DETERMINISTIC             -- Same inputs = same output
BEGIN
  -- Multiply amount by rate and round to 2 decimal places
  RETURN ROUND(amount * rate, 2);
END //
DELIMITER ;

-- Test the function
SELECT gs13_calculate_tax(100, 0.08) AS tax;     -- Returns 8.00
SELECT gs13_calculate_tax(1250, 0.08) AS tax;    -- Returns 100.00
```

**Why a Function?** Tax calculation is a pure computation we'll use in many queries!

**Step 2:** Create procedure to calculate order total
**What's Happening:** Building a procedure that calculates subtotal, tax, and total for an order!
```sql
DROP PROCEDURE IF EXISTS gs13_order_total;

DELIMITER //
CREATE PROCEDURE gs13_order_total(
  IN p_order_id INT,              -- Input: which order to calculate
  OUT p_subtotal DECIMAL(10,2),   -- Output: subtotal before tax
  OUT p_tax DECIMAL(10,2),        -- Output: tax amount
  OUT p_total DECIMAL(10,2)       -- Output: final total
)
BEGIN
  -- Step 1: Calculate subtotal (sum of all items)
  SELECT SUM(quantity * unit_price) INTO p_subtotal
  FROM gs13_order_items
  WHERE order_id = p_order_id;
  
  -- Step 2: Calculate tax using our function!
  SET p_tax = gs13_calculate_tax(p_subtotal, 0.08);
  
  -- Step 3: Calculate final total
  SET p_total = p_subtotal + p_tax;
END //
DELIMITER ;
```

**Key Point:** Notice how the procedure CALLS our function! Procedures can use functions. 🎯

**Step 3:** Test procedure
**What's Happening:** Running the procedure and checking all the returned values!

```sql
-- Calculate totals for order 1
CALL gs13_order_total(1, @subtotal, @tax, @total);

-- Check all the returned values
SELECT @subtotal, @tax, @total;
-- Order 1: Laptop ($1200) + 2 Mouse ($50) = $1250 subtotal
-- Tax: $1250 × 0.08 = $100
-- Total: $1350

-- Try order 2
CALL gs13_order_total(2, @subtotal, @tax, @total);
SELECT @subtotal, @tax, @total;
-- Order 2: Keyboard ($75) subtotal, $6 tax, $81 total
```

### Key Takeaways
- ✅ **Functions can be called FROM procedures** (reusable components!)
- ✅ **Use OUT parameters** to return multiple values from procedures
- ✅ **DETERMINISTIC** means function always returns same output for same input
- ✅ **Procedures for complex logic**, functions for simple calculations
- ✅ This pattern (function + procedure) is very common in real applications!

**Real-World Impact:** One tax function used everywhere = easy to update tax rate in one place! 💰

---

## Activity 2: Customer Management Procedures

**Goal:** Build a customer registration procedure with validation and error handling!

**Beginner Explanation:** Real applications need to validate data BEFORE inserting. This procedure checks if email already exists and returns helpful messages!

### Setup
```sql
DROP TABLE IF EXISTS gs13_customers;
CREATE TABLE gs13_customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(100) UNIQUE,
  name VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Verify table structure
DESC gs13_customers;
```

### Steps

**Step 1:** Create procedure to add customer with validation
**What's Happening:** Building a "smart" insert that checks for duplicates first!
```sql
DROP PROCEDURE IF EXISTS gs13_add_customer;

DELIMITER //
CREATE PROCEDURE gs13_add_customer(
  IN p_email VARCHAR(100),       -- Input: customer email
  IN p_name VARCHAR(100),        -- Input: customer name
  OUT p_customer_id INT,         -- Output: new customer ID (0 if failed)
  OUT p_message VARCHAR(255)     -- Output: success/error message
)
BEGIN
  -- DECLARE creates a local variable (only exists in this procedure)
  DECLARE existing_count INT;
  
  -- Step 1: Check if email already exists
  SELECT COUNT(*) INTO existing_count
  FROM gs13_customers 
  WHERE email = p_email;
  
  -- Step 2: Validation logic
  IF existing_count > 0 THEN
    -- Email already exists - return error
    SET p_customer_id = 0;
    SET p_message = 'Email already exists';
  ELSE
    -- Email is unique - insert new customer
    INSERT INTO gs13_customers (email, name) 
    VALUES (p_email, p_name);
    
    -- Get the auto-generated customer_id
    SET p_customer_id = LAST_INSERT_ID();
    SET p_message = 'Customer added successfully';
  END IF;
END //
DELIMITER ;
```

**Key Concepts:**
- `DECLARE` creates local variables
- `SELECT...INTO` stores query result in variable
- `IF...THEN...ELSE...END IF` for conditional logic
- `LAST_INSERT_ID()` gets the auto-generated ID from INSERT

**Step 2:** Test procedure
**What's Happening:** Testing both success and error cases!

```sql
-- Test 1: Add new customer (should succeed)
CALL gs13_add_customer('alice@email.com', 'Alice', @id, @msg);
SELECT @id AS customer_id, @msg AS message;
-- Returns: customer_id=1, message='Customer added successfully'

-- Verify in table
SELECT * FROM gs13_customers;

-- Test 2: Try to add duplicate email (should fail gracefully)
CALL gs13_add_customer('alice@email.com', 'Alice2', @id, @msg);
SELECT @id, @msg;
-- Returns: customer_id=0, message='Email already exists'

-- Verify no duplicate was created
SELECT * FROM gs13_customers;

-- Test 3: Add another unique customer (should succeed)
CALL gs13_add_customer('bob@email.com', 'Bob', @id, @msg);
SELECT @id, @msg;
-- Returns: customer_id=2, message='Customer added successfully'
```

### Key Takeaways
- ✅ **Use DECLARE** to create local variables for intermediate calculations
- ✅ **Implement validation logic** before modifying data (check before insert!)
- ✅ **Return meaningful messages** so caller knows what happened
- ✅ **Handle errors gracefully** without crashing (return 0 + error message)
- ✅ **Use LAST_INSERT_ID()** to get auto-generated primary keys
- ✅ This is production-ready code! Real apps use this pattern! 🎯

**Real-World Pattern:** Every "register user" feature in websites uses this exact approach!

