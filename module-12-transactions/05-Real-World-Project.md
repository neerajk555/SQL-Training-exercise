# Real-World Project — Transaction-Safe Order System

## 📋 Before You Start

### Learning Objectives
By completing this real-world project, you will:
- Apply transaction management to multi-step operations
- Practice COMMIT/ROLLBACK for data integrity
- Work with realistic order processing scenarios
- Build stored procedures with error handling
- Develop skills for handling concurrent transactions

### Project Approach
**Time Allocation (60-90 minutes):**
- 📖 **10 min**: Read checkout requirements, identify transaction boundaries
- 🔧 **10 min**: Run setup, understand order flow
- 💻 **40-60 min**: Build checkout procedure with transactions
- ✅ **10 min**: Test success and failure scenarios

**Success Tips:**
- ✅ Use START TRANSACTION for multi-step operations
- ✅ COMMIT only when all steps succeed
- ✅ ROLLBACK immediately on any error
- ✅ Test both success and failure paths
- ✅ Use locking to prevent race conditions

---

## Project: Build Complete E-Commerce Checkout

**Requirements:**
1. Validate cart items exist and in stock
2. Calculate totals (subtotal, tax, shipping)
3. Create order record
4. Deduct inventory for each item
5. Process payment (simulate)
6. Clear shopping cart
7. Handle errors at each step with proper rollback

**Deliverables:**
- Stored procedure for checkout process
- Error handling for: out of stock, payment failure, invalid data
- Transaction log table tracking all attempts
- Test cases for success and failure scenarios

**Evaluation:**
- ✅ All-or-nothing guarantee
- ✅ Proper locking to prevent overselling
- ✅ Detailed error messages
- ✅ Rollback on any failure

---

## Setup

### Database Schema

```sql
-- Clean up previous runs
DROP TABLE IF EXISTS rw12_cart, rw12_products, rw12_orders, rw12_order_items, rw12_payments, rw12_transaction_log;

-- Products/Inventory Table
CREATE TABLE rw12_products (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(100) NOT NULL,
  price DECIMAL(10,2) NOT NULL CHECK (price > 0),
  stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
  is_active BOOLEAN DEFAULT TRUE
);

-- Shopping Cart Table
CREATE TABLE rw12_cart (
  cart_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES rw12_products(product_id)
);

-- Orders Table
CREATE TABLE rw12_orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  tax DECIMAL(10,2) NOT NULL,
  shipping DECIMAL(10,2) NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  order_status VARCHAR(20) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order Items Table
CREATE TABLE rw12_order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES rw12_orders(order_id),
  FOREIGN KEY (product_id) REFERENCES rw12_products(product_id)
);

-- Payments Table
CREATE TABLE rw12_payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(50),
  payment_status VARCHAR(20) DEFAULT 'pending',
  processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES rw12_orders(order_id)
);

-- Transaction Log Table (for audit trail)
CREATE TABLE rw12_transaction_log (
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  order_id INT,
  operation VARCHAR(50),
  status VARCHAR(20),
  error_message VARCHAR(255),
  logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample Product Data
INSERT INTO rw12_products (product_id, product_name, price, stock_quantity) VALUES
(1, 'Laptop', 999.99, 10),
(2, 'Wireless Mouse', 29.99, 50),
(3, 'USB-C Cable', 15.99, 100),
(4, 'Laptop Stand', 49.99, 25),
(5, 'Webcam HD', 79.99, 5);

-- Sample Cart Data (User 101 has items in cart)
INSERT INTO rw12_cart (user_id, product_id, quantity) VALUES
(101, 1, 1),   -- 1 Laptop
(101, 2, 2),   -- 2 Mice
(101, 3, 3);   -- 3 Cables

-- Sample Cart Data (User 102 has items in cart)
INSERT INTO rw12_cart (user_id, product_id, quantity) VALUES
(102, 5, 1);   -- 1 Webcam
```

---

## Implementation Guide

### Part 1: Build the Checkout Procedure

Create a stored procedure that processes checkout with full transaction safety.

