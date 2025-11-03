# Speed Drills — Procedures & Functions

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

