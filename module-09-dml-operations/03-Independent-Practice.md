# Independent Practice — DML Operations

## 📋 Before You Start

### Learning Objectives
Through independent practice, you will:
- Apply INSERT, UPDATE, DELETE without step-by-step guidance
- Perform bulk data operations safely
- Migrate data between tables
- Use transactions for complex multi-step changes
- Validate data modifications

### Difficulty Progression
- 🟢 **Easy (1-3)**: Single-table INSERT/UPDATE/DELETE, 10-12 minutes
- 🟡 **Medium (4-6)**: Multi-row updates, conditional logic, JOINs, 15-20 minutes
- 🔴 **Challenge (7)**: Data migration with validation and error handling, 25-30 minutes

### Problem-Solving Strategy
1. **READ** requirements carefully—understand WHAT data to change
2. **SETUP** sample data
3. **PLAN** your DML:
   - Which rows to affect? → Write WHERE clause first
   - Test with SELECT → Verify target rows
   - Write INSERT/UPDATE/DELETE → Apply changes
   - Verify results → Check affected rows
4. **USE TRANSACTIONS** for multi-step operations
5. **TRY** solving independently
6. **REVIEW** solution

### Critical Safety Guidelines
**Before ANY UPDATE or DELETE:**
1. Write and run: `SELECT * FROM table WHERE condition`
2. Verify row count matches expectations
3. Only then change SELECT to UPDATE/DELETE
4. Start with small test changes on non-production data

