# Quick Warm-Ups — Stored Procedures & Functions (5–10 min each)

## 📋 Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Create stored procedures for reusable SQL logic
- Write functions that return values
- Use parameters (IN, OUT, INOUT)
- Understand DELIMITER and why it's needed
- Call procedures and use functions in queries

### Key Concepts for Beginners
**Procedures vs Functions:**
- **Procedure**: Performs actions, no return value, called with CALL
- **Function**: Returns a single value, used in SELECT/WHERE

**Why DELIMITER?**
- Procedures/functions contain semicolons (;) in their body
- DELIMITER changes the statement terminator temporarily
- Pattern: `DELIMITER //` → create procedure → `DELIMITER ;`

**Parameter Types:**
- `IN`: Input only (read by procedure)
- `OUT`: Output only (set by procedure, returned to caller)
- `INOUT`: Both input and output

**When to Use:**
- ✅ Procedures: Encapsulate complex multi-step operations
- ✅ Functions: Reusable calculations in queries
- ✅ Both: Reduce code duplication, centralize business logic

### Execution Tips
1. **Drop before creating**: Use `DROP PROCEDURE IF EXISTS`
2. **Change DELIMITER**: Always use DELIMITER // before creation
3. **Reset DELIMITER**: Change back to ; after creation
4. **Test immediately**: CALL procedure or SELECT function()

**Beginner Tip:** Procedures perform actions (INSERT, UPDATE). Functions return values for use in queries. Use DELIMITER to change statement terminator!

---

## 1) Simple Procedure — 5 min

**What You'll Learn:** Create your first stored procedure!

**Beginner Explanation:** A procedure is like saving a query with a name, so you can run it anytime without retyping it.

**Solution:**
```sql
-- Drop if exists (prevents "already exists" error)
DROP PROCEDURE IF EXISTS wu13_hello;

-- Change delimiter so semicolons inside procedure don't end the CREATE statement
DELIMITER //

CREATE PROCEDURE wu13_hello()
BEGIN
  SELECT 'Hello, World!' AS message;
END //

-- Change delimiter back to normal
DELIMITER ;

-- Call the procedure (like running a function!)
CALL wu13_hello();
```

**What Happens:** Every time you run `CALL wu13_hello()`, it executes the SELECT statement inside!

**Real-World Use:** Replace "Hello World" with "SELECT * FROM orders WHERE status = 'pending'" for a reusable query! 📦

---

## 2) Procedure with IN Parameter — 6 min

**What You'll Learn:** Pass values INTO a procedure (like function arguments!).

**Beginner Explanation:** `IN` parameters are inputs - you pass them when calling the procedure, like passing arguments to a function in programming.

**Solution:**
```sql
DROP PROCEDURE IF EXISTS wu13_greet;

DELIMITER //
CREATE PROCEDURE wu13_greet(IN user_name VARCHAR(50))  -- IN means "input only"
BEGIN
  -- Use the parameter inside the procedure
  SELECT CONCAT('Hello, ', user_name, '!') AS greeting;
END //
DELIMITER ;

-- Call with different values
CALL wu13_greet('Alice');  -- Output: Hello, Alice!
CALL wu13_greet('Bob');    -- Output: Hello, Bob!
```

**Key Concept:** The `user_name` parameter acts like a variable you can use inside the procedure!

**Real-World Example:** Replace greeting with "SELECT * FROM orders WHERE customer_name = user_name" to get orders for any customer! 🎯

---

## 3) Function that Returns Value — 7 min

**What You'll Learn:** Create a function that calculates and returns a value!

**Beginner Explanation:** Functions are like Excel formulas - they take inputs, calculate something, and return a result. Unlike procedures, functions are used INSIDE queries!

**Solution:**
```sql
DROP FUNCTION IF EXISTS wu13_add;

DELIMITER //
CREATE FUNCTION wu13_add(a INT, b INT)
RETURNS INT           -- Must declare what type of value it returns!
DETERMINISTIC         -- Required in MySQL (same inputs = same output)
BEGIN
  RETURN a + b;       -- Use RETURN (not SELECT!)
END //
DELIMITER ;

-- Use in SELECT (not CALL!)
SELECT wu13_add(5, 3) AS result;  -- Returns: 8

-- Use in calculations with table data
SELECT product_id, price, wu13_add(price, 10) AS price_plus_10 
FROM products;
```

**Key Differences from Procedures:**
- ✅ Functions use `SELECT function()` (not CALL)
- ✅ Functions must RETURN a value
- ✅ Functions need DETERMINISTIC keyword
- ✅ Functions can be used in WHERE clauses!

**Real-World Example:** Create `calculate_tax(price)` to use in all your pricing queries! 💰

---

## 4) Procedure with OUT Parameter — 7 min

**What You'll Learn:** How procedures can "return" values using OUT parameters!

**Beginner Explanation:** Since procedures can't use RETURN like functions, they use OUT parameters to send values back. Think of it like a function returning multiple values!

