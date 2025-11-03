# Guided Step-by-Step — Procedures & Functions

## Activity 1: Order Total Calculator — 18 min

### Setup
```sql
DROP TABLE IF EXISTS gs13_order_items;
CREATE TABLE gs13_order_items (
  order_id INT,
  product_name VARCHAR(100),
  quantity INT,
  unit_price DECIMAL(10,2)
);
INSERT INTO gs13_order_items VALUES
(1, 'Laptop', 1, 1200.00),
(1, 'Mouse', 2, 25.00),
(2, 'Keyboard', 1, 75.00);
```

### Steps

**Step 1:** Create function to calculate tax
```sql
DROP FUNCTION IF EXISTS gs13_calculate_tax;

DELIMITER //
CREATE FUNCTION gs13_calculate_tax(amount DECIMAL(10,2), rate DECIMAL(4,3))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  RETURN ROUND(amount * rate, 2);
END //
DELIMITER ;

SELECT gs13_calculate_tax(100, 0.08) AS tax;
```

**Step 2:** Create procedure to calculate order total
```sql
DROP PROCEDURE IF EXISTS gs13_order_total;

DELIMITER //
CREATE PROCEDURE gs13_order_total(
  IN p_order_id INT,
  OUT p_subtotal DECIMAL(10,2),
  OUT p_tax DECIMAL(10,2),
  OUT p_total DECIMAL(10,2)
)
BEGIN
  SELECT SUM(quantity * unit_price) INTO p_subtotal
  FROM gs13_order_items
  WHERE order_id = p_order_id;
  
  SET p_tax = gs13_calculate_tax(p_subtotal, 0.08);
  SET p_total = p_subtotal + p_tax;
END //
DELIMITER ;
```

**Step 3:** Test procedure
```sql
CALL gs13_order_total(1, @subtotal, @tax, @total);
SELECT @subtotal, @tax, @total;
```

### Key Takeaways
- Functions can be called from procedures
- Use OUT parameters to return multiple values
- DETERMINISTIC for consistent results

---

## Activity 2: Customer Management Procedures — 20 min

### Setup
```sql
DROP TABLE IF EXISTS gs13_customers;
CREATE TABLE gs13_customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(100) UNIQUE,
  name VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Steps

**Step 1:** Create procedure to add customer with validation
```sql
DROP PROCEDURE IF EXISTS gs13_add_customer;

DELIMITER //
CREATE PROCEDURE gs13_add_customer(
  IN p_email VARCHAR(100),
  IN p_name VARCHAR(100),
  OUT p_customer_id INT,
  OUT p_message VARCHAR(255)
)
BEGIN
  DECLARE existing_count INT;
  
  SELECT COUNT(*) INTO existing_count
  FROM gs13_customers WHERE email = p_email;
  
  IF existing_count > 0 THEN
    SET p_customer_id = 0;
    SET p_message = 'Email already exists';
  ELSE
    INSERT INTO gs13_customers (email, name) VALUES (p_email, p_name);
    SET p_customer_id = LAST_INSERT_ID();
    SET p_message = 'Customer added successfully';
  END IF;
END //
DELIMITER ;
```

**Step 2:** Test procedure
```sql
CALL gs13_add_customer('alice@email.com', 'Alice', @id, @msg);
SELECT @id AS customer_id, @msg AS message;

-- Try duplicate
CALL gs13_add_customer('alice@email.com', 'Alice2', @id, @msg);
SELECT @id, @msg;
```

### Key Takeaways
- Use variables to store intermediate results
- Implement business logic validation
- Return meaningful messages
- Handle errors gracefully

