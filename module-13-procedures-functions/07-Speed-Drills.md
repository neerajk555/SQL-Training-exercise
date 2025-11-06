# Speed Drills — Procedures & Functions

## 📋 Before You Start

### Learning Objectives
By completing these speed drills, you will:
- Build muscle memory for DELIMITER management
- Practice quick recall of procedure/function syntax
- Develop speed with parameter declarations
- Reinforce CALL and SELECT usage
- Test your mastery of stored routines

### How to Use Speed Drills
**Purpose:** Rapid practice for procedure mastery. 2-3 minutes per drill!

**Process:**
1. Write complete syntax from memory
2. Check DELIMITER usage
3. Verify parameter types
4. Practice until automatic
5. Test with CALL/SELECT

**Scoring:** 9-10: Expert | 7-8: Good | 5-6: Practice | <5: Review

---

## Speed Drill Questions

## Drill 1: Simple Procedure
```sql
DELIMITER //
CREATE PROCEDURE test() BEGIN SELECT 1; END //
DELIMITER ;
```

## Drill 2: Call Procedure
`CALL procedure_name();`

## Drill 3: Drop Procedure
`DROP PROCEDURE IF EXISTS procedure_name;`

## Drill 4: Create Function
```sql
DELIMITER //
CREATE FUNCTION add(a INT, b INT) RETURNS INT DETERMINISTIC
BEGIN RETURN a + b; END //
DELIMITER ;
```

## Drill 5: Use Function
`SELECT my_function(10) AS result;`

## Drill 6: IN Parameter
`CREATE PROCEDURE test(IN p_name VARCHAR(50))`

## Drill 7: OUT Parameter
`CREATE PROCEDURE test(OUT p_count INT)`

## Drill 8: INOUT Parameter
`CREATE PROCEDURE test(INOUT p_value INT)`

## Drill 9: IF Statement
```sql
IF condition THEN
  -- code
ELSEIF condition THEN
  -- code
ELSE
  -- code
END IF;
```

## Drill 10: WHILE Loop
```sql
WHILE i < 10 DO
  SET i = i + 1;
END WHILE;
```