**Common Pitfalls:**
- ❌ Forgetting WHERE clause (affects ALL rows!)
- ❌ Not testing SELECT first (modify wrong rows)
- ❌ Updating without transaction (can't undo mistakes)
- ❌ Wrong join condition (updates wrong rows)
- ✅ Always use transactions for important changes!

**Recovery Strategy if Mistake:**
- If you used transaction: `ROLLBACK;`
- If you didn't: Restore from backup (always have backups!)
- Prevention is better than recovery!

---

## Exercise 1: Add New Products (🟢 Easy) — 10 min

**Scenario:** Your store is launching 5 new products. Add them to the inventory database.

### Setup
```sql
DROP TABLE IF EXISTS ip9_products;
CREATE TABLE ip9_products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT
);

-- Already have 2 products
INSERT INTO ip9_products (product_name, category, price, stock_quantity)
VALUES ('Gaming Mouse', 'Electronics', 49.99, 100),
       ('Office Chair', 'Furniture', 199.99, 50);
```

### Your Task
Insert these 5 new products in a **single INSERT statement**:
1. Mechanical Keyboard | Electronics | $129.99 | 75 units
2. USB-C Hub | Electronics | $34.99 | 200 units
3. Desk Lamp | Furniture | $29.99 | 150 units
4. Monitor Stand | Furniture | $45.00 | 80 units
5. Webcam | Electronics | $89.99 | 60 units

**Requirements:**
- Use ONE INSERT statement with multiple value sets
- Don't specify product_id (let AUTO_INCREMENT handle it)
- All 5 products should be inserted

<details>
<summary>💡 Hint</summary>

```sql
INSERT INTO table (col1, col2, col3, col4)
VALUES 
    (val1, val2, val3, val4),
    (val1, val2, val3, val4),
    ...;
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Insert 5 new products at once
INSERT INTO ip9_products (product_name, category, price, stock_quantity)
VALUES 
    ('Mechanical Keyboard', 'Electronics', 129.99, 75),
    ('USB-C Hub', 'Electronics', 34.99, 200),
    ('Desk Lamp', 'Furniture', 29.99, 150),
    ('Monitor Stand', 'Furniture', 45.00, 80),
    ('Webcam', 'Electronics', 89.99, 60);

-- Verify all products were inserted
SELECT * FROM ip9_products ORDER BY product_id;
```

**Expected Output:**
```
+------------+----------------------+-------------+--------+----------------+
| product_id | product_name         | category    | price  | stock_quantity |
+------------+----------------------+-------------+--------+----------------+
|          1 | Gaming Mouse         | Electronics |  49.99 |            100 |
|          2 | Office Chair         | Furniture   | 199.99 |             50 |
|          3 | Mechanical Keyboard  | Electronics | 129.99 |             75 |
|          4 | USB-C Hub            | Electronics |  34.99 |            200 |
|          5 | Desk Lamp            | Furniture   |  29.99 |            150 |
|          6 | Monitor Stand        | Furniture   |  45.00 |             80 |
|          7 | Webcam               | Electronics |  89.99 |             60 |
+------------+----------------------+-------------+--------+----------------+
7 rows total (5 new + 2 existing)
```

**Key Points:**
- Single INSERT with 5 value sets (efficient!)
- AUTO_INCREMENT assigned IDs 3-7 automatically
- All required columns provided (product_name, category, price, stock_quantity)
</details>

---

## Exercise 2: Apply Category Discount (🟢 Easy) — 12 min

**Scenario:** Your store is running a 15% off sale on all Electronics. Update prices for that category.

### Setup (Use data from Exercise 1)
```sql
-- If starting fresh, run this:
DROP TABLE IF EXISTS ip9_products;
CREATE TABLE ip9_products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT
);

INSERT INTO ip9_products (product_name, category, price, stock_quantity)
VALUES 
    ('Gaming Mouse', 'Electronics', 49.99, 100),
    ('Office Chair', 'Furniture', 199.99, 50),
    ('Mechanical Keyboard', 'Electronics', 129.99, 75),
    ('USB-C Hub', 'Electronics', 34.99, 200),
    ('Desk Lamp', 'Furniture', 29.99, 150),
    ('Monitor Stand', 'Furniture', 45.00, 80),
    ('Webcam', 'Electronics', 89.99, 60);
```

### Your Task
Reduce prices by 15% for all products in the 'Electronics' category.

**Requirements:**
- Only Electronics products should be affected
- Calculate: `new_price = old_price * 0.85` (85% = 100% - 15% discount)
- Furniture prices should remain unchanged

<details>
<summary>💡 Hint #1: Test First!</summary>

```sql
-- ALWAYS test with SELECT first
SELECT product_id, product_name, category, 
       price AS old_price, 
       price * 0.85 AS new_price
FROM ip9_products
WHERE category = 'Electronics';
```
</details>

<details>
<summary>💡 Hint #2: UPDATE Syntax</summary>

```sql
UPDATE table
SET column = column * 0.85
WHERE condition;
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Step 1: Preview the discount
SELECT product_id, product_name, category, 
       price AS old_price, 
       ROUND(price * 0.85, 2) AS new_price,
       ROUND(price - (price * 0.85), 2) AS discount_amount
FROM ip9_products
WHERE category = 'Electronics';

-- Expected preview:
-- +------------+---------------------+-------------+-----------+-----------+-----------------+
-- | product_id | product_name        | category    | old_price | new_price | discount_amount |
-- +------------+---------------------+-------------+-----------+-----------+-----------------+
-- |          1 | Gaming Mouse        | Electronics |     49.99 |     42.49 |            7.50 |
-- |          3 | Mechanical Keyboard | Electronics |    129.99 |    110.49 |           19.50 |
-- |          4 | USB-C Hub           | Electronics |     34.99 |     29.74 |            5.25 |
-- |          7 | Webcam              | Electronics |     89.99 |     76.49 |           13.50 |
-- +------------+---------------------+-------------+-----------+-----------+-----------------+

-- Step 2: Apply the discount (using transaction for safety)
START TRANSACTION;

UPDATE ip9_products
SET price = ROUND(price * 0.85, 2)
WHERE category = 'Electronics';

-- Step 3: Verify changes
SELECT * FROM ip9_products ORDER BY product_id;

-- Step 4: If correct, commit
COMMIT;
```

**Expected Output (After UPDATE):**
```
+------------+---------------------+-------------+--------+----------------+
| product_id | product_name        | category    | price  | stock_quantity |
+------------+---------------------+-------------+--------+----------------+
|          1 | Gaming Mouse        | Electronics |  42.49 |            100 | ← Changed
|          2 | Office Chair        | Furniture   | 199.99 |             50 | Unchanged
|          3 | Mechanical Keyboard | Electronics | 110.49 |             75 | ← Changed
|          4 | USB-C Hub           | Electronics |  29.74 |            200 | ← Changed
|          5 | Desk Lamp           | Furniture   |  29.99 |            150 | Unchanged
|          6 | Monitor Stand       | Furniture   |  45.00 |             80 | Unchanged
|          7 | Webcam              | Electronics |  76.49 |             60 | ← Changed
+------------+---------------------+-------------+--------+----------------+
4 rows affected (4 Electronics products updated)
```

**Key Points:**
- WHERE clause targets only Electronics (4 products)
- Furniture prices unchanged (3 products)
- ROUND() used to avoid long decimals (42.4915 → 42.49)
- Transaction allows ROLLBACK if mistake
</details>

---

## Exercise 3: Delete Out-of-Stock Items (🟢 Easy) — 11 min

**Scenario:** Remove products that have been out of stock (quantity = 0) for cleanup.

### Setup
```sql
DROP TABLE IF EXISTS ip9_inventory;
CREATE TABLE ip9_inventory (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    stock_quantity INT,
    last_restock_date DATE
);

INSERT INTO ip9_inventory VALUES
    (101, 'Laptop', 0, '2024-01-15'),        -- Out of stock
    (102, 'Mouse', 150, '2024-11-01'),       -- In stock
    (103, 'Keyboard', 0, '2024-03-20'),      -- Out of stock
    (104, 'Monitor', 75, '2024-10-15'),      -- In stock
    (105, 'Headphones', 0, '2024-02-10'),    -- Out of stock
    (106, 'Webcam', 45, '2024-11-05');       -- In stock
```

### Your Task
Delete all products where `stock_quantity = 0`.

**Requirements:**
- Only remove out-of-stock items (quantity = 0)
- Products with stock should remain
- Use transaction for safety

<details>
<summary>💡 Hint: SELECT-DELETE-SELECT Pattern</summary>

```sql
-- 1. See what will be deleted
SELECT * FROM table WHERE condition;

-- 2. Delete those rows
DELETE FROM table WHERE condition;

-- 3. Verify deletion
SELECT * FROM table;
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Step 1: Identify products to delete
SELECT product_id, product_name, stock_quantity
FROM ip9_inventory
WHERE stock_quantity = 0;

-- Expected:
-- +------------+-------------+----------------+
-- | product_id | product_name| stock_quantity |
-- +------------+-------------+----------------+
-- |        101 | Laptop      |              0 |
-- |        103 | Keyboard    |              0 |
-- |        105 | Headphones  |              0 |
-- +------------+-------------+----------------+

-- Step 2: Delete using transaction
START TRANSACTION;

DELETE FROM ip9_inventory
WHERE stock_quantity = 0;

-- Step 3: Verify remaining products
SELECT * FROM ip9_inventory ORDER BY product_id;

-- Expected (only in-stock items remain):
-- +------------+--------------+----------------+------------------+
-- | product_id | product_name | stock_quantity | last_restock_date|
-- +------------+--------------+----------------+------------------+
-- |        102 | Mouse        |            150 | 2024-11-01       |
-- |        104 | Monitor      |             75 | 2024-10-15       |
-- |        106 | Webcam       |             45 | 2024-11-05       |
-- +------------+--------------+----------------+------------------+

-- Step 4: If correct, commit
COMMIT;
```

**Expected Result:**
- 3 rows deleted (Laptop, Keyboard, Headphones)
- 3 rows remain (Mouse, Monitor, Webcam)
- All remaining products have stock > 0

**Key Points:**
- WHERE clause prevents deleting all products
- SELECT first confirms correct targets
- Transaction allows ROLLBACK if wrong rows deleted
- Permanent deletion (consider soft delete alternative!)
</details>

**💡 Alternative: Soft Delete**
```sql
-- Instead of DELETE, mark as inactive
ALTER TABLE ip9_inventory ADD COLUMN is_active BOOLEAN DEFAULT TRUE;

UPDATE ip9_inventory
SET is_active = FALSE
WHERE stock_quantity = 0;

-- Query active products only
SELECT * FROM ip9_inventory WHERE is_active = TRUE;
```

---

## Exercise 4: Restock from Shipments (🟡 Medium) — 18 min

**Scenario:** You have a `shipments` table with incoming stock. Update product inventory by adding shipment quantities using a JOIN.

### Setup
```sql
DROP TABLE IF EXISTS ip9_stock;
CREATE TABLE ip9_stock (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    current_stock INT
);

INSERT INTO ip9_stock VALUES
    (201, 'Laptop', 30),
    (202, 'Mouse', 50),
    (203, 'Keyboard', 40),
    (204, 'Monitor', 20);

DROP TABLE IF EXISTS ip9_shipments;
CREATE TABLE ip9_shipments (
    shipment_id INT PRIMARY KEY,
    product_id INT,
    quantity_received INT,
    shipment_date DATE
);

INSERT INTO ip9_shipments VALUES
    (1, 201, 25, '2024-11-06'),  -- 25 Laptops
    (2, 203, 50, '2024-11-06'),  -- 50 Keyboards
    (3, 204, 30, '2024-11-06');  -- 30 Monitors
-- Note: No shipment for Mouse (202)
```

### Your Task
Update `current_stock` in `ip9_stock` by adding `quantity_received` from `ip9_shipments` using UPDATE with JOIN.

**Requirements:**
- Use INNER JOIN to match products
- Add shipment quantity to current stock
- Only update products that have shipments
- Mouse should remain unchanged (no shipment)

<details>
<summary>💡 Hint: UPDATE...JOIN Syntax</summary>

```sql
UPDATE table1 t1
INNER JOIN table2 t2 ON t1.key = t2.key
SET t1.column = t1.column + t2.column;
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Step 1: Preview the update
SELECT 
    s.product_id,
    s.product_name,
    s.current_stock,
    sh.quantity_received,
    s.current_stock + sh.quantity_received AS new_stock
FROM ip9_stock s
INNER JOIN ip9_shipments sh ON s.product_id = sh.product_id;

-- Expected preview:
-- +------------+--------------+---------------+-------------------+-----------+
-- | product_id | product_name | current_stock | quantity_received | new_stock |
-- +------------+--------------+---------------+-------------------+-----------+
-- |        201 | Laptop       |            30 |                25 |        55 |
-- |        203 | Keyboard     |            40 |                50 |        90 |
-- |        204 | Monitor      |            20 |                30 |        50 |
-- +------------+--------------+---------------+-------------------+-----------+

-- Step 2: Apply the update
START TRANSACTION;

UPDATE ip9_stock s
INNER JOIN ip9_shipments sh ON s.product_id = sh.product_id
SET s.current_stock = s.current_stock + sh.quantity_received;

-- Step 3: Verify all products
SELECT * FROM ip9_stock ORDER BY product_id;

-- Expected:
-- +------------+--------------+---------------+
-- | product_id | product_name | current_stock |
-- +------------+--------------+---------------+
-- |        201 | Laptop       |            55 | ← Updated (30+25)
-- |        202 | Mouse        |            50 | Unchanged
-- |        203 | Keyboard     |            90 | ← Updated (40+50)
-- |        204 | Monitor      |            50 | ← Updated (20+30)
-- +------------+--------------+---------------+

COMMIT;
```

**Key Points:**
- INNER JOIN only updates matched products (3 out of 4)
- Mouse (202) unchanged because no shipment exists
- Column reference: `s.current_stock` (stock table) + `sh.quantity_received` (shipments table)
- 3 rows affected

**Common Mistake:**
```sql
-- ❌ WRONG: LEFT JOIN would try to add NULL
UPDATE ip9_stock s
LEFT JOIN ip9_shipments sh ON s.product_id = sh.product_id
SET s.current_stock = s.current_stock + sh.quantity_received;
-- Mouse would become: 50 + NULL = NULL (wrong!)

-- ✅ RIGHT: INNER JOIN only processes matches
UPDATE ip9_stock s
INNER JOIN ip9_shipments sh ON s.product_id = sh.product_id
SET s.current_stock = s.current_stock + sh.quantity_received;
```
</details>

---

## Exercise 5: Update Status Based on Multiple Conditions (🟡 Medium) — 20 min

**Scenario:** Assign order statuses based on payment and shipment states using CASE logic.

### Setup
```sql
DROP TABLE IF EXISTS ip9_orders;
CREATE TABLE ip9_orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    is_paid BOOLEAN,
    is_shipped BOOLEAN,
    order_status VARCHAR(20)
);

INSERT INTO ip9_orders VALUES
    (1001, 'Alice', TRUE, TRUE, NULL),    -- Paid + Shipped = Delivered
    (1002, 'Bob', TRUE, FALSE, NULL),     -- Paid + Not shipped = Processing
    (1003, 'Charlie', FALSE, FALSE, NULL),-- Not paid = Pending Payment
    (1004, 'Diana', TRUE, TRUE, NULL),    -- Paid + Shipped = Delivered
    (1005, 'Eve', FALSE, TRUE, NULL);     -- Not paid but shipped = Error/Review
```

### Your Task
Update `order_status` using this logic:
- If `is_paid = TRUE` AND `is_shipped = TRUE` → 'Delivered'
- If `is_paid = TRUE` AND `is_shipped = FALSE` → 'Processing'
- If `is_paid = FALSE` AND `is_shipped = FALSE` → 'Pending Payment'
- If `is_paid = FALSE` AND `is_shipped = TRUE` → 'Needs Review' (unusual case)

**Requirements:**
- Use UPDATE with CASE statement
- All 4 conditions must be handled
- Verify correct status for each order

<details>
<summary>💡 Hint: CASE with Multiple Conditions</summary>

```sql
UPDATE table
SET column = CASE
    WHEN condition1 AND condition2 THEN 'value1'
    WHEN condition3 AND condition4 THEN 'value2'
    ELSE 'default'
END;
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Step 1: Preview status assignment
SELECT 
    order_id,
    customer_name,
    is_paid,
    is_shipped,
    CASE
        WHEN is_paid = TRUE AND is_shipped = TRUE THEN 'Delivered'
        WHEN is_paid = TRUE AND is_shipped = FALSE THEN 'Processing'
        WHEN is_paid = FALSE AND is_shipped = FALSE THEN 'Pending Payment'
        WHEN is_paid = FALSE AND is_shipped = TRUE THEN 'Needs Review'
    END AS new_status
FROM ip9_orders;

-- Expected preview:
-- +----------+---------------+---------+------------+------------------+
-- | order_id | customer_name | is_paid | is_shipped | new_status       |
-- +----------+---------------+---------+------------+------------------+
-- |     1001 | Alice         |       1 |          1 | Delivered        |
-- |     1002 | Bob           |       1 |          0 | Processing       |
-- |     1003 | Charlie       |       0 |          0 | Pending Payment  |
-- |     1004 | Diana         |       1 |          1 | Delivered        |
-- |     1005 | Eve           |       0 |          1 | Needs Review     |
-- +----------+---------------+---------+------------+------------------+

-- Step 2: Apply status update
START TRANSACTION;

UPDATE ip9_orders
SET order_status = CASE
    WHEN is_paid = TRUE AND is_shipped = TRUE THEN 'Delivered'
    WHEN is_paid = TRUE AND is_shipped = FALSE THEN 'Processing'
    WHEN is_paid = FALSE AND is_shipped = FALSE THEN 'Pending Payment'
    WHEN is_paid = FALSE AND is_shipped = TRUE THEN 'Needs Review'
END;

-- Step 3: Verify results
SELECT * FROM ip9_orders ORDER BY order_id;

-- Expected:
-- +----------+---------------+---------+------------+------------------+
-- | order_id | customer_name | is_paid | is_shipped | order_status     |
-- +----------+---------------+---------+------------+------------------+
-- |     1001 | Alice         |       1 |          1 | Delivered        |
-- |     1002 | Bob           |       1 |          0 | Processing       |
-- |     1003 | Charlie       |       0 |          0 | Pending Payment  |
-- |     1004 | Diana         |       1 |          1 | Delivered        |
-- |     1005 | Eve           |       0 |          1 | Needs Review     |
-- +----------+---------------+---------+------------+------------------+

COMMIT;
```

**Key Points:**
- CASE handles all 4 combinations of is_paid/is_shipped
- Order matters: most specific conditions first
- Eve's order flagged for review (shipped but not paid - unusual!)
- All 5 rows updated with appropriate status

**Business Logic:**
- **Delivered:** Customer paid, package delivered ✅
- **Processing:** Paid, warehouse preparing shipment 📦
- **Pending Payment:** Waiting for customer payment 💳
- **Needs Review:** Anomaly - shipped without payment ⚠️ (investigate!)
</details>

---

## Exercise 6: Bulk Price Adjustment with Conditions (🟡 Medium) — 19 min

**Scenario:** Apply different price adjustments based on product category and current price tier.

### Setup
```sql
DROP TABLE IF EXISTS ip9_catalog;
CREATE TABLE ip9_catalog (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

INSERT INTO ip9_catalog VALUES
    (301, 'Budget Mouse', 'Electronics', 15.00),
    (302, 'Gaming Mouse', 'Electronics', 75.00),
    (303, 'Office Chair', 'Furniture', 120.00),
    (304, 'Ergonomic Chair', 'Furniture', 450.00),
    (305, 'Basic Keyboard', 'Electronics', 25.00),
    (306, 'Mech Keyboard', 'Electronics', 150.00),
    (307, 'Desk Lamp', 'Furniture', 30.00),
    (308, 'Designer Lamp', 'Furniture', 200.00);
```

### Your Task
Apply these pricing rules:
- **Electronics under $50:** Increase by 20% (price * 1.20)
- **Electronics $50+:** Increase by 10% (price * 1.10)
- **Furniture under $100:** Increase by 15% (price * 1.15)
- **Furniture $100+:** Increase by 5% (price * 1.05)

**Requirements:**
- Use single UPDATE with CASE statement
- All products should get appropriate adjustment
- Round to 2 decimal places

<details>
<summary>💡 Hint: Nested Conditions in CASE</summary>

```sql
CASE
    WHEN category = 'X' AND price < 50 THEN price * 1.20
    WHEN category = 'X' AND price >= 50 THEN price * 1.10
    WHEN category = 'Y' AND price < 100 THEN price * 1.15
    WHEN category = 'Y' AND price >= 100 THEN price * 1.05
END
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Step 1: Preview price adjustments
SELECT 
    product_id,
    product_name,
    category,
    price AS old_price,
    CASE
        WHEN category = 'Electronics' AND price < 50 THEN ROUND(price * 1.20, 2)
        WHEN category = 'Electronics' AND price >= 50 THEN ROUND(price * 1.10, 2)
        WHEN category = 'Furniture' AND price < 100 THEN ROUND(price * 1.15, 2)
        WHEN category = 'Furniture' AND price >= 100 THEN ROUND(price * 1.05, 2)
    END AS new_price,
    CASE
        WHEN category = 'Electronics' AND price < 50 THEN '+20%'
        WHEN category = 'Electronics' AND price >= 50 THEN '+10%'
        WHEN category = 'Furniture' AND price < 100 THEN '+15%'
        WHEN category = 'Furniture' AND price >= 100 THEN '+5%'
    END AS adjustment
FROM ip9_catalog;

-- Expected preview:
-- +------------+------------------+-------------+-----------+-----------+------------+
-- | product_id | product_name     | category    | old_price | new_price | adjustment |
-- +------------+------------------+-------------+-----------+-----------+------------+
-- |        301 | Budget Mouse     | Electronics |     15.00 |     18.00 | +20%       |
-- |        302 | Gaming Mouse     | Electronics |     75.00 |     82.50 | +10%       |
-- |        303 | Office Chair     | Furniture   |    120.00 |    126.00 | +5%        |
-- |        304 | Ergonomic Chair  | Furniture   |    450.00 |    472.50 | +5%        |
-- |        305 | Basic Keyboard   | Electronics |     25.00 |     30.00 | +20%       |
-- |        306 | Mech Keyboard    | Electronics |    150.00 |    165.00 | +10%       |
-- |        307 | Desk Lamp        | Furniture   |     30.00 |     34.50 | +15%       |
-- |        308 | Designer Lamp    | Furniture   |    200.00 |    210.00 | +5%        |
-- +------------+------------------+-------------+-----------+-----------+------------+

-- Step 2: Apply price adjustments
START TRANSACTION;

UPDATE ip9_catalog
SET price = CASE
    WHEN category = 'Electronics' AND price < 50 THEN ROUND(price * 1.20, 2)
    WHEN category = 'Electronics' AND price >= 50 THEN ROUND(price * 1.10, 2)
    WHEN category = 'Furniture' AND price < 100 THEN ROUND(price * 1.15, 2)
    WHEN category = 'Furniture' AND price >= 100 THEN ROUND(price * 1.05, 2)
END;

-- Step 3: Verify all changes
SELECT * FROM ip9_catalog ORDER BY product_id;

-- Expected:
-- +------------+------------------+-------------+--------+
-- | product_id | product_name     | category    | price  |
-- +------------+------------------+-------------+--------+
-- |        301 | Budget Mouse     | Electronics |  18.00 | ← +20%
-- |        302 | Gaming Mouse     | Electronics |  82.50 | ← +10%
-- |        303 | Office Chair     | Furniture   | 126.00 | ← +5%
-- |        304 | Ergonomic Chair  | Furniture   | 472.50 | ← +5%
-- |        305 | Basic Keyboard   | Electronics |  30.00 | ← +20%
-- |        306 | Mech Keyboard    | Electronics | 165.00 | ← +10%
-- |        307 | Desk Lamp        | Furniture   |  34.50 | ← +15%
-- |        308 | Designer Lamp    | Furniture   | 210.00 | ← +5%
-- +------------+------------------+-------------+--------+

COMMIT;
```

**Key Points:**
- 4 different adjustment percentages based on category + price tier
- CASE with compound conditions (category AND price)
- ROUND() prevents long decimals (18.0000... → 18.00)
- All 8 products updated with appropriate multiplier

**Business Logic:**
- Cheaper items get bigger % increases (more elastic demand)
- Expensive items get smaller % increases (preserve competitiveness)
- Category-specific pricing strategies
</details>

---

## Exercise 7: Complex Data Migration with Validation (🔴 Challenge) — 28 min

**Scenario:** Migrate customer data from legacy system to new system with data cleansing, validation, and error handling.

### Setup
```sql
-- Legacy customer table (messy data)
DROP TABLE IF EXISTS ip9_legacy_customers;
CREATE TABLE ip9_legacy_customers (
    old_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    email_address VARCHAR(100),
    phone_number VARCHAR(30),
    signup_date VARCHAR(20),  -- Stored as text!
    account_status VARCHAR(20)
);

INSERT INTO ip9_legacy_customers VALUES
    (1, 'Alice Johnson', '  alice@example.com  ', '(555) 123-4567', '2023-01-15', 'active'),
    (2, 'Bob Smith', 'bob@EXAMPLE.com', '555.234.5678', '2023-03-22', 'ACTIVE'),
    (3, 'Charlie Brown', 'charlie@example.com  ', '555-345-6789', 'invalid-date', 'suspended'),
    (4, 'Diana Prince', '  DIANA@EXAMPLE.COM', '5554567890', '2023-08-10', 'active'),
    (5, 'Eve Adams', 'eve@example.com', '', '2023-11-01', 'inactive');  -- Missing phone

-- New customer table (clean schema)
DROP TABLE IF EXISTS ip9_customers;
CREATE TABLE ip9_customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    legacy_id INT UNIQUE,  -- Track where data came from
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(15),  -- Digits only
    signup_date DATE,   -- Proper date type
    is_active BOOLEAN,
    migrated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Error log table
DROP TABLE IF EXISTS ip9_migration_errors;
CREATE TABLE ip9_migration_errors (
    error_id INT AUTO_INCREMENT PRIMARY KEY,
    legacy_id INT,
    error_message VARCHAR(255),
    recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### Your Task
Migrate customer data with these requirements:

**Data Transformations:**
1. **Email:** TRIM whitespace, convert to LOWERCASE
2. **Phone:** Remove all non-digit characters, store digits only
3. **Signup Date:** Convert text to proper DATE (skip if invalid)
4. **Status:** Convert 'active'/'ACTIVE' → TRUE, others → FALSE
5. **Name:** Keep as-is (already clean)

**Validation Rules:**
- Email must contain '@'
- Phone must have at least 10 digits (after cleaning)
- Invalid dates should log error and skip that record
- All other records should migrate successfully

**Requirements:**
- Use INSERT...SELECT with transformations
- Log validation errors to `ip9_migration_errors`
- Use transactions for data integrity
- Verify all valid records migrated

<details>
<summary>💡 Hint #1: String Functions</summary>

```sql
TRIM(column)                                    -- Remove spaces
LOWER(column)                                   -- Convert to lowercase
REPLACE(REPLACE(column, '(', ''), ')', '')     -- Remove characters
SUBSTRING(column, start, length)                -- Extract portions
```
</details>

<details>
<summary>💡 Hint #2: Date Conversion</summary>

```sql
-- Convert string to date (returns NULL if invalid)
STR_TO_DATE(column, '%Y-%m-%d')

-- Or check if valid:
WHERE signup_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
```
</details>

<details>
<summary>💡 Hint #3: Conditional Migration</summary>

```sql
-- Migrate valid records only
INSERT INTO new_table (...)
SELECT ...
FROM legacy_table
WHERE email LIKE '%@%'  -- Has @
  AND LENGTH(REPLACE(...phone...)) >= 10  -- Valid phone
  AND signup_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';  -- Valid date
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- ========================================
-- COMPLETE DATA MIGRATION SCRIPT
-- ========================================

START TRANSACTION;

-- Step 1: Log invalid records (before migration)
-- Check for invalid emails
INSERT INTO ip9_migration_errors (legacy_id, error_message)
SELECT old_id, CONCAT('Invalid email: ', email_address)
FROM ip9_legacy_customers
WHERE TRIM(email_address) NOT LIKE '%@%';

-- Check for invalid phone numbers (less than 10 digits after cleaning)
INSERT INTO ip9_migration_errors (legacy_id, error_message)
SELECT old_id, CONCAT('Invalid phone: ', phone_number)
FROM ip9_legacy_customers
WHERE LENGTH(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(phone_number, '(', ''), ')', ''), '-', ''), '.', ''), ' ', '')) < 10;

