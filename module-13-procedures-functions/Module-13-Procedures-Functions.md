# Module 13 · Stored Procedures & Functions

**What You'll Learn:** How to create reusable SQL code blocks that can be called like mini-programs!

## 🎯 Why Use Procedures & Functions?

**Real-World Analogy:** Think of procedures and functions like recipes in a cookbook. Instead of writing out "mix flour, eggs, and milk" every time, you just say "make pancake batter" and everyone knows what to do!

**Benefits:**
- ✅ **Reusability:** Write once, use many times
- ✅ **Maintainability:** Fix logic in one place, not scattered across 100 queries
- ✅ **Performance:** Compiled once, executed many times
- ✅ **Security:** Users can run procedures without direct table access
- ✅ **Business Logic:** Centralize rules (e.g., "15% discount for gold members")

## 🔑 Procedures vs Functions: The Ultimate Guide

| Feature | Stored Procedure | Function |
|---------|------------------|----------|
| **Purpose** | Perform actions | Calculate/return value |
| **Returns** | 0 or more result sets (via OUT params) | Always returns 1 value |
| **How to call** | `CALL procedure_name()` | `SELECT function_name()` |
| **Use in SELECT** | ❌ No | ✅ Yes |
| **Modify data** | ✅ Yes (INSERT/UPDATE/DELETE) | ⚠️ Not recommended |
| **Transaction control** | ✅ Yes (COMMIT/ROLLBACK) | ❌ No |
| **Example** | Process order, send email | Calculate tax, format phone |

**Simple Rule:** 
- Use **PROCEDURE** when you need to DO something (update database, complex logic)
- Use **FUNCTION** when you need to CALCULATE something (return a value for use in queries)

## Key Concepts:
### 1. Simple Procedure (Performs Action)

**What It Does:** Gets all orders for a customer.

```sql
-- Step 1: Change delimiter (because procedure body has semicolons!)
DELIMITER //

-- Step 2: Create the procedure
CREATE PROCEDURE get_customer_orders(IN cust_id INT)
BEGIN
  SELECT * FROM orders WHERE customer_id = cust_id;
END //

-- Step 3: Change delimiter back
DELIMITER ;

-- Step 4: Call the procedure
CALL get_customer_orders(1);
```

**Why DELIMITER?** The procedure body contains `;` which would end the CREATE statement prematurely. `DELIMITER //` tells MySQL "use // as the statement terminator until I tell you otherwise."

---

### 2. Function (Returns a Value)

**What It Does:** Calculates 8% tax on an amount.

```sql
DELIMITER //

CREATE FUNCTION calculate_tax(amount DECIMAL(10,2)) 
RETURNS DECIMAL(10,2)  -- Must declare return type!
DETERMINISTIC          -- Same input = same output
BEGIN
  RETURN amount * 0.08;  -- Use RETURN (not SELECT!)
END //

DELIMITER ;

-- Use in queries
SELECT calculate_tax(100);  -- Returns 8.00

-- Use in calculations
SELECT product_id, price, calculate_tax(price) AS tax
FROM products;
```

**Key Differences:**
- Functions use `RETURN` (not SELECT)
- Must declare `RETURNS type`
- Must include `DETERMINISTIC` or `NOT DETERMINISTIC`
- Called with `SELECT` (not CALL)

---

### 3. Procedure with OUT Parameter (Returns Values)

**What It Does:** Counts orders and returns the result to a variable.

```sql
DELIMITER //

CREATE PROCEDURE count_orders(
  IN cust_id INT,        -- Input: customer ID
  OUT order_count INT    -- Output: will be set by procedure
)
BEGIN
  -- Use SELECT...INTO to set the OUT parameter
  SELECT COUNT(*) INTO order_count 
  FROM orders 
  WHERE customer_id = cust_id;
END //

DELIMITER ;

-- Call with a session variable (starts with @)
CALL count_orders(1, @count);

-- Check the result
SELECT @count;  -- Shows the count returned by procedure
```

**Parameter Types Explained:**
- **IN:** Value goes INTO the procedure (input only, cannot be changed)
- **OUT:** Value comes OUT of the procedure (set by procedure, returned to caller)
- **INOUT:** Both input and output (can be read and modified)

---

### 4. Complete Example: Order Processing

**Real-World Scenario:** Calculate order total with tax and discount.

```sql
-- Function: Calculate discount based on customer tier
DELIMITER //
CREATE FUNCTION get_discount_rate(tier VARCHAR(10)) 
RETURNS DECIMAL(4,3)
DETERMINISTIC
BEGIN
  CASE tier
    WHEN 'gold' THEN RETURN 0.150;
    WHEN 'silver' THEN RETURN 0.100;
    WHEN 'bronze' THEN RETURN 0.050;
    ELSE RETURN 0.000;
  END CASE;
END //
DELIMITER ;

-- Procedure: Calculate complete order total
DELIMITER //
CREATE PROCEDURE calculate_order_total(
  IN p_order_id INT,
  IN p_customer_tier VARCHAR(10),
  OUT p_subtotal DECIMAL(10,2),
  OUT p_discount DECIMAL(10,2),
  OUT p_tax DECIMAL(10,2),
  OUT p_total DECIMAL(10,2)
)
BEGIN
  -- Calculate subtotal
  SELECT SUM(quantity * price) INTO p_subtotal
  FROM order_items
  WHERE order_id = p_order_id;
  
  -- Calculate discount using our function
  SET p_discount = p_subtotal * get_discount_rate(p_customer_tier);
  
  -- Calculate tax on discounted amount
  SET p_tax = (p_subtotal - p_discount) * 0.08;
  
  -- Calculate final total
  SET p_total = p_subtotal - p_discount + p_tax;
END //
DELIMITER ;

-- Use it!
CALL calculate_order_total(1, 'gold', @sub, @disc, @tax, @total);
SELECT @sub AS subtotal, @disc AS discount, @tax AS tax, @total AS total;
```

