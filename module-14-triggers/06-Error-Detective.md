# Error Detective — Triggers

## Error 1: Infinite Trigger Loop
```sql
CREATE TRIGGER tr1 AFTER UPDATE ON table1
FOR EACH ROW UPDATE table2 SET col = 1;

CREATE TRIGGER tr2 AFTER UPDATE ON table2
FOR EACH ROW UPDATE table1 SET col = 1;
-- Infinite loop!
```
**Fix:** Avoid circular trigger chains.

## Error 2: Missing DELIMITER
```sql
CREATE TRIGGER tr AFTER INSERT ON t
BEGIN SELECT 1; END;  -- Syntax error!
```
**Fix:** Use DELIMITER // ... DELIMITER ;

## Error 3: Using OLD in INSERT Trigger
```sql
CREATE TRIGGER tr AFTER INSERT
BEGIN INSERT INTO log VALUES (OLD.id);  -- OLD doesn't exist in INSERT!
END
```
**Fix:** Use NEW for INSERT, NEW/OLD for UPDATE, OLD for DELETE.

## Error 4: Modifying Same Table
```sql
CREATE TRIGGER tr AFTER INSERT ON t
FOR EACH ROW INSERT INTO t VALUES (...);  -- Can't modify same table!
```
**Fix:** Triggers can't modify the table that fired them.

## Error 5: Complex Logic Slowing Down
```sql
CREATE TRIGGER tr AFTER INSERT
BEGIN
  -- 50 lines of complex calculations --
END  -- Every insert is now slow!
```
**Fix:** Keep triggers simple; move complex logic to stored procedures.

