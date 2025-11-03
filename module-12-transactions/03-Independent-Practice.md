# Independent Practice — Transactions

## Exercise 1: Shopping Cart Checkout (Easy) — 20 min
Implement checkout: create order, deduct inventory, clear cart - all in transaction.

```sql
CREATE TABLE ip12_cart (user_id INT, product_id INT, quantity INT);
CREATE TABLE ip12_inventory (product_id INT PRIMARY KEY, stock INT);
CREATE TABLE ip12_orders (order_id INT AUTO_INCREMENT PRIMARY KEY, user_id INT, total DECIMAL(10,2));

-- Your task: Write transaction to process checkout for user_id = 1
```

**Solution:** Use START TRANSACTION, lock inventory with FOR UPDATE, create order, update inventory, COMMIT.

---

## Exercise 2: Multi-Step Booking (Medium) — 30 min
Hotel booking system: check availability, create reservation, charge payment - with rollback on payment failure.

**Requirements:**
- Lock room to prevent double-booking
- Use savepoints for payment attempts
- Handle errors gracefully

---

## Exercise 3: Concurrent Access Handling (Hard) — 40 min
Simulate two users trying to book last seat simultaneously. Implement proper locking and error handling.

**Test:** Run two transactions in separate sessions, verify only one succeeds.

