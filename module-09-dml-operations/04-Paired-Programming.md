# Paired Programming: Order Fulfillment System (30–40 min)

**Roles**
- **Driver**: Types SQL, verbalizes approach and safety checks
- **Navigator**: Reviews logic, asks questions about WHERE clauses, checks affected rows
- **Switch roles** after each part (A → B → C)

**Critical Reminders:**
- ⚠️ ALWAYS use WHERE with UPDATE/DELETE
- ⚠️ Test with SELECT first before UPDATE/DELETE
- ⚠️ Use transactions for safety (START TRANSACTION, COMMIT, ROLLBACK)
- ⚠️ Verify affected row count after each operation

---

## Schema (3 tables; DML focus)

```sql
-- Products table
DROP TABLE IF EXISTS pp9_products;
CREATE TABLE pp9_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    stock_quantity INT,
    price DECIMAL(8,2)
);
INSERT INTO pp9_products VALUES
(101, 'Laptop', 50, 1200.00),
(102, 'Mouse', 200, 25.00),
(103, 'Keyboard', 150, 75.00),
(104, 'Monitor', 75, 300.00),
(105, 'Webcam', 100, 89.99);

-- Orders table
DROP TABLE IF EXISTS pp9_orders;
CREATE TABLE pp9_orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    order_date DATE,
    status VARCHAR(20),
    total_amount DECIMAL(10,2)
);
INSERT INTO pp9_orders VALUES
(201, 'Alice Johnson', '2025-03-01', 'pending', 1275.00),
(202, 'Bob Smith', '2025-03-02', 'pending', 100.00),
(203, 'Carol White', '2025-03-03', 'processing', 1500.00),
(204, 'David Lee', '2025-03-04', 'pending', 89.99),
(205, 'Eve Brown', '2025-03-05', 'shipped', 375.00);

-- Order items (which products are in each order)
DROP TABLE IF EXISTS pp9_order_items;
CREATE TABLE pp9_order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT
);
INSERT INTO pp9_order_items VALUES
(1, 201, 101, 1),  -- Order 201: 1 Laptop
(2, 201, 102, 3),  -- Order 201: 3 Mice
(3, 202, 103, 1),  -- Order 202: 1 Keyboard
(4, 202, 102, 1),  -- Order 202: 1 Mouse
(5, 203, 101, 1),  -- Order 203: 1 Laptop
(6, 203, 104, 1),  -- Order 203: 1 Monitor
(7, 204, 105, 1),  -- Order 204: 1 Webcam
(8, 205, 103, 5);  -- Order 205: 5 Keyboards
```

---

## Part A (Driver 1): Batch Insert New Products

**Task:** The warehouse just received 4 new products. Insert them in a **single INSERT statement**.

**New Products:**
- USB Hub | 180 units | $34.99
- Desk Lamp | 150 units | $29.99
- Mouse Pad | 300 units | $9.99
- HDMI Cable | 250 units | $12.50

**Requirements:**
- Use ONE INSERT statement with multiple value sets
- Let product_id auto-generate (start after 105)
- Verify 4 rows inserted

**Edge cases to discuss:**
- What if product_id wasn't auto-increment?
- What happens if you forget a column?
- How to handle duplicate product names?

<details>
<summary>💡 Solution</summary>

```sql
-- First, modify table to add AUTO_INCREMENT (setup fix)
ALTER TABLE pp9_products MODIFY product_id INT AUTO_INCREMENT;

-- Insert 4 products in one statement
INSERT INTO pp9_products (product_name, stock_quantity, price)
VALUES 
    ('USB Hub', 180, 34.99),
    ('Desk Lamp', 150, 29.99),
    ('Mouse Pad', 300, 9.99),
    ('HDMI Cable', 250, 12.50);

-- Verify insertion
SELECT * FROM pp9_products WHERE product_id > 105;
```

**Expected output:** 4 rows inserted, IDs 106-109

**Discussion points:**
- Multiple VALUES sets are more efficient than separate INSERTs
- AUTO_INCREMENT handles ID generation
- Always verify with SELECT after insertion
</details>

---

## Part B (Driver 2): Update Order Status to Processing

**Task:** All 'pending' orders need to move to 'processing' status. Use UPDATE with proper safety checks.

**Requirements:**
- Update ONLY orders with status = 'pending'
- Change status to 'processing'
- Use a transaction for safety
- Verify affected rows before committing

**Safety checklist:**
1. Write SELECT first to see affected rows
2. Wrap in transaction
3. Execute UPDATE
4. Verify row count
5. COMMIT if correct, ROLLBACK if wrong

<details>
<summary>💡 Solution</summary>

```sql
-- Step 1: Test SELECT first to see which rows will be affected
SELECT order_id, customer_name, status
FROM pp9_orders
WHERE status = 'pending';
-- Should show orders 201, 202, 204

-- Step 2: Use transaction for safety
START TRANSACTION;

-- Step 3: Execute UPDATE
UPDATE pp9_orders
SET status = 'processing'
WHERE status = 'pending';

-- Step 4: Verify the change
SELECT order_id, customer_name, status
FROM pp9_orders
WHERE status = 'processing';
-- Should show 201, 202, 203, 204 (3 new + 1 existing)

-- Step 5: Check affected rows message (should say "3 rows affected")
-- If correct, commit; if wrong, rollback

COMMIT;  -- Or ROLLBACK if something's wrong
```