**This Shows:**
- ✅ Function called FROM procedure
- ✅ Multiple OUT parameters
- ✅ Real business logic (discounts, tax)
- ✅ Reusable calculations
```

## 📚 Best Practices

### When to Use Each

**Use Stored Procedures When:**
- ✅ Performing multiple operations (INSERT, UPDATE, DELETE)
- ✅ Need transaction control (BEGIN, COMMIT, ROLLBACK)
- ✅ Returning multiple result sets
- ✅ Complex business logic with multiple steps
- ✅ Examples: process_order, generate_report, batch_update

**Use Functions When:**
- ✅ Calculating a single value
- ✅ Need to use result in WHERE/SELECT/JOIN
- ✅ Pure computation (no side effects)
- ✅ Examples: calculate_tax, format_phone, get_discount_rate

### MySQL-Specific Requirements

**Functions MUST have:**
- `RETURNS type` declaration
- `RETURN value;` statement
- `DETERMINISTIC` or `NOT DETERMINISTIC` keyword
  - **DETERMINISTIC:** Same input always produces same output (e.g., calculate_tax)
  - **NOT DETERMINISTIC:** Output may vary (e.g., get_current_timestamp)

**Common MySQL Gotchas:**
```sql
-- ❌ Wrong: Function without DETERMINISTIC
CREATE FUNCTION add(a INT, b INT) RETURNS INT
BEGIN
  RETURN a + b;
END;
-- Error: FUNCTION must be declared DETERMINISTIC

-- ✅ Correct:
CREATE FUNCTION add(a INT, b INT) RETURNS INT
DETERMINISTIC
BEGIN
  RETURN a + b;
END;
```

### Error Handling

**Basic Error Handler:**
```sql
DELIMITER //
CREATE PROCEDURE safe_insert(IN email VARCHAR(100), OUT success BOOLEAN)
BEGIN
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
  BEGIN
    SET success = FALSE;
  END;
  
  SET success = TRUE;
  INSERT INTO users (email) VALUES (email);
END //
DELIMITER ;
```

**Handler Types:**
- `CONTINUE HANDLER`: Continue after error
- `EXIT HANDLER`: Exit procedure after error
- `SQLEXCEPTION`: Catches all SQL errors
- `SQLWARNING`: Catches warnings
- `NOT FOUND`: Catches "no data" conditions

### Naming Conventions

**Recommended Patterns:**
- Procedures: `action_noun` → `process_order`, `update_inventory`
- Functions: `verb_noun` or `get_noun` → `calculate_tax`, `get_discount`
- Parameters: prefix with `p_` → `p_customer_id`, `p_amount`
- Variables: prefix with `v_` → `v_total`, `v_count`

### Documentation Template

```sql
/*
  Procedure: calculate_order_total
  Purpose: Calculate complete order total including discounts and tax
  
  Parameters:
    IN  p_order_id (INT)          - Order ID to calculate
    IN  p_customer_tier (VARCHAR) - Customer tier (gold/silver/bronze)
    OUT p_subtotal (DECIMAL)      - Order subtotal before discounts
    OUT p_discount (DECIMAL)      - Discount amount
    OUT p_tax (DECIMAL)           - Tax amount  
    OUT p_total (DECIMAL)         - Final total
    
  Example:
    CALL calculate_order_total(1, 'gold', @sub, @disc, @tax, @total);
    
  Author: Your Name
  Date: 2024-01-15
*/
DELIMITER //
CREATE PROCEDURE calculate_order_total(...)
BEGIN
  -- Implementation
END //
DELIMITER ;
```

## 🚀 Quick Reference Card

```sql
-- CREATE PROCEDURE
DELIMITER //
CREATE PROCEDURE name(IN param1 TYPE, OUT param2 TYPE)
BEGIN
  -- SQL statements
END //
DELIMITER ;
CALL name(value, @variable);

-- CREATE FUNCTION
DELIMITER //
CREATE FUNCTION name(param TYPE) RETURNS TYPE
DETERMINISTIC
BEGIN
  RETURN value;
END //
DELIMITER ;
SELECT name(value);

-- DROP
DROP PROCEDURE IF EXISTS name;
DROP FUNCTION IF EXISTS name;

-- VIEW DEFINITION
SHOW CREATE PROCEDURE name;
SHOW CREATE FUNCTION name;

-- LIST ALL
SHOW PROCEDURE STATUS WHERE Db = 'database_name';
SHOW FUNCTION STATUS WHERE Db = 'database_name';
```

**Remember:** Procedures DO things. Functions RETURN things. Use DELIMITER when creating both! 🎯
