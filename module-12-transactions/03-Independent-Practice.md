# Independent Practice — Transactions

## Exercise 1: Shopping Cart Checkout (Easy)

**Goal:** Implement a complete checkout process - create order, deduct inventory, clear cart - all in one transaction.

**Beginner Explanation:** When a customer clicks "Place Order", several things must happen together. If ANY step fails, ALL steps should be cancelled!

### Setup
```sql
DROP TABLE IF EXISTS ip12_cart, ip12_inventory, ip12_orders, ip12_order_items;

CREATE TABLE ip12_cart (
  user_id INT, 
  product_id INT, 
  quantity INT
);

CREATE TABLE ip12_inventory (
  product_id INT PRIMARY KEY, 
  stock INT CHECK (stock >= 0)
);

CREATE TABLE ip12_orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY, 
  user_id INT, 
  total DECIMAL(10,2)
);

CREATE TABLE ip12_order_items (
  order_id INT,
  product_id INT,
  quantity INT
);

-- Sample data
INSERT INTO ip12_inventory VALUES (101, 50), (102, 30);
INSERT INTO ip12_cart VALUES (1, 101, 2), (1, 102, 1);
```

**Your Task:** Write a transaction to process checkout for user_id = 1.

### Solution

```sql
START TRANSACTION;

-- Step 1: Lock inventory rows to prevent race conditions
SELECT i.product_id, i.stock, c.quantity
FROM ip12_cart c
JOIN ip12_inventory i ON c.product_id = i.product_id
WHERE c.user_id = 1
FOR UPDATE;

-- Step 2: Calculate total
SELECT @total := SUM(c.quantity * 10.00)  -- Assume $10 per item
FROM ip12_cart c
WHERE c.user_id = 1;

-- Step 3: Create order
INSERT INTO ip12_orders (user_id, total) VALUES (1, @total);
SET @order_id = LAST_INSERT_ID();

-- Step 4: Copy cart items to order
INSERT INTO ip12_order_items (order_id, product_id, quantity)
SELECT @order_id, product_id, quantity
FROM ip12_cart
WHERE user_id = 1;

-- Step 5: Update inventory
UPDATE ip12_inventory i
JOIN ip12_cart c ON i.product_id = c.product_id
SET i.stock = i.stock - c.quantity
WHERE c.user_id = 1;

-- Step 6: Clear cart
DELETE FROM ip12_cart WHERE user_id = 1;

-- Commit everything
COMMIT;

-- Verify results
SELECT * FROM ip12_orders;
SELECT * FROM ip12_order_items;
SELECT * FROM ip12_inventory;
SELECT * FROM ip12_cart WHERE user_id = 1;  -- Should be empty
```

### What You Learned
- ✅ Multi-table transactions (orders, inventory, cart)
- ✅ Using `FOR UPDATE` to prevent race conditions
- ✅ Capturing auto-generated IDs with `LAST_INSERT_ID()`
- ✅ All-or-nothing processing (if ANY step fails, ALL are rolled back)

---

## Exercise 2: Multi-Step Booking (Medium)

**Goal:** Build a hotel booking system: check availability, create reservation, process payment - with savepoints for error handling.

**Beginner Explanation:** Hotel bookings have multiple steps. If payment fails, you want to rollback the payment attempt but might retry with a different card. Savepoints let you undo just the payment without losing the whole reservation!

### Setup
```sql
DROP TABLE IF EXISTS ip12_rooms, ip12_reservations, ip12_payments;

CREATE TABLE ip12_rooms (
  room_id INT PRIMARY KEY,
  room_type VARCHAR(50),
  is_available BOOLEAN DEFAULT TRUE
);

CREATE TABLE ip12_reservations (
  reservation_id INT AUTO_INCREMENT PRIMARY KEY,
  room_id INT,
  guest_name VARCHAR(100),
  check_in DATE,
  check_out DATE
);

CREATE TABLE ip12_payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  reservation_id INT,
  amount DECIMAL(10,2),
  status VARCHAR(20)
);

-- Sample data
INSERT INTO ip12_rooms VALUES 
(201, 'Standard', TRUE),
(202, 'Deluxe', TRUE),
(203, 'Suite', FALSE);
```

**Your Task:** Create a complete booking transaction with payment handling using savepoints.

### Solution

```sql
START TRANSACTION;

-- Step 1: Check and lock available room
SELECT * FROM ip12_rooms 
WHERE room_id = 201 AND is_available = TRUE 
FOR UPDATE;
-- Room is now locked!

-- Step 2: Create reservation
INSERT INTO ip12_reservations (room_id, guest_name, check_in, check_out)
VALUES (201, 'John Doe', '2024-06-01', '2024-06-05');

SET @reservation_id = LAST_INSERT_ID();

-- Step 3: Mark room as unavailable
UPDATE ip12_rooms SET is_available = FALSE WHERE room_id = 201;

-- Step 4: Create savepoint before payment
SAVEPOINT before_payment;

-- Try to process payment (simulated)
INSERT INTO ip12_payments (reservation_id, amount, status)
VALUES (@reservation_id, 400.00, 'pending');

-- Simulate payment processing...
-- Let's say first attempt fails
UPDATE ip12_payments 
SET status = 'failed' 
WHERE reservation_id = @reservation_id;

-- Rollback payment attempt
ROLLBACK TO before_payment;

-- Step 5: Try payment again with different card
SAVEPOINT before_payment_retry;

INSERT INTO ip12_payments (reservation_id, amount, status)
VALUES (@reservation_id, 400.00, 'pending');

-- This time it succeeds!
UPDATE ip12_payments 
SET status = 'success' 
WHERE reservation_id = @reservation_id;

-- Step 6: Commit everything
COMMIT;

-- Verify results
SELECT * FROM ip12_reservations;
SELECT * FROM ip12_payments;
SELECT * FROM ip12_rooms WHERE room_id = 201;
```

