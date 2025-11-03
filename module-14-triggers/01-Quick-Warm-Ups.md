# Quick Warm-Ups — Triggers (5–10 min each)

**Beginner Tip:** Triggers automatically execute on INSERT/UPDATE/DELETE events. BEFORE triggers validate/modify data. AFTER triggers audit/log changes. Use NEW for new values, OLD for previous values!

---

## 1) Simple AFTER INSERT Trigger — 6 min
```sql
DROP TABLE IF EXISTS wu14_users, wu14_audit_log;
CREATE TABLE wu14_users (user_id INT PRIMARY KEY, username VARCHAR(50));
CREATE TABLE wu14_audit_log (log_id INT AUTO_INCREMENT PRIMARY KEY, message VARCHAR(255), logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

DELIMITER //
CREATE TRIGGER tr_user_insert AFTER INSERT ON wu14_users
FOR EACH ROW
BEGIN
  INSERT INTO wu14_audit_log (message) VALUES (CONCAT('New user: ', NEW.username));
END //
DELIMITER ;

INSERT INTO wu14_users VALUES (1, 'alice');
SELECT * FROM wu14_audit_log;
```

---

## 2) BEFORE INSERT Validation — 7 min
```sql
DROP TABLE IF EXISTS wu14_products;
CREATE TABLE wu14_products (product_id INT PRIMARY KEY, name VARCHAR(100), price DECIMAL(10,2));

DELIMITER //
CREATE TRIGGER tr_validate_price BEFORE INSERT ON wu14_products
FOR EACH ROW
BEGIN
  IF NEW.price < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price cannot be negative';
  END IF;
END //
DELIMITER ;

INSERT INTO wu14_products VALUES (1, 'Laptop', 1200);  -- Success
-- INSERT INTO wu14_products VALUES (2, 'Invalid', -10);  -- Error!
```

---

## 3) AFTER UPDATE Trigger — 7 min
```sql
DROP TABLE IF EXISTS wu14_inventory, wu14_inventory_history;
CREATE TABLE wu14_inventory (product_id INT PRIMARY KEY, stock INT);
CREATE TABLE wu14_inventory_history (hist_id INT AUTO_INCREMENT PRIMARY KEY, product_id INT, old_stock INT, new_stock INT, changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

INSERT INTO wu14_inventory VALUES (1, 100);

DELIMITER //
CREATE TRIGGER tr_track_stock_change AFTER UPDATE ON wu14_inventory
FOR EACH ROW
BEGIN
  IF OLD.stock != NEW.stock THEN
    INSERT INTO wu14_inventory_history (product_id, old_stock, new_stock)
    VALUES (NEW.product_id, OLD.stock, NEW.stock);
  END IF;
END //
DELIMITER ;

UPDATE wu14_inventory SET stock = 90 WHERE product_id = 1;
SELECT * FROM wu14_inventory_history;
```

---

## 4) BEFORE UPDATE Validation — 7 min
```sql
DROP TABLE IF EXISTS wu14_accounts;
CREATE TABLE wu14_accounts (account_id INT PRIMARY KEY, balance DECIMAL(10,2));
INSERT INTO wu14_accounts VALUES (1, 1000);

DELIMITER //
CREATE TRIGGER tr_prevent_negative_balance BEFORE UPDATE ON wu14_accounts
FOR EACH ROW
BEGIN
  IF NEW.balance < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Balance cannot be negative';
  END IF;
END //
DELIMITER ;

UPDATE wu14_accounts SET balance = 500 WHERE account_id = 1;  -- Success
-- UPDATE wu14_accounts SET balance = -100 WHERE account_id = 1;  -- Error!
```

---

## 5) AFTER DELETE Trigger — 6 min
```sql
DROP TABLE IF EXISTS wu14_customers, wu14_deleted_customers;
CREATE TABLE wu14_customers (customer_id INT PRIMARY KEY, name VARCHAR(100));
CREATE TABLE wu14_deleted_customers (customer_id INT, name VARCHAR(100), deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

INSERT INTO wu14_customers VALUES (1, 'Alice');

DELIMITER //
CREATE TRIGGER tr_archive_deleted AFTER DELETE ON wu14_customers
FOR EACH ROW
BEGIN
  INSERT INTO wu14_deleted_customers (customer_id, name) VALUES (OLD.customer_id, OLD.name);
END //
DELIMITER ;

DELETE FROM wu14_customers WHERE customer_id = 1;
SELECT * FROM wu14_deleted_customers;
```

---

## 6) Auto-Update Timestamp — 6 min
```sql
DROP TABLE IF EXISTS wu14_posts;
CREATE TABLE wu14_posts (post_id INT PRIMARY KEY, content TEXT, created_at TIMESTAMP, updated_at TIMESTAMP);

DELIMITER //
CREATE TRIGGER tr_set_timestamps BEFORE INSERT ON wu14_posts
FOR EACH ROW
BEGIN
  SET NEW.created_at = NOW();
  SET NEW.updated_at = NOW();
END //

CREATE TRIGGER tr_update_timestamp BEFORE UPDATE ON wu14_posts
FOR EACH ROW
BEGIN
  SET NEW.updated_at = NOW();
END //
DELIMITER ;

INSERT INTO wu14_posts (post_id, content) VALUES (1, 'First post');
SELECT * FROM wu14_posts;
```

---

## 7) Computed Column with Trigger — 7 min
```sql
DROP TABLE IF EXISTS wu14_order_items;
CREATE TABLE wu14_order_items (item_id INT PRIMARY KEY, quantity INT, unit_price DECIMAL(10,2), total DECIMAL(10,2));

DELIMITER //
CREATE TRIGGER tr_calculate_total BEFORE INSERT ON wu14_order_items
FOR EACH ROW
BEGIN
  SET NEW.total = NEW.quantity * NEW.unit_price;
END //

CREATE TRIGGER tr_update_total BEFORE UPDATE ON wu14_order_items
FOR EACH ROW
BEGIN
  SET NEW.total = NEW.quantity * NEW.unit_price;
END //
DELIMITER ;

INSERT INTO wu14_order_items (item_id, quantity, unit_price) VALUES (1, 5, 10.00);
SELECT * FROM wu14_order_items;  -- total = 50.00
```

---

## 8) Multiple Triggers on Same Table — 7 min
```sql
DROP TABLE IF EXISTS wu14_employees;
CREATE TABLE wu14_employees (emp_id INT PRIMARY KEY, salary DECIMAL(10,2), last_modified TIMESTAMP);

DELIMITER //
CREATE TRIGGER tr_emp_validate BEFORE UPDATE ON wu14_employees
FOR EACH ROW
BEGIN
  IF NEW.salary < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary must be positive';
  END IF;
END //

CREATE TRIGGER tr_emp_timestamp BEFORE UPDATE ON wu14_employees
FOR EACH ROW
BEGIN
  SET NEW.last_modified = NOW();
END //
DELIMITER ;

INSERT INTO wu14_employees VALUES (1, 50000, NOW());
UPDATE wu14_employees SET salary = 55000 WHERE emp_id = 1;
SELECT * FROM wu14_employees;
```

---

**Key Takeaways:**
- BEFORE triggers: validate/modify data before save
- AFTER triggers: audit/log after save
- NEW: new values (INSERT, UPDATE)
- OLD: previous values (UPDATE, DELETE)
- SIGNAL: raise custom errors
- Multiple triggers execute in alphabetical order
- Keep triggers simple and fast!