-- Check for invalid dates
INSERT INTO ip9_migration_errors (legacy_id, error_message)
SELECT old_id, CONCAT('Invalid date: ', signup_date)
FROM ip9_legacy_customers
WHERE signup_date NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

-- Step 2: Migrate valid records with transformations
INSERT INTO ip9_customers (legacy_id, name, email, phone, signup_date, is_active)
SELECT 
    old_id,
    full_name,
    LOWER(TRIM(email_address)) AS email,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(phone_number, '(', ''), ')', ''), '-', ''), '.', ''), ' ', '') AS phone,
    STR_TO_DATE(signup_date, '%Y-%m-%d') AS signup_date,
    CASE 
        WHEN LOWER(account_status) = 'active' THEN TRUE
        ELSE FALSE
    END AS is_active
FROM ip9_legacy_customers
WHERE TRIM(email_address) LIKE '%@%'  -- Valid email
  AND LENGTH(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(phone_number, '(', ''), ')', ''), '-', ''), '.', ''), ' ', '')) >= 10  -- Valid phone
  AND signup_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';  -- Valid date

-- Step 3: Verify migration results
SELECT 'Migration Summary:' AS report;

SELECT COUNT(*) AS total_legacy_records FROM ip9_legacy_customers;
SELECT COUNT(*) AS successful_migrations FROM ip9_customers;
SELECT COUNT(*) AS failed_migrations FROM ip9_migration_errors;

