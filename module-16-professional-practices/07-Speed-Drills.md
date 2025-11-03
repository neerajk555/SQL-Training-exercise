# Speed Drills — Professional Practices

## Drill 1: Fix Naming (30 seconds)
Rename: `SELECT t.a, t.b FROM t WHERE t.c = 1`
```sql
SELECT 
  users.name,
  users.email
FROM users
WHERE users.status = 'active';
```

---

## Drill 2: Add Parameter Validation (45 seconds)
```sql
CREATE PROCEDURE update_stock(p_id INT, p_qty INT)
BEGIN
  IF p_qty < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid quantity';
  END IF;
  UPDATE products SET stock = p_qty WHERE id = p_id;
END;
```

---

## Drill 3: Secure This Query (30 seconds)
Bad: `"SELECT * FROM users WHERE id = " + userId`  
Good: Use parameterized query with placeholder `?`

---

## Drill 4: Add Comments (45 seconds)
```sql
-- Calculate monthly revenue by product category
SELECT 
  category,
  SUM(amount) AS revenue
FROM orders
WHERE order_date >= '2024-01-01'
GROUP BY category;
```

---

## Drill 5: Transaction Safety (60 seconds)
```sql
START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
```

---

## Drill 6: Add Index (30 seconds)
```sql
CREATE INDEX idx_orders_user_date ON orders(user_id, order_date);
```

---

## Drill 7: Error Handler (45 seconds)
```sql
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
  ROLLBACK;
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Operation failed';
END;
```

**Key Takeaways:** Speed in professional practices comes from consistent patterns and templates.

