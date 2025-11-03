# Speed Drills — Triggers

## Drill 1: AFTER INSERT
```sql
DELIMITER //
CREATE TRIGGER tr AFTER INSERT ON t
FOR EACH ROW BEGIN
  INSERT INTO log VALUES (NEW.id);
END //
DELIMITER ;
```

## Drill 2: BEFORE UPDATE
```sql
CREATE TRIGGER tr BEFORE UPDATE ON t
FOR EACH ROW BEGIN
  SET NEW.updated_at = NOW();
END //
```

## Drill 3: Show Triggers
`SHOW TRIGGERS FROM database_name;`

## Drill 4: Drop Trigger
`DROP TRIGGER IF EXISTS trigger_name;`

## Drill 5: SIGNAL Error
```sql
IF NEW.price < 0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid price';
END IF;
```

## Drill 6: Access OLD Value
`INSERT INTO history VALUES (OLD.id, OLD.value);`

## Drill 7: Access NEW Value
`INSERT INTO log VALUES (NEW.id, NEW.value);`

## Drill 8: AFTER DELETE
```sql
CREATE TRIGGER tr AFTER DELETE ON t
FOR EACH ROW BEGIN
  INSERT INTO archive VALUES (OLD.id);
END //
```

## Drill 9: Conditional Logic
```sql
IF NEW.status != OLD.status THEN
  INSERT INTO status_log VALUES (NEW.id, OLD.status, NEW.status);
END IF;
```

## Drill 10: Multiple Statements
```sql
BEGIN
  INSERT INTO log1 VALUES (NEW.id);
  INSERT INTO log2 VALUES (NEW.id);
  UPDATE summary SET count = count + 1;
END //
```