-- Step 4: Review migrated data
SELECT * FROM ip9_customers ORDER BY customer_id;

-- Step 5: Check error log
SELECT * FROM ip9_migration_errors;

-- Step 6: If everything looks good, commit
COMMIT;
```

**Expected Results:**

**Migrated Customers:**
```
+-------------+-----------+----------------+---------------------+------------+-------------+-----------+---------------------+
| customer_id | legacy_id | name           | email               | phone      | signup_date | is_active | migrated_at         |
+-------------+-----------+----------------+---------------------+------------+-------------+-----------+---------------------+
|           1 |         1 | Alice Johnson  | alice@example.com   | 5551234567 | 2023-01-15  |         1 | 2025-11-06 15:00:00 |
|           2 |         2 | Bob Smith      | bob@example.com     | 5552345678 | 2023-03-22  |         1 | 2025-11-06 15:00:00 |
|           3 |         4 | Diana Prince   | diana@example.com   | 5554567890 | 2023-08-10  |         1 | 2025-11-06 15:00:00 |
+-------------+-----------+----------------+---------------------+------------+-------------+-----------+---------------------+
3 successful migrations
```

**Migration Errors:**
```
+----------+-----------+-------------------------------+---------------------+
| error_id | legacy_id | error_message                 | recorded_at         |
+----------+-----------+-------------------------------+---------------------+
|        1 |         3 | Invalid date: invalid-date    | 2025-11-06 15:00:00 |
|        2 |         5 | Invalid phone:                | 2025-11-06 15:00:00 |
+----------+-----------+-------------------------------+---------------------+
2 failed migrations
```

**Analysis:**
- ✅ **Record 1 (Alice):** Migrated - email trimmed, phone formatted
- ✅ **Record 2 (Bob):** Migrated - email lowercased, phone formatted
- ❌ **Record 3 (Charlie):** FAILED - Invalid date format
- ✅ **Record 4 (Diana):** Migrated - email trimmed+lowercased, phone already clean
- ❌ **Record 5 (Eve):** FAILED - Phone missing (empty string < 10 digits)

**Key Transformations:**
```
Alice:
  email:  '  alice@example.com  ' → 'alice@example.com' (TRIM + LOWER)
  phone:  '(555) 123-4567'        → '5551234567' (removed all non-digits)
  
