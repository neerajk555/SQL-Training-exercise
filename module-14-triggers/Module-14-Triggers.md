# Module 14 · Triggers

Triggers automatically execute in response to INSERT, UPDATE, or DELETE events.

## Key Concepts:
```sql
-- BEFORE INSERT trigger (validation)
DELIMITER //
CREATE TRIGGER validate_price BEFORE INSERT ON products
FOR EACH ROW
BEGIN
  IF NEW.price < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price cannot be negative';
  END IF;
END //
DELIMITER ;

-- AFTER INSERT trigger (audit log)
DELIMITER //
CREATE TRIGGER log_new_order AFTER INSERT ON orders
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (table_name, action, record_id, timestamp)
  VALUES ('orders', 'INSERT', NEW.order_id, NOW());
END //
DELIMITER ;

-- BEFORE UPDATE trigger (maintain history)
DELIMITER //
CREATE TRIGGER archive_price_change BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
  IF NEW.price != OLD.price THEN
    INSERT INTO price_history (product_id, old_price, new_price, changed_at)
    VALUES (OLD.product_id, OLD.price, NEW.price, NOW());
  END IF;
END //
DELIMITER ;
```

## Best Practices:
- Keep triggers simple and fast
- Avoid complex logic (use procedures instead)
- Document trigger behavior
- Be careful with cascade triggers
- Test thoroughly (triggers can cause unexpected behavior)
