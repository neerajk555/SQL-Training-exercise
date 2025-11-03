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
```sql
DROP PROCEDURE IF EXISTS wu13_hello;

DELIMITER //
CREATE PROCEDURE wu13_hello()
BEGIN
  SELECT 'Hello, World!' AS message;
END //
DELIMITER ;

CALL wu13_hello();
```

---

## 2) Procedure with IN Parameter — 6 min
```sql
DROP PROCEDURE IF EXISTS wu13_greet;

DELIMITER //
CREATE PROCEDURE wu13_greet(IN user_name VARCHAR(50))
BEGIN
  SELECT CONCAT('Hello, ', user_name, '!') AS greeting;
END //
DELIMITER ;

CALL wu13_greet('Alice');
CALL wu13_greet('Bob');
```

---

## 3) Function that Returns Value — 7 min
```sql
DROP FUNCTION IF EXISTS wu13_add;

DELIMITER //
CREATE FUNCTION wu13_add(a INT, b INT)
RETURNS INT
DETERMINISTIC
BEGIN
  RETURN a + b;
END //
DELIMITER ;

SELECT wu13_add(5, 3) AS result;
SELECT product_id, price, wu13_add(price, 10) AS price_plus_10 FROM products;
```

---

## 4) Procedure with OUT Parameter — 7 min
```sql
DROP PROCEDURE IF EXISTS wu13_count_products;

DELIMITER //
CREATE PROCEDURE wu13_count_products(OUT product_count INT)
BEGIN
  SELECT COUNT(*) INTO product_count FROM products;
END //
DELIMITER ;

CALL wu13_count_products(@count);
SELECT @count AS total_products;
```

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
```sql
DROP TABLE IF EXISTS wu13_numbers;
CREATE TABLE wu13_numbers (num INT);

DROP PROCEDURE IF EXISTS wu13_insert_numbers;

DELIMITER //
CREATE PROCEDURE wu13_insert_numbers(IN max_num INT)
BEGIN
  DECLARE i INT DEFAULT 1;
  WHILE i <= max_num DO
    INSERT INTO wu13_numbers VALUES (i);
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;

CALL wu13_insert_numbers(5);
SELECT * FROM wu13_numbers;
```

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
```sql
DROP PROCEDURE IF EXISTS wu13_double_value;

DELIMITER //
CREATE PROCEDURE wu13_double_value(INOUT value INT)
BEGIN
  SET value = value * 2;
END //
DELIMITER ;

SET @num = 10;
CALL wu13_double_value(@num);
SELECT @num AS doubled;  -- Returns 20
```

---

**Key Takeaways:**
- Use DELIMITER to change command terminator
- Procedures: CALL procedure_name()
- Functions: SELECT function_name() or use in WHERE/SELECT
- Parameters: IN (input), OUT (output), INOUT (both)
- Functions must be DETERMINISTIC or NOT DETERMINISTIC
- Functions RETURN single value, procedures can return result sets

