# Error Detective — Procedures & Functions

## Error 1: Missing DELIMITER
```sql
CREATE PROCEDURE test()
BEGIN
  SELECT 'Hello';
END
```
**Fix:** Use DELIMITER // before CREATE, DELIMITER ; after END //

## Error 2: Wrong Parameter Mode
```sql
CREATE PROCEDURE get_count(IN count INT)
BEGIN
  SELECT COUNT(*) INTO count FROM table;  -- count should be OUT
END
```
**Fix:** Change IN to OUT for parameters receiving values.

## Error 3: Function Must RETURN
```sql
CREATE FUNCTION add(a INT, b INT) RETURNS INT
BEGIN
  SELECT a + b;  -- Wrong!
END
```
**Fix:** Use RETURN a + b; (not SELECT)

## Error 4: Missing DETERMINISTIC
```sql
CREATE FUNCTION calc(x INT) RETURNS INT
BEGIN
  RETURN x * 2;
END
```
**Fix:** Add DETERMINISTIC or NOT DETERMINISTIC declaration.

## Error 5: Calling Function Wrong
```sql
CALL my_function(10);  -- Wrong!
```
**Fix:** Use SELECT my_function(10); (functions aren't CALLed)