**Solution:**
```sql
DROP PROCEDURE IF EXISTS wu13_count_products;

DELIMITER //
CREATE PROCEDURE wu13_count_products(OUT product_count INT)  -- OUT means "output"
BEGIN
  -- Use SELECT...INTO to store result in the OUT parameter
  SELECT COUNT(*) INTO product_count FROM products;
END //
DELIMITER ;

-- Call with a session variable (starts with @)
CALL wu13_count_products(@count);

-- Check the value that was "returned"
SELECT @count AS total_products;
```

**How It Works:**
1. Procedure calculates COUNT(*)
2. Stores result in `product_count` parameter
3. Value is copied to `@count` variable
4. You can use `@count` after the CALL

**OUT vs RETURN:**
- Functions: Use `RETURN value;` → returns one value
- Procedures: Use OUT parameters → can "return" multiple values!

**Real-World Example:** Calculate subtotal, tax, and total in one procedure with 3 OUT parameters! 🧮

---

## 5) Function with Conditional Logic — 8 min
```sql
DROP FUNCTION IF EXISTS wu13_grade;

DELIMITER //
CREATE FUNCTION wu13_grade(score INT)
RETURNS VARCHAR(1)
DETERMINISTIC
BEGIN
  IF score >= 90 THEN RETURN 'A';
  ELSEIF score >= 80 THEN RETURN 'B';
  ELSEIF score >= 70 THEN RETURN 'C';
  ELSEIF score >= 60 THEN RETURN 'D';
  ELSE RETURN 'F';
  END IF;
END //
DELIMITER ;

SELECT wu13_grade(85) AS grade;
SELECT student_name, score, wu13_grade(score) AS grade FROM students;
```

---

## 6) Procedure with Loop — 8 min

**What You'll Learn:** Use loops inside procedures for repetitive tasks!

**Beginner Explanation:** Just like for/while loops in programming, SQL procedures can loop! This is powerful for batch operations.

**Setup & Solution:**
```sql
-- Create test table
DROP TABLE IF EXISTS wu13_numbers;
CREATE TABLE wu13_numbers (num INT);

DROP PROCEDURE IF EXISTS wu13_insert_numbers;

DELIMITER //
CREATE PROCEDURE wu13_insert_numbers(IN max_num INT)
BEGIN
  -- DECLARE creates a local variable (only exists inside procedure)
  DECLARE i INT DEFAULT 1;
  
  -- WHILE loop (like while in other languages)
  WHILE i <= max_num DO
    INSERT INTO wu13_numbers VALUES (i);
    SET i = i + 1;  -- Important: increment counter!
  END WHILE;
END //
DELIMITER ;

-- Insert numbers 1 through 5
CALL wu13_insert_numbers(5);

-- Verify the results
SELECT * FROM wu13_numbers;
-- Shows: 1, 2, 3, 4, 5
```

**Loop Types in MySQL:**
- `WHILE condition DO ... END WHILE` (shown above)
- `REPEAT ... UNTIL condition END REPEAT` (do-while style)
- `LOOP ... END LOOP` with `LEAVE` statement (manual break)

**Real-World Use:** Generate test data, process batches, retry operations! 🔄

---

## 7) Function with Date Calculation — 7 min
```sql
DROP FUNCTION IF EXISTS wu13_days_until;

DELIMITER //
CREATE FUNCTION wu13_days_until(future_date DATE)
RETURNS INT
DETERMINISTIC
BEGIN
  RETURN DATEDIFF(future_date, CURDATE());
END //
DELIMITER ;

SELECT wu13_days_until('2025-12-31') AS days_remaining;
```

---

## 8) Procedure with INOUT Parameter — 8 min

**What You'll Learn:** Use INOUT for parameters that are both input AND output!

**Beginner Explanation:** INOUT is like passing a variable by reference in programming - you pass a value in, the procedure modifies it, and you get the modified value back!

**Solution:**
```sql
DROP PROCEDURE IF EXISTS wu13_double_value;

DELIMITER //
CREATE PROCEDURE wu13_double_value(INOUT value INT)  -- INOUT = both input and output!
BEGIN
  -- Read the input value AND modify it
  SET value = value * 2;
END //
DELIMITER ;

-- Set initial value
SET @num = 10;

-- Call procedure (reads 10, sets to 20)
CALL wu13_double_value(@num);

-- Check the modified value
SELECT @num AS doubled;  -- Returns 20
```

**Parameter Type Comparison:**
- **IN:** Read-only (input) → Value goes IN, cannot be changed
- **OUT:** Write-only (output) → Value comes OUT, input value ignored
- **INOUT:** Read-write (both) → Read input value, modify it, return modified value

**When to Use INOUT:**
- Modifying a counter: increment, decrement
- Accumulating values: running total, concatenating strings
- Applying transformations: format_phone_number, normalize_text

**Real-World Example:** 
```sql
-- Format phone number: input "1234567890", output "(123) 456-7890"
CALL format_phone(@phone_number);
```

**Performance Tip:** INOUT is slightly more efficient than using separate IN and OUT parameters when you need both! ⚡

---

**Key Takeaways:**
- Use DELIMITER to change command terminator
- Procedures: CALL procedure_name()
- Functions: SELECT function_name() or use in WHERE/SELECT
- Parameters: IN (input), OUT (output), INOUT (both)
- Functions must be DETERMINISTIC or NOT DETERMINISTIC
- Functions RETURN single value, procedures can return result sets