```sql
DELIMITER //

CREATE PROCEDURE ProcessCheckout(
  IN p_user_id INT,
  IN p_payment_method VARCHAR(50),
  OUT p_order_id INT,
  OUT p_status VARCHAR(50),
  OUT p_message VARCHAR(255)
)
BEGIN
  DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;
  DECLARE v_tax DECIMAL(10,2) DEFAULT 0;
  DECLARE v_shipping DECIMAL(10,2) DEFAULT 10.00;
  DECLARE v_total DECIMAL(10,2) DEFAULT 0;
  DECLARE v_cart_count INT DEFAULT 0;
  DECLARE v_stock_check INT DEFAULT 0;
  DECLARE v_payment_success BOOLEAN DEFAULT FALSE;
  
  -- Error handling
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    -- Rollback on any error
    ROLLBACK;
    SET p_status = 'error';
    SET p_message = 'Transaction failed - all changes rolled back';
    
    -- Log the failure
    INSERT INTO rw12_transaction_log (user_id, operation, status, error_message)
    VALUES (p_user_id, 'checkout', 'failed', 'SQL Exception occurred');
  END;
  
  -- Start transaction
  START TRANSACTION;
  
  -- Log transaction start
  INSERT INTO rw12_transaction_log (user_id, operation, status)
  VALUES (p_user_id, 'checkout', 'started');
  
  -- Step 1: Validate cart is not empty
  SELECT COUNT(*) INTO v_cart_count
  FROM rw12_cart
  WHERE user_id = p_user_id;
  
  IF v_cart_count = 0 THEN
    ROLLBACK;
    SET p_status = 'error';
    SET p_message = 'Cart is empty';
    INSERT INTO rw12_transaction_log (user_id, operation, status, error_message)
    VALUES (p_user_id, 'checkout', 'failed', 'Empty cart');
    LEAVE ProcessCheckout;
  END IF;
  
  -- Step 2: Lock products and check stock availability
  SELECT COUNT(*) INTO v_stock_check
  FROM rw12_cart c
  JOIN rw12_products p ON c.product_id = p.product_id
  WHERE c.user_id = p_user_id
    AND p.stock_quantity >= c.quantity
    AND p.is_active = TRUE
  FOR UPDATE;
  
  IF v_stock_check < v_cart_count THEN
    ROLLBACK;
    SET p_status = 'error';
    SET p_message = 'One or more items out of stock or inactive';
    INSERT INTO rw12_transaction_log (user_id, operation, status, error_message)
    VALUES (p_user_id, 'checkout', 'failed', 'Insufficient stock');
    LEAVE ProcessCheckout;
  END IF;
  
  -- Step 3: Calculate totals
  SELECT SUM(c.quantity * p.price) INTO v_subtotal
  FROM rw12_cart c
  JOIN rw12_products p ON c.product_id = p.product_id
  WHERE c.user_id = p_user_id;
  
  SET v_tax = v_subtotal * 0.08;  -- 8% tax
  SET v_total = v_subtotal + v_tax + v_shipping;
  
  -- Step 4: Create order record
  INSERT INTO rw12_orders (user_id, subtotal, tax, shipping, total, order_status)
  VALUES (p_user_id, v_subtotal, v_tax, v_shipping, v_total, 'pending');
  
  SET p_order_id = LAST_INSERT_ID();
  
  -- Step 5: Copy cart items to order_items
  INSERT INTO rw12_order_items (order_id, product_id, quantity, unit_price)
  SELECT p_order_id, c.product_id, c.quantity, p.price
  FROM rw12_cart c
  JOIN rw12_products p ON c.product_id = p.product_id
  WHERE c.user_id = p_user_id;
  
  -- Step 6: Deduct inventory
  UPDATE rw12_products p
  JOIN rw12_cart c ON p.product_id = c.product_id
  SET p.stock_quantity = p.stock_quantity - c.quantity
  WHERE c.user_id = p_user_id;
  
  -- Step 7: Simulate payment processing
  -- In real world, this would call a payment gateway API
  IF v_total > 0 AND p_payment_method IS NOT NULL THEN
    -- Simulate 90% success rate
    SET v_payment_success = (RAND() > 0.1);
    
    IF v_payment_success THEN
      INSERT INTO rw12_payments (order_id, amount, payment_method, payment_status)
      VALUES (p_order_id, v_total, p_payment_method, 'completed');
      
      UPDATE rw12_orders 
      SET order_status = 'confirmed' 
      WHERE order_id = p_order_id;
    ELSE
      -- Payment failed - rollback everything
      ROLLBACK;
      SET p_status = 'error';
      SET p_message = 'Payment processing failed';
      INSERT INTO rw12_transaction_log (user_id, order_id, operation, status, error_message)
      VALUES (p_user_id, p_order_id, 'checkout', 'failed', 'Payment declined');
      LEAVE ProcessCheckout;
    END IF;
  END IF;
  
  -- Step 8: Clear cart
  DELETE FROM rw12_cart WHERE user_id = p_user_id;
  
  -- Step 9: Commit transaction
  COMMIT;
  
  -- Success!
  SET p_status = 'success';
  SET p_message = CONCAT('Order #', p_order_id, ' created successfully. Total: $', v_total);
  
  INSERT INTO rw12_transaction_log (user_id, order_id, operation, status)
  VALUES (p_user_id, p_order_id, 'checkout', 'success');
  
END //

DELIMITER ;
```