### What You Learned
- ✅ Using `FOR UPDATE` to prevent double-booking
- ✅ **Savepoints** for partial rollback (payment retries)
- ✅ Multi-step business logic in one transaction
- ✅ Graceful error handling without losing all work

**Real-World Tip:** In production, you'd integrate with actual payment APIs and use try-catch blocks to handle payment failures automatically!

---

## Exercise 3: Concurrent Access Handling (Hard)

**Goal:** Simulate two users trying to book the last concert seat simultaneously. Use proper locking to ensure only one succeeds!

**Beginner Explanation:** This is the classic "race condition" problem. Without proper locking:
1. User A checks: "1 seat available" ✓
2. User B checks: "1 seat available" ✓
3. Both book the seat!
4. Now 2 people have tickets for 1 seat! 😱

### Setup
```sql
DROP TABLE IF EXISTS ip12_concert_seats, ip12_bookings;

CREATE TABLE ip12_concert_seats (
  seat_id INT PRIMARY KEY,
  seat_number VARCHAR(10),
  is_booked BOOLEAN DEFAULT FALSE
);

CREATE TABLE ip12_bookings (
  booking_id INT AUTO_INCREMENT PRIMARY KEY,
  seat_id INT,
  customer_name VARCHAR(100),
  booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Only ONE seat available!
INSERT INTO ip12_concert_seats VALUES 
(1, 'A-101', FALSE);
```

**Your Task:** Write two concurrent transactions (run in separate sessions) that properly handle the race condition.

### Solution - Session A (First User)

```sql
START TRANSACTION;

-- Check if seat is available AND lock it
SELECT * FROM ip12_concert_seats 
WHERE seat_id = 1 AND is_booked = FALSE 
FOR UPDATE;
-- Returns the seat (it's available and now LOCKED)

-- Simulate user thinking time
-- SELECT SLEEP(5);  -- Uncomment to test

-- Book the seat
INSERT INTO ip12_bookings (seat_id, customer_name)
VALUES (1, 'Alice');

-- Mark seat as booked
UPDATE ip12_concert_seats 
SET is_booked = TRUE 
WHERE seat_id = 1;

-- Commit (releases the lock)
COMMIT;

-- Verify
SELECT * FROM ip12_bookings;
SELECT * FROM ip12_concert_seats;
```

### Solution - Session B (Second User - run immediately after Session A starts)

```sql
START TRANSACTION;

-- Try to check and lock the same seat
SELECT * FROM ip12_concert_seats 
WHERE seat_id = 1 AND is_booked = FALSE 
FOR UPDATE;
-- This will WAIT until Session A commits!

-- After Session A commits, this returns 0 rows (seat is now booked)
-- So this query returns empty result

-- Check if we got the seat
-- Since the SELECT returned 0 rows, we know it's booked

-- Try to book anyway (this will fail gracefully)
INSERT INTO ip12_bookings (seat_id, customer_name)
VALUES (1, 'Bob');

UPDATE ip12_concert_seats 
SET is_booked = TRUE 
WHERE seat_id = 1;
-- These statements execute but don't change anything (WHERE conditions don't match)

COMMIT;

-- Verify - Bob didn't get the seat
SELECT * FROM ip12_bookings;
SELECT * FROM ip12_concert_seats;
```

### Better Solution - With Error Checking

**Session B (Improved):**
```sql
START TRANSACTION;

-- Try to lock available seat
SELECT * FROM ip12_concert_seats 
WHERE seat_id = 1 AND is_booked = FALSE 
FOR UPDATE;

-- In application code, check if query returned rows
-- If 0 rows, the seat is already booked!

-- Let's check with COUNT
SELECT COUNT(*) INTO @available
FROM ip12_concert_seats 
WHERE seat_id = 1 AND is_booked = FALSE;

-- If available, book it
IF @available > 0 THEN
  INSERT INTO ip12_bookings (seat_id, customer_name)
  VALUES (1, 'Bob');
  
  UPDATE ip12_concert_seats 
  SET is_booked = TRUE 
  WHERE seat_id = 1;
  
  SELECT 'Booking successful!' AS result;
ELSE
  SELECT 'Sorry, seat already booked!' AS result;
END IF;

COMMIT;
```

### What You Learned
- ✅ **`SELECT ... FOR UPDATE`** prevents race conditions
- ✅ Proper locking ensures **only one user gets the last seat**
- ✅ Second user **waits** until first transaction completes
- ✅ Always **check if seat is still available** after lock is acquired
- ✅ Real-world concurrency control!

**Test This:** Open two MySQL sessions and run Session A and B simultaneously. Session B will wait for Session A to finish. Only Alice gets the seat! 🎫

**Without FOR UPDATE:** Both sessions would see "seat available" and both would book it. Disaster! 🚨