**Expected output:** 3 rows updated (orders 201, 202, 204)

**Discussion points:**
- Always test with SELECT before UPDATE
- Transaction allows rollback if mistake
- WHERE clause is CRITICAL (without it, ALL rows update!)
- Check "rows affected" message
</details>

---

## Part C (Driver 1): Archive Old Shipped Orders

**Task:** Create an archive table and move all 'shipped' orders from March 1-3, 2025 into it. Then delete those orders from the main table.

**Requirements:**
- Create `pp9_orders_archive` table (same structure as pp9_orders)
- Copy shipped orders from March 1-3 using INSERT...SELECT
- Delete the archived orders from pp9_orders
- Use transaction for the entire operation

**Multi-step safety:**
- Archive first (INSERT...SELECT)
- Verify archive has correct data
- Then delete from main table
- All in one transaction

<details>
<summary>💡 Solution</summary>

```sql
-- Step 1: Create archive table
DROP TABLE IF EXISTS pp9_orders_archive;
CREATE TABLE pp9_orders_archive (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    order_date DATE,
    status VARCHAR(20),
    total_amount DECIMAL(10,2),
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Test SELECT to see what will be archived
SELECT *
FROM pp9_orders
WHERE status = 'shipped'
  AND order_date BETWEEN '2025-03-01' AND '2025-03-03';
-- Should show any shipped orders in that date range

-- Step 3: Use transaction for safety
START TRANSACTION;

-- Step 4: Copy to archive using INSERT...SELECT
INSERT INTO pp9_orders_archive (order_id, customer_name, order_date, status, total_amount)
SELECT order_id, customer_name, order_date, status, total_amount
FROM pp9_orders
WHERE status = 'shipped'
  AND order_date BETWEEN '2025-03-01' AND '2025-03-03';

-- Step 5: Verify archive contents
SELECT * FROM pp9_orders_archive;

-- Step 6: Delete from main table (ONLY if archive looks correct!)
DELETE FROM pp9_orders
WHERE status = 'shipped'
  AND order_date BETWEEN '2025-03-01' AND '2025-03-03';

-- Step 7: Verify main table
SELECT * FROM pp9_orders WHERE status = 'shipped';

-- Step 8: If everything looks good, COMMIT
COMMIT;  -- Or ROLLBACK if something's wrong
```

**Expected output:** 
- Orders meeting criteria moved to archive
- Those orders removed from main table
- All other orders remain untouched

**Discussion points:**
- INSERT...SELECT copies data efficiently
- Archive-then-delete pattern is safer than just DELETE
- Transaction ensures both operations succeed together
- Consider adding archived_at timestamp
- In production, might use soft deletes instead
</details>

---

## Role-Switching Points

After each part:
1. **Switch Driver/Navigator roles**
2. **Brief explanation**: New driver explains the solution
3. **Alternative approaches**: Discuss other ways to solve it
4. **Safety discussion**: What could go wrong? How to prevent?

---

## Collaboration Tips

**Navigator questions to ask:**
- "Did we test with SELECT first?"
- "What's our WHERE clause? Will it affect the right rows?"
- "Are we using a transaction?"
- "How many rows should be affected?"
- "What happens if we forget the WHERE?"

**Driver narration:**
- "First I'll SELECT to see which rows..."
- "Starting transaction for safety..."
- "Now UPDATE with WHERE status = 'pending'..."
- "Checking affected rows: should be 3..."
- "Looks good, committing..."

**Both partners:**
- Read error messages aloud
- Verify row counts together
- Discuss what could go wrong
- Practice the mantra: "SELECT before UPDATE/DELETE"

---

## Extended Challenge (If Time Permits)

**Scenario:** Reduce inventory after orders ship. For order 205 (5 Keyboards), decrease the keyboard stock by 5.

**Task:** Write an UPDATE that:
1. Reduces `stock_quantity` in pp9_products
2. Only for product_id 103 (Keyboard)
3. Decreases by exactly 5 units
4. Uses transaction safety

<details>
<summary>💡 Solution</summary>

```sql
-- Test current stock
SELECT product_id, product_name, stock_quantity
FROM pp9_products
WHERE product_id = 103;
-- Should show 150 keyboards

START TRANSACTION;

-- Decrease stock
UPDATE pp9_products
SET stock_quantity = stock_quantity - 5
WHERE product_id = 103;

-- Verify new stock
SELECT product_id, product_name, stock_quantity
FROM pp9_products
WHERE product_id = 103;
-- Should show 145 keyboards

COMMIT;
```

**Advanced:** How would you update stock for ALL items in an order using a JOIN?
</details>

---

## Key Takeaways

- ✅ Always test with SELECT before UPDATE/DELETE
- ✅ Use transactions for safety (can ROLLBACK mistakes)
- ✅ WHERE clause is CRITICAL (prevents updating ALL rows)
- ✅ Verify affected row count after operations
- ✅ INSERT...SELECT efficiently copies data
- ✅ Archive before delete for important data
- ✅ Multiple VALUES sets are faster than separate INSERTs

**Remember:** DML changes are permanent! Better to be slow and safe than fast and wrong.