---

## Testing Scenarios

### Test Case 1: Successful Checkout

```sql
-- Test successful checkout for user 101
CALL ProcessCheckout(101, 'credit_card', @order_id, @status, @message);

-- Check results
SELECT @order_id AS OrderID, @status AS Status, @message AS Message;

-- Verify order was created
SELECT * FROM rw12_orders WHERE order_id = @order_id;

-- Verify order items
SELECT * FROM rw12_order_items WHERE order_id = @order_id;

-- Verify inventory was deducted
SELECT product_id, product_name, stock_quantity 
FROM rw12_products 
WHERE product_id IN (1, 2, 3);

-- Verify payment record
SELECT * FROM rw12_payments WHERE order_id = @order_id;

-- Verify cart was cleared
SELECT * FROM rw12_cart WHERE user_id = 101;

-- Check transaction log
SELECT * FROM rw12_transaction_log WHERE user_id = 101 ORDER BY logged_at DESC;
```

**Expected Results:**
- ✅ Order created with status 'confirmed'
- ✅ Order items match cart contents
- ✅ Inventory reduced by order quantities
- ✅ Payment record with 'completed' status
- ✅ Cart empty for user 101
- ✅ Transaction log shows 'success'

---

### Test Case 2: Empty Cart Error

```sql
-- Try checkout with empty cart
CALL ProcessCheckout(999, 'credit_card', @order_id, @status, @message);

SELECT @status AS Status, @message AS Message;
-- Expected: Status = 'error', Message = 'Cart is empty'

-- Verify no order was created
SELECT COUNT(*) AS OrderCount FROM rw12_orders WHERE user_id = 999;
-- Expected: 0

-- Check error logged
SELECT * FROM rw12_transaction_log WHERE user_id = 999;
-- Expected: Shows 'failed' with 'Empty cart' message
```

---

### Test Case 3: Insufficient Stock Error

```sql
-- Add item to cart with quantity exceeding stock
INSERT INTO rw12_cart (user_id, product_id, quantity) VALUES (103, 5, 100);
-- Product 5 (Webcam) only has 5 in stock, but requesting 100

-- Try checkout
CALL ProcessCheckout(103, 'credit_card', @order_id, @status, @message);

SELECT @status AS Status, @message AS Message;
-- Expected: Status = 'error', Message = 'One or more items out of stock or inactive'

-- Verify inventory unchanged
SELECT product_id, stock_quantity FROM rw12_products WHERE product_id = 5;
-- Expected: Still shows 5 (or 4 if user 102 checked out earlier)

-- Verify cart still has items (not cleared due to rollback)
SELECT * FROM rw12_cart WHERE user_id = 103;
-- Expected: Cart item still exists

-- Clean up test data
DELETE FROM rw12_cart WHERE user_id = 103;
```

---

### Test Case 4: Concurrent Checkout (Race Condition Test)

This requires two database sessions running simultaneously.

**Session 1:**
```sql
START TRANSACTION;

-- Simulate user 201 checking out last webcam
INSERT INTO rw12_cart (user_id, product_id, quantity) VALUES (201, 5, 1);

-- Check stock (should see 1 available)
SELECT stock_quantity FROM rw12_products WHERE product_id = 5;

-- Pause here (let Session 2 start)
SELECT SLEEP(10);

-- Complete checkout
CALL ProcessCheckout(201, 'credit_card', @order_id, @status, @message);
SELECT @status, @message;

COMMIT;
```

