# Paired Programming — Transactions

## Challenge: Ticket Booking System — 35 min

**Goal:** Build a robust ticket booking system where two users try to book the same seat. Learn about race conditions, locking, and concurrency!

**Beginner Explanation:** This exercise simulates what happens in real ticket booking websites when thousands of people try to buy the same seats. You'll discover why proper locking is critical!

### Setup (Both Partners Run This)

```sql
DROP TABLE IF EXISTS pp12_seats, pp12_bookings;

CREATE TABLE pp12_seats (
  seat_id INT PRIMARY KEY,
  section VARCHAR(10),
  seat_number VARCHAR(10),
  price DECIMAL(10,2),
  is_available BOOLEAN DEFAULT TRUE
);

CREATE TABLE pp12_bookings (
  booking_id INT AUTO_INCREMENT PRIMARY KEY,
  seat_id INT,
  customer_name VARCHAR(100),
  email VARCHAR(100),
  booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert some seats (only a few available!)
INSERT INTO pp12_seats VALUES 
(1, 'VIP', 'A-101', 150.00, TRUE),
(2, 'VIP', 'A-102', 150.00, TRUE),
(3, 'Regular', 'B-201', 50.00, FALSE);
```

---

### Part 1: Discover the Problem (Without Locking) ❌

**Partner A - Run This First:**
```sql
START TRANSACTION;

-- Check if seat is available (NO LOCKING YET!)
SELECT * FROM pp12_seats 
WHERE seat_id = 1 AND is_available = TRUE;
-- Shows seat is available

-- Simulate thinking time (Partner B will run their query now!)
-- SELECT SLEEP(10);  -- Uncomment this to make the race condition obvious

-- Book the seat
INSERT INTO pp12_bookings (seat_id, customer_name, email)
VALUES (1, 'Alice', 'alice@example.com');

UPDATE pp12_seats SET is_available = FALSE WHERE seat_id = 1;

COMMIT;

SELECT * FROM pp12_bookings;
```

**Partner B - Run This Immediately After Partner A Starts:**
```sql
START TRANSACTION;

-- Check if seat is available (NO LOCKING!)
SELECT * FROM pp12_seats 
WHERE seat_id = 1 AND is_available = TRUE;
-- Shows seat is available! (But Partner A is booking it!)

-- Book the same seat
INSERT INTO pp12_bookings (seat_id, customer_name, email)
VALUES (1, 'Bob', 'bob@example.com');

UPDATE pp12_seats SET is_available = FALSE WHERE seat_id = 1;

COMMIT;

SELECT * FROM pp12_bookings;
```

**What Happened?** 😱
```sql
-- Check the disaster
SELECT * FROM pp12_bookings WHERE seat_id = 1;
-- BOTH Alice and Bob have bookings for seat 1!

SELECT * FROM pp12_seats WHERE seat_id = 1;
-- Only ONE seat, but TWO bookings!
```

**Discuss Together:**
- Why did both bookings succeed?
- What's the race condition?
- What happens in real ticket websites?

---

### Part 2: Fix It With Proper Locking ✅

**First, reset the data:**
```sql
DELETE FROM pp12_bookings;
UPDATE pp12_seats SET is_available = TRUE WHERE seat_id = 1;
```

**Partner A - Fixed Version:**
```sql
START TRANSACTION;

-- Lock the seat while checking availability
SELECT * FROM pp12_seats 
WHERE seat_id = 1 AND is_available = TRUE 
FOR UPDATE;
-- Seat is now LOCKED! Partner B must wait.

-- Simulate thinking time
-- SELECT SLEEP(10);  -- Uncomment to test

-- Book the seat
INSERT INTO pp12_bookings (seat_id, customer_name, email)
VALUES (1, 'Alice', 'alice@example.com');

UPDATE pp12_seats SET is_available = FALSE WHERE seat_id = 1;

COMMIT;  -- This releases the lock!

SELECT * FROM pp12_bookings;
```

**Partner B - Fixed Version (Run Right After Partner A Starts):**
```sql
START TRANSACTION;

-- Try to lock the same seat
SELECT * FROM pp12_seats 
WHERE seat_id = 1 AND is_available = TRUE 
FOR UPDATE;
-- This WAITS until Partner A commits!
-- After waiting, returns 0 rows (seat is now booked)

-- Check if we got a result
-- In MySQL, you'd check row count in application code
-- Let's see what we got:
SELECT COUNT(*) AS seats_available
FROM pp12_seats 
WHERE seat_id = 1 AND is_available = TRUE;
-- Returns 0! Seat is taken.

-- Don't book if no seats available
-- ROLLBACK or just don't insert

ROLLBACK;

SELECT 'Seat already taken!' AS message;
```

**Verify the Fix:** ✅
```sql
-- Check bookings
SELECT * FROM pp12_bookings WHERE seat_id = 1;
-- Only Alice has a booking!

-- Check seat status
SELECT * FROM pp12_seats WHERE seat_id = 1;
-- is_available = FALSE, correctly marked as booked
```

---

### Part 3: Discussion Questions

**Discuss with Your Partner:**

1. **Why FOR UPDATE?**
   - What happens without it?
   - When does Partner B's query start waiting?
   - When is the lock released?

2. **Deadlock Scenarios:**
   - What if Partner A locks Seat 1 then tries to lock Seat 2?
   - And Partner B locks Seat 2 then tries to lock Seat 1?
   - How does MySQL handle this?

3. **Real-World Strategies:**
   - What if a user abandons checkout (never commits)?
   - Should locks have timeouts?
   - How do high-traffic sites handle thousands of concurrent bookings?

4. **Alternative Approaches:**
   - Could you use `UPDATE ... WHERE is_available = TRUE` directly?
   - What about optimistic locking (version numbers)?
   - When would you use each approach?

---

### Bonus Challenge

**Implement a "cart reservation" system:**
- When user adds seat to cart, mark it as "reserved" for 5 minutes
- After 5 minutes, automatically release it
- Hint: Add a `reserved_until` timestamp column

```sql
-- Starter code
ALTER TABLE pp12_seats 
ADD COLUMN reserved_until TIMESTAMP NULL;

-- Partner A: Reserve seat for 5 minutes
UPDATE pp12_seats 
SET reserved_until = DATE_ADD(NOW(), INTERVAL 5 MINUTE)
WHERE seat_id = 2 AND is_available = TRUE 
  AND (reserved_until IS NULL OR reserved_until < NOW());

-- Partner B: Try to reserve same seat
-- Should fail if within 5 minutes!
```

---

### Key Takeaways

- ✅ **Race conditions** happen when two transactions read the same data
- ✅ **`SELECT ... FOR UPDATE`** prevents race conditions by locking rows
- ✅ Locked rows make other transactions **wait** until COMMIT/ROLLBACK
- ✅ Always **check availability AFTER acquiring lock** (might be taken already!)
- ✅ Consider **timeouts** to prevent abandoned locks
- ✅ Understanding concurrency is **critical for real-world applications**! 🎫

