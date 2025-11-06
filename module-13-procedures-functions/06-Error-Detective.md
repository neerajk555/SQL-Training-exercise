# Error Detective — Procedures & Functions

## 📋 Before You Start

### Learning Objectives
By completing these error detective challenges, you will:
- Develop debugging skills for stored procedures and functions
- Practice identifying DELIMITER issues, parameter errors, and return value problems
- Learn to recognize syntax errors in complex code blocks
- Build troubleshooting skills for procedural SQL
- Understand common procedure/function pitfalls

### How to Approach Each Challenge
1. **Read scenario** - understand what procedure should do
2. **Identify syntax error** - check DELIMITER, parameters, RETURN
3. **Answer guiding questions** - analyze procedure structure
4. **Check the fix** - see correct syntax
5. **Test with CALL or SELECT** - verify it works

**Beginner Tip:** Procedure errors often involve missing DELIMITER changes or wrong parameter types. Always use DELIMITER // before CREATE and DELIMITER ; after!

---

## Error Detective Challenges

## Error 1: Missing DELIMITER ❌

**Beginner Explanation:** Without changing the delimiter, MySQL sees the first semicolon and thinks the CREATE statement is complete!

```sql
-- This FAILS!
CREATE PROCEDURE test()
BEGIN
  SELECT 'Hello';  -- This ; ends the CREATE prematurely!
END  -- MySQL never sees this!
```

**Why This is Wrong:**
- MySQL uses `;` as the statement terminator by default
- The `;` after `SELECT 'Hello'` ends the CREATE PROCEDURE statement
- MySQL thinks you're creating an incomplete procedure
- Error: "You have an error in your SQL syntax"

**Fix:** ✅
```sql
-- Change delimiter BEFORE creating procedure
DELIMITER //

CREATE PROCEDURE test()
BEGIN
  SELECT 'Hello';  -- Now this ; is just part of the procedure body
END //  -- This // ends the CREATE statement

-- Change delimiter back to normal
DELIMITER ;

-- Now you can call it
CALL test();
```

**Remember:** Always use `DELIMITER //` before and `DELIMITER ;` after! 🔧

## Error 2: Wrong Parameter Mode ❌

**Beginner Explanation:** IN parameters are read-only! You can't assign values to them.

```sql
-- This FAILS!
DELIMITER //
CREATE PROCEDURE get_count(IN count INT)  -- IN means read-only!
BEGIN
  SELECT COUNT(*) INTO count FROM orders;  -- ERROR: Can't write to IN parameter!
END //
DELIMITER ;
```

**Why This is Wrong:**
- `IN` parameters are for INPUT only (you read them, not write to them)
- Trying to assign a value with `INTO count` fails
- It's like trying to change a function parameter that's passed by value
- Error: "OUT or INOUT argument 1 for routine... is not a variable"

**Fix:** ✅
```sql
DELIMITER //
CREATE PROCEDURE get_count(OUT count INT)  -- OUT means write-only!
BEGIN
  SELECT COUNT(*) INTO count FROM orders;  -- Now it works!
END //
DELIMITER ;

-- Call it
CALL get_count(@result);
SELECT @result;  -- Shows the count
```

**Parameter Rules:**
- **IN:** Pass value INTO procedure (read-only)
- **OUT:** Get value OUT of procedure (write-only, input ignored)
- **INOUT:** Both read and write

**Real-World Example:** If procedure calculates something and returns it, use OUT! 📤

## Error 3: Function Must RETURN ❌

**Beginner Explanation:** Functions MUST use RETURN to send back a value. SELECT doesn't work in functions!

```sql
-- This FAILS!
DELIMITER //
CREATE FUNCTION add(a INT, b INT) RETURNS INT
DETERMINISTIC
BEGIN
  SELECT a + b;  -- ERROR: Functions need RETURN, not SELECT!
END //
DELIMITER ;
```