**Session 2 (run immediately after Session 1 starts):**
```sql
START TRANSACTION;

-- Simulate user 202 also trying to get last webcam
INSERT INTO rw12_cart (user_id, product_id, quantity) VALUES (202, 5, 1);

-- Try checkout (will wait for Session 1's lock)
CALL ProcessCheckout(202, 'credit_card', @order_id, @status, @message);
SELECT @status, @message;
-- Expected: One will succeed, one will fail with 'out of stock'

COMMIT;
```

**Verify Race Condition Handled:**
```sql
-- Check final webcam stock
SELECT stock_quantity FROM rw12_products WHERE product_id = 5;
-- Expected: 0 (only one user got it)

-- Check orders
SELECT order_id, user_id, order_status FROM rw12_orders WHERE user_id IN (201, 202);
-- Expected: Only one order exists

-- Check who won
SELECT * FROM rw12_transaction_log WHERE user_id IN (201, 202) ORDER BY logged_at;
-- Expected: One success, one failure
```

---

### Test Case 5: Payment Failure Rollback

Since payment has simulated randomness, we'll test the rollback logic by modifying the procedure temporarily.

```sql
-- Add cart for user 104
INSERT INTO rw12_cart (user_id, product_id, quantity) VALUES (104, 4, 1);

-- Check inventory before
SELECT stock_quantity FROM rw12_products WHERE product_id = 4;

-- Run checkout multiple times until payment fails
-- (about 1 in 10 should fail due to 10% failure rate)
CALL ProcessCheckout(104, 'credit_card', @order_id, @status, @message);
SELECT @order_id, @status, @message;

-- If payment failed, verify rollback:
IF @status = 'error' THEN
  -- Verify no order exists
  SELECT COUNT(*) FROM rw12_orders WHERE order_id = @order_id;
  -- Expected: 0 or order with 'pending' status
  
  -- Verify inventory unchanged
  SELECT stock_quantity FROM rw12_products WHERE product_id = 4;
  -- Expected: Same as before
  
  -- Verify cart still has items
  SELECT * FROM rw12_cart WHERE user_id = 104;
  -- Expected: Item still in cart (not cleared)
END IF;
```

---

## Extension Challenges

### Challenge 1: Add Discount Codes
Add a `discount_codes` table and modify the procedure to apply discount percentages.

```sql
CREATE TABLE rw12_discount_codes (
  code VARCHAR(20) PRIMARY KEY,
  discount_percent DECIMAL(5,2),
  is_active BOOLEAN DEFAULT TRUE
);

INSERT INTO rw12_discount_codes VALUES ('SAVE10', 10.00, TRUE);

-- Modify procedure signature to accept discount code
-- ALTER PROCEDURE ProcessCheckout...
```

### Challenge 2: Stock Reservation System
Implement a temporary reservation that holds stock for 10 minutes while user completes checkout.

```sql
CREATE TABLE rw12_stock_reservations (
  reservation_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  product_id INT,
  quantity INT,
  reserved_until TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE
);

-- Add logic to reserve stock when items added to cart
-- Auto-release after 10 minutes
```

### Challenge 3: Add Retry Logic for Payment Failures
Allow 3 payment retry attempts before final failure.

### Challenge 4: Implement Savepoints for Partial Success
If payment fails but inventory was already deducted, use savepoint to rollback only the payment portion and mark order as "payment_pending".

---

## Key Takeaways

✅ **Transactions ensure atomicity** - all steps succeed or all fail together  
✅ **Locking prevents race conditions** - `FOR UPDATE` ensures no double-booking  
✅ **Error handlers provide safety** - automatic rollback on exceptions  
✅ **Logging provides audit trail** - track all attempts for debugging  
✅ **Testing validates correctness** - must test both success and failure paths  
✅ **Real-world systems are complex** - payments, inventory, and orders must stay synchronized  

**Production Considerations:**
- Add connection pool timeout handling
- Implement idempotency (prevent duplicate orders)
- Add distributed transaction support for microservices
- Monitor long-running transactions
- Implement automatic retry with exponential backoff
- Add comprehensive error codes and user-friendly messages