Bob:
  email:  'bob@EXAMPLE.com'       → 'bob@example.com' (LOWER)
  phone:  '555.234.5678'          → '5552345678' (removed dots)
  status: 'ACTIVE'                → TRUE (CASE conversion)
  
Charlie:
  ERROR: signup_date 'invalid-date' doesn't match YYYY-MM-DD format

Diana:
  email:  '  DIANA@EXAMPLE.COM'   → 'diana@example.com' (TRIM + LOWER)
  phone:  '5554567890'            → '5554567890' (already digits)
  
Eve:
  ERROR: phone '' has 0 digits (< 10 required)
```

</details>

**Key Takeaways:**
- Complex migrations require validation + error logging
- Transactions protect data integrity
- String functions clean messy data
- Separate error handling from main migration
- Always verify counts: legacy = migrated + failed

---

## 🎯 Practice Wrap-Up

**What You Accomplished:**
- ✅ Basic DML operations (INSERT, UPDATE, DELETE)
- ✅ Conditional updates with WHERE and CASE
- ✅ Multi-table updates with JOIN
- ✅ Data transformations and cleansing
- ✅ Complex migrations with validation
- ✅ Error handling and logging
- ✅ Transaction safety patterns

**Next Steps:**
- Try Paired Programming exercises for collaboration practice
- Tackle Real-World Project for comprehensive scenarios
- Challenge yourself with Take-Home assignments

**Remember:**
- 🔍 Always SELECT before UPDATE/DELETE
- 🔄 Use transactions for safety
- ✅ Verify affected row counts
- 📝 Log errors for troubleshooting
- 💾 Backup before major changes!
