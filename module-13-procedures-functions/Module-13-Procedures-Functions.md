# Module 13 · Stored Procedures & Functions

Procedures and functions encapsulate reusable SQL logic.

## Key Concepts:
```sql
-- Simple procedure
DELIMITER //
CREATE PROCEDURE get_customer_orders(IN cust_id INT)
BEGIN
  SELECT * FROM orders WHERE customer_id = cust_id;
END //
DELIMITER ;

CALL get_customer_orders(1);

-- Function
DELIMITER //
CREATE FUNCTION calculate_tax(amount DECIMAL(10,2)) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  RETURN amount * 0.08;
END //
DELIMITER ;

SELECT calculate_tax(100);  -- Returns 8.00

-- Procedure with OUT parameter
DELIMITER //
CREATE PROCEDURE count_orders(IN cust_id INT, OUT order_count INT)
BEGIN
  SELECT COUNT(*) INTO order_count FROM orders WHERE customer_id = cust_id;
END //
DELIMITER ;

CALL count_orders(1, @count);
SELECT @count;
```

## Best Practices:
- Use procedures for complex multi-step operations
- Use functions for calculations
- Handle errors with DECLARE...HANDLER
- Document parameters and return values