**Why This is Wrong:**
- Functions must explicitly RETURN a value
- `SELECT` displays results but doesn't return them
- MySQL expects a `RETURN` statement in every function
- Error: "FUNCTION... ended without RETURN"

**Fix:** ✅
```sql
DELIMITER //
CREATE FUNCTION add(a INT, b INT) RETURNS INT
DETERMINISTIC
BEGIN
  RETURN a + b;  -- Correct: RETURN the value!
END //
DELIMITER ;

-- Use it
SELECT add(5, 3);  -- Returns: 8
```

**Key Differences:**
- **Procedures:** Use SELECT to display results (no RETURN needed)
- **Functions:** Must use RETURN (SELECT won't work for output)

**Think of it like:** Functions are like return statements in programming - they must return exactly one value! 🔙

## Error 4: Missing DETERMINISTIC ❌

**Beginner Explanation:** MySQL requires you to declare whether your function always returns the same result for the same inputs!

```sql
-- This FAILS!
DELIMITER //
CREATE FUNCTION calc(x INT) RETURNS INT  -- Missing DETERMINISTIC!
BEGIN
  RETURN x * 2;
END //
DELIMITER ;
```

**Why This is Wrong:**
- MySQL needs to know if function is deterministic (for optimization)
- **DETERMINISTIC:** Same input always produces same output (e.g., math calculations)
- **NOT DETERMINISTIC:** Output may vary (e.g., RAND(), NOW())
- Error: "This function has none of DETERMINISTIC, NO SQL, or READS SQL DATA"

**Fix:** ✅
```sql
DELIMITER //
CREATE FUNCTION calc(x INT) RETURNS INT
DETERMINISTIC  -- Add this declaration!
BEGIN
  RETURN x * 2;
END //
DELIMITER ;
```

**When to Use Each:**
```sql
-- DETERMINISTIC: Same inputs = same output
CREATE FUNCTION calculate_tax(amount DECIMAL(10,2)) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  RETURN amount * 0.08;  -- Always returns same result for same amount
END

-- NOT DETERMINISTIC: Output varies
CREATE FUNCTION get_random_discount() RETURNS DECIMAL(4,2)
NOT DETERMINISTIC
BEGIN
  RETURN RAND() * 0.20;  -- Random value each time!
END
```

**Rule of Thumb:** If your function does pure calculations (no randomness, no current time/date), use DETERMINISTIC! 🎲

## Error 5: Calling Function Wrong ❌

**Beginner Explanation:** Functions and procedures are called differently - don't mix them up!

```sql
-- This FAILS!
CALL my_function(10);  -- ERROR: CALL is for procedures, not functions!
```

**Why This is Wrong:**
- `CALL` is only for procedures
- Functions are used like built-in functions (SUM, COUNT, etc.)
- Functions must be used in SELECT, WHERE, or other expressions
- Error: "PROCEDURE... does not exist" (MySQL looks for a procedure, not a function!)

**Fix:** ✅
```sql
-- Correct way to use functions:
SELECT my_function(10);  -- Use SELECT

-- Or in a query:
SELECT product_name, price, my_function(price) AS calculated_value
FROM products;

-- Or in WHERE clause:
SELECT * FROM products WHERE my_function(price) > 100;
```

**How to Call Each:**
```sql
-- PROCEDURE: Use CALL
DELIMITER //
CREATE PROCEDURE greet(IN name VARCHAR(50))
BEGIN
  SELECT CONCAT('Hello, ', name);
END //
DELIMITER ;

CALL greet('Alice');  -- Correct!

-- FUNCTION: Use SELECT or in expressions
DELIMITER //
CREATE FUNCTION double_it(num INT) RETURNS INT
DETERMINISTIC
BEGIN
  RETURN num * 2;
END //
DELIMITER ;

SELECT double_it(5);  -- Correct!
```

**Easy Way to Remember:**
- **CALL** procedures (they DO things)
- **SELECT** functions (they RETURN things) 📞

