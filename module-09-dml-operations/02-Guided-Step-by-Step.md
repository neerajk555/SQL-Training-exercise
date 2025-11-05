# Guided Step-by-Step — DML Operations

## 📋 Before You Start

### Learning Objectives
Through these guided activities, you will:
- Update data using UPDATE with JOINs
- Archive data with INSERT...SELECT patterns
- Perform safe DELETE operations
- Use CASE in UPDATE for conditional logic
- Practice transaction safety

### Critical DML Safety Concepts
**Transaction Pattern:**
```sql
START TRANSACTION;
  -- Your INSERT/UPDATE/DELETE statements
  -- Check results with SELECT
COMMIT;  -- Or ROLLBACK if something's wrong
```

**Testing Strategy:**
1. Write SELECT to identify target rows
2. Convert to UPDATE/DELETE
3. Verify affected row count
4. Use transaction to protect data

### Execution Process
1. **Run complete setup** for each activity
2. **Follow steps** carefully—DML is permanent!
3. **Verify checkpoints** before proceeding
4. **Use transactions** for safety
5. **Study complete solution**

---

## Activity 1: Product Inventory Update (17 min) ⏱️

**Scenario:** Your warehouse just received shipments for several products. You have a `shipments` table with quantities received, and you need to update your `products` inventory accordingly.

**Real-World Analogy:** This is like when Amazon receives trucks at the warehouse - they scan incoming boxes and automatically update inventory counts in the system. You're combining data from TWO tables (products + shipments) to update quantities.

**What You'll Learn:** UPDATE with JOIN - combining data from multiple tables to modify records

### Setup Code
```sql
-- Create products table
DROP TABLE IF EXISTS gs9_products;
CREATE TABLE gs9_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    stock_quantity INT
);

INSERT INTO gs9_products VALUES
    (101, 'Laptop', 50),
    (102, 'Mouse', 200),
    (103, 'Keyboard', 150),
    (104, 'Monitor', 75);

-- Create shipments table (new stock arrivals)
DROP TABLE IF EXISTS gs9_shipments;
CREATE TABLE gs9_shipments (
    shipment_id INT PRIMARY KEY,
    product_id INT,
    quantity_received INT
);

INSERT INTO gs9_shipments VALUES
    (1, 101, 25),   -- 25 Laptops arrived
    (2, 102, 100),  -- 100 Mice arrived
    (3, 104, 50);   -- 50 Monitors arrived
    -- Note: No shipment for Keyboard (product 103)
```

---

### Step 1: Understand Current State (3 min)

**Task:** View both tables to see what needs updating.

<details>
<summary>💡 Your Turn</summary>

```sql
-- View current inventory
SELECT * FROM gs9_products ORDER BY product_id;

-- View incoming shipments
SELECT * FROM gs9_shipments ORDER BY shipment_id;
```

**Expected Output:**
```
-- Products (current inventory):
+------------+--------------+----------------+
| product_id | product_name | stock_quantity |
+------------+--------------+----------------+
|        101 | Laptop       |             50 |
|        102 | Mouse        |            200 |
|        103 | Keyboard     |            150 |
|        104 | Monitor      |             75 |
+------------+--------------+----------------+

-- Shipments (need to add to inventory):
+-------------+------------+-------------------+
| shipment_id | product_id | quantity_received |
+-------------+------------+-------------------+
|           1 |        101 |                25 |
|           2 |        102 |               100 |
|           3 |        104 |                50 |
+-------------+------------+-------------------+
```

**Analysis:** 
- Laptop needs +25 (50 → 75)
- Mouse needs +100 (200 → 300)
- Keyboard gets no update (no shipment)
- Monitor needs +50 (75 → 125)
</details>

✅ **Checkpoint:** You should see 4 products and 3 shipments.

---

### Step 2: Preview the Update with SELECT + JOIN (5 min)

**Task:** Write a SELECT query that shows what the new quantities WOULD BE after adding shipments. Use JOIN to combine products and shipments.

<details>
<summary>💡 Hint: JOIN Structure</summary>

```sql
SELECT 
    p.product_id,
    p.product_name,
    p.stock_quantity AS old_quantity,
    s.quantity_received,
    p.stock_quantity + s.quantity_received AS new_quantity
FROM gs9_products p
INNER JOIN gs9_shipments s ON p.product_id = s.product_id;
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Preview what will happen when we update
SELECT 
    p.product_id,
    p.product_name,
    p.stock_quantity AS old_quantity,
    s.quantity_received,
    p.stock_quantity + s.quantity_received AS new_quantity
FROM gs9_products p
INNER JOIN gs9_shipments s ON p.product_id = s.product_id
ORDER BY p.product_id;
```

**Expected Output:**
```
+------------+--------------+--------------+-------------------+--------------+
| product_id | product_name | old_quantity | quantity_received | new_quantity |
+------------+--------------+--------------+-------------------+--------------+
|        101 | Laptop       |           50 |                25 |           75 |
|        102 | Mouse        |          200 |               100 |          300 |
|        104 | Monitor      |           75 |                50 |          125 |
+------------+--------------+--------------+-------------------+--------------+
```

**Notice:** Keyboard (103) is NOT in results because INNER JOIN only returns matches! No shipment = no update.

**Beginner Tip:** Always preview calculations with SELECT before running UPDATE. This lets you verify the math is correct!
</details>

✅ **Checkpoint:** Your preview should show 3 products with calculated new quantities.

---

### Step 3: Execute the UPDATE with JOIN (5 min)

**Task:** Now convert the SELECT into an UPDATE statement. You'll use the same JOIN logic but change the action from "show me" to "update it".

<details>
<summary>💡 Hint: UPDATE...JOIN Syntax</summary>

MySQL syntax for UPDATE with JOIN:
```sql
UPDATE table1
INNER JOIN table2 ON table1.key = table2.key
SET table1.column = table1.column + table2.column;
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Use transaction for safety
START TRANSACTION;

-- Update inventory based on shipments
UPDATE gs9_products p
INNER JOIN gs9_shipments s ON p.product_id = s.product_id
SET p.stock_quantity = p.stock_quantity + s.quantity_received;

-- Verify the changes
SELECT * FROM gs9_products ORDER BY product_id;

-- If correct, commit; if wrong, rollback
COMMIT;
```

**Expected Output (After UPDATE):**
```
+------------+--------------+----------------+
| product_id | product_name | stock_quantity |
+------------+--------------+----------------+
|        101 | Laptop       |             75 |  -- Was 50, added 25
|        102 | Mouse        |            300 |  -- Was 200, added 100
|        103 | Keyboard     |            150 |  -- Unchanged (no shipment)
|        104 | Monitor      |            125 |  -- Was 75, added 50
+------------+--------------+----------------+
3 rows affected
```

**What Happened:**
- UPDATE used INNER JOIN to find matching product_ids
- Added `quantity_received` to existing `stock_quantity`
- Only 3 rows updated (Keyboard had no matching shipment)
- Transaction ensures we can ROLLBACK if needed

**Beginner Tip:** The UPDATE affects `gs9_products`, but uses data from `gs9_shipments` via JOIN. Think of JOIN as bringing in extra information to help with the update!
</details>

✅ **Checkpoint:** Stock quantities should be: Laptop=75, Mouse=300, Keyboard=150, Monitor=125.

---

### Step 4: Understanding the Pattern (4 min)

**Reflection Questions:**

1. **Why use INNER JOIN instead of LEFT JOIN?**
   <details>
   <summary>Answer</summary>
   
   INNER JOIN only updates products that HAVE shipments. If we used LEFT JOIN, we'd try to add NULL to products without shipments (causing errors or unintended behavior).
   
   ```sql
   -- INNER JOIN: Only updates matches
   UPDATE products p
   INNER JOIN shipments s ON p.product_id = s.product_id
   SET p.stock_quantity = p.stock_quantity + s.quantity_received;
   -- Only 3 products updated (101, 102, 104)
   
   -- LEFT JOIN: Tries to update ALL products
   UPDATE products p
   LEFT JOIN shipments s ON p.product_id = s.product_id
   SET p.stock_quantity = p.stock_quantity + s.quantity_received;
   -- Error or wrong result! Can't add NULL to Keyboard's quantity
   ```
   </details>

2. **What if we ran the UPDATE twice?**
   <details>
   <summary>Answer</summary>
   
   The inventory would be WRONG! It would add shipments twice:
   - First run: Laptop 50 + 25 = 75 ✅
   - Second run: Laptop 75 + 25 = 100 ❌ (wrong!)
   
   **Solution:** Delete shipment records after processing:
   ```sql
   START TRANSACTION;
   UPDATE gs9_products p
   INNER JOIN gs9_shipments s ON p.product_id = s.product_id
   SET p.stock_quantity = p.stock_quantity + s.quantity_received;
   
   -- Remove processed shipments so they can't be applied twice
   DELETE FROM gs9_shipments;
   
   COMMIT;
   ```
   </details>

3. **How would you UPDATE with a condition?**
   <details>
   <summary>Answer</summary>
   
   Add WHERE clause to filter:
   ```sql
   -- Only update products with shipments > 50
   UPDATE gs9_products p
   INNER JOIN gs9_shipments s ON p.product_id = s.product_id
   SET p.stock_quantity = p.stock_quantity + s.quantity_received
   WHERE s.quantity_received > 50;
   -- Only Mouse (100) would be updated, not Laptop (25) or Monitor (50)
   ```
   </details>

---

### Real-World Applications

This UPDATE + JOIN pattern is used for:
- **Inventory management:** Adding received shipments
- **Order fulfillment:** Subtracting sold quantities
- **Pricing updates:** Applying category-wide discounts
- **Status changes:** Marking items as "shipped" when tracking shows delivery
- **Data migrations:** Copying values from staging tables to production

**Key Takeaway:** UPDATE with JOIN lets you modify data in one table based on related data in another table!

---

## Activity 2: Order Archival (18 min) ⏱️

**Scenario:** Your e-commerce platform keeps all orders in one table, but it's getting huge (millions of rows). To improve performance, you need to move old completed orders (over 1 year old) to an archive table, then delete them from the active table.

**Real-World Analogy:** This is like moving old paper files from your office filing cabinet to long-term storage in the basement. You still have the data, but it's not clogging up your daily workspace.

**What You'll Learn:** INSERT...SELECT (copy data) + DELETE (remove originals) - the archival pattern

### Setup Code
```sql
-- Create active orders table
DROP TABLE IF EXISTS gs9_orders;
CREATE TABLE gs9_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    status VARCHAR(20)
);

INSERT INTO gs9_orders VALUES
    (1001, 5, '2023-06-15', 150.00, 'Completed'),  -- Old (over 1 year)
    (1002, 12, '2024-11-01', 200.00, 'Completed'), -- Recent
    (1003, 8, '2023-08-20', 75.50, 'Completed'),   -- Old
    (1004, 5, '2024-10-15', 300.00, 'Pending'),    -- Recent + not completed
    (1005, 3, '2023-12-10', 125.00, 'Completed');  -- Old

-- Create empty archive table (same structure)
DROP TABLE IF EXISTS gs9_orders_archive;
CREATE TABLE gs9_orders_archive (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    status VARCHAR(20),
    archived_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

### Step 1: Identify Records to Archive (4 min)

**Task:** Write a SELECT query to find all orders that should be archived. 

**Archive Criteria:**
- Status = 'Completed' 
- Order date > 1 year ago

<details>
<summary>💡 Hint: Date Calculation</summary>

MySQL date arithmetic:
```sql
-- Date 1 year ago from today
DATE_SUB(CURDATE(), INTERVAL 1 YEAR)

-- Compare: orders older than this
WHERE order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Find orders to archive
SELECT 
    order_id,
    customer_id,
    order_date,
    total_amount,
    status,
    DATEDIFF(CURDATE(), order_date) AS days_old
FROM gs9_orders
WHERE status = 'Completed'
  AND order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
ORDER BY order_date;
```

**Expected Output:**
```
+----------+-------------+------------+--------------+-----------+----------+
| order_id | customer_id | order_date | total_amount | status    | days_old |
+----------+-------------+------------+--------------+-----------+----------+
|     1001 |           5 | 2023-06-15 |       150.00 | Completed |      509 |
|     1003 |           8 | 2023-08-20 |        75.50 | Completed |      443 |
|     1005 |           3 | 2023-12-10 |       125.00 | Completed |      331 |
+----------+-------------+------------+--------------+-----------+----------+
```

**Analysis:**
- 3 orders match criteria (1001, 1003, 1005)
- Order 1002 excluded (recent - 2024-11-01)
- Order 1004 excluded (status = 'Pending', not 'Completed')

**Beginner Tip:** DATE_SUB(CURDATE(), INTERVAL 1 YEAR) calculates "1 year ago from today" automatically. This query will work correctly on any date!
</details>

✅ **Checkpoint:** You should see 3 old completed orders ready for archival.

---

### Step 2: Copy Records to Archive (5 min)

**Task:** Use INSERT...SELECT to copy the identified orders into the archive table.

<details>
<summary>💡 Hint: INSERT...SELECT Pattern</summary>

```sql
INSERT INTO archive_table (columns)
SELECT columns FROM active_table WHERE conditions;
```

The SELECT determines which rows get copied. No VALUES needed!
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Copy old orders to archive
INSERT INTO gs9_orders_archive (order_id, customer_id, order_date, total_amount, status)
SELECT order_id, customer_id, order_date, total_amount, status
FROM gs9_orders
WHERE status = 'Completed'
  AND order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- Verify the copy
SELECT * FROM gs9_orders_archive ORDER BY order_id;
```

**Expected Output:**
```
+----------+-------------+------------+--------------+-----------+---------------------+
| order_id | customer_id | order_date | total_amount | status    | archived_at         |
+----------+-------------+------------+--------------+-----------+---------------------+
|     1001 |           5 | 2023-06-15 |       150.00 | Completed | 2025-11-06 14:30:00 |
|     1003 |           8 | 2023-08-20 |        75.50 | Completed | 2025-11-06 14:30:00 |
|     1005 |           3 | 2023-12-10 |       125.00 | Completed | 2025-11-06 14:30:00 |
+----------+-------------+------------+--------------+-----------+---------------------+
3 rows inserted
```

**What Happened:**
- SELECT identified 3 matching orders
- INSERT copied all columns from those rows
- `archived_at` was auto-populated with current timestamp (DEFAULT CURRENT_TIMESTAMP)
- Original rows still exist in `gs9_orders` (we only copied, not moved)

**Beginner Tip:** INSERT...SELECT is atomic - either all rows are copied or none are. It's transactional by nature!
</details>

✅ **Checkpoint:** Archive table should have 3 orders with today's timestamp in `archived_at`.

---

### Step 3: Verify Data Integrity (3 min)

**Task:** Before deleting originals, verify that ALL data was copied correctly.

<details>
<summary>💡 Your Turn</summary>

```sql
-- Count: Should match
SELECT COUNT(*) AS active_old_orders FROM gs9_orders
WHERE status = 'Completed' 
  AND order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

SELECT COUNT(*) AS archived_orders FROM gs9_orders_archive;

-- Compare data: Should be identical
SELECT order_id, customer_id, total_amount FROM gs9_orders
WHERE status = 'Completed' 
  AND order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
ORDER BY order_id;

SELECT order_id, customer_id, total_amount FROM gs9_orders_archive
ORDER BY order_id;
```

**Expected Output:**
```
-- Both counts should be 3
+-------------------+
| active_old_orders |
+-------------------+
|                 3 |
+-------------------+

+-----------------+
| archived_orders |
+-----------------+
|               3 |
+-----------------+

-- Data should match perfectly
+----------+-------------+--------------+
| order_id | customer_id | total_amount |
+----------+-------------+--------------+
|     1001 |           5 |       150.00 |
|     1003 |           8 |        75.50 |
|     1005 |           3 |       125.00 |
+----------+-------------+--------------+
```

**Safety Check:** Counts match ✅ and data is identical ✅ - safe to delete!
</details>

✅ **Checkpoint:** Verify counts and data match before proceeding!

---

### Step 4: Delete Archived Records from Active Table (4 min)

**Task:** Now delete the orders from the active table (since they're safely in the archive).

<details>
<summary>⚠️ CRITICAL: Use Transaction!</summary>

```sql
START TRANSACTION;

-- Delete old orders from active table
DELETE FROM gs9_orders
WHERE status = 'Completed'
  AND order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- Verify: Should only have 2 orders left
SELECT * FROM gs9_orders ORDER BY order_id;

-- If correct: COMMIT; if wrong: ROLLBACK;
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Wrap in transaction for safety
START TRANSACTION;

-- Delete the archived orders from active table
DELETE FROM gs9_orders
WHERE status = 'Completed'
  AND order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- Check remaining orders
SELECT * FROM gs9_orders ORDER BY order_id;

-- Verify archive still has data
SELECT COUNT(*) FROM gs9_orders_archive;

-- If everything looks good, commit
COMMIT;
```

**Expected Output (After DELETE):**
```
-- Active table now has only recent/pending orders:
+----------+-------------+------------+--------------+---------+
| order_id | customer_id | order_date | total_amount | status  |
+----------+-------------+------------+--------------+---------+
|     1002 |          12 | 2024-11-01 |       200.00 | Completed |  -- Recent
|     1004 |           5 | 2024-10-15 |       300.00 | Pending   |  -- Not completed
+----------+-------------+------------+--------------+---------+
2 rows remain (3 deleted)

-- Archive table still has 3 orders:
+---------+
| COUNT(*)|
+---------+
|       3 |
+---------+
```

**What Happened:**
- DELETE removed 3 orders (1001, 1003, 1005) from active table
- Same WHERE clause as INSERT ensured consistency
- Archive table unchanged (we didn't touch it)
- Total data preserved: 2 active + 3 archived = 5 total (no loss)

**Beginner Tip:** The WHERE clause for DELETE MUST match the WHERE clause from INSERT! Otherwise you might delete different data than you archived!
</details>

✅ **Checkpoint:** Active table has 2 orders, archive has 3. Total = 5 (same as original).

---

### Step 5: Complete Archival Pattern (2 min)

**Task:** Here's the complete production-ready archival script:

```sql
-- COMPLETE ARCHIVAL PATTERN (Production-Ready)
START TRANSACTION;

-- Step 1: Copy to archive
INSERT INTO gs9_orders_archive (order_id, customer_id, order_date, total_amount, status)
SELECT order_id, customer_id, order_date, total_amount, status
FROM gs9_orders
WHERE status = 'Completed'
  AND order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- Step 2: Verify counts match
SELECT 
    (SELECT COUNT(*) FROM gs9_orders 
     WHERE status = 'Completed' AND order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)) AS to_delete,
    (SELECT COUNT(*) FROM gs9_orders_archive WHERE archived_at > DATE_SUB(NOW(), INTERVAL 1 MINUTE)) AS just_archived;
-- Both should be the same number!

-- Step 3: If counts match, delete from active table
DELETE FROM gs9_orders
WHERE status = 'Completed'
  AND order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- Step 4: Final verification
SELECT COUNT(*) AS active_orders FROM gs9_orders;
SELECT COUNT(*) AS archived_orders FROM gs9_orders_archive;

-- If everything checks out: COMMIT
-- If something wrong: ROLLBACK
COMMIT;
```

**Key Safety Features:**
1. **Transaction:** Can rollback if anything goes wrong
2. **Count verification:** Ensures all data was copied
3. **Same WHERE clause:** INSERT and DELETE target identical rows
4. **Final check:** Verify totals before committing

---

### Real-World Applications

This archival pattern is used for:
- **Order systems:** Move old orders to reduce query time
- **Logging:** Archive old logs to keep tables small
- **Data retention:** Comply with "delete after X years" policies
- **Performance:** Keep hot data small, archive cold data
- **Auditing:** Preserve historical data while cleaning up

**Alternative: Soft Delete (No Archive Table)**
```sql
-- Add 'is_archived' column instead of separate table
ALTER TABLE gs9_orders ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;

-- "Archive" by marking, not moving
UPDATE gs9_orders 
SET is_archived = TRUE
WHERE status = 'Completed' AND order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- Query active orders
SELECT * FROM gs9_orders WHERE is_archived = FALSE;
```

**Key Takeaway:** INSERT...SELECT + DELETE is the standard pattern for moving data between tables safely!

---

## Activity 3: Customer Data Cleansing (19 min) ⏱️

**Scenario:** Your customer database has inconsistent data quality issues:
1. Email addresses with leading/trailing spaces
2. Phone numbers in various formats
3. Missing country codes (need default 'US')
4. Customer loyalty tiers need updating based on total spending

You need to clean and standardize this data!

**Real-World Analogy:** This is like organizing a messy contact list on your phone - trimming extra spaces, standardizing phone formats, and categorizing contacts by how often you interact with them.

**What You'll Learn:** UPDATE with CASE statements, string functions, and conditional logic

### Setup Code
```sql
-- Create customers table with messy data
DROP TABLE IF EXISTS gs9_customers;
CREATE TABLE gs9_customers (
    customer_id INT PRIMARY KEY,
    email VARCHAR(100),
    phone VARCHAR(20),
    country_code CHAR(2),
    loyalty_tier VARCHAR(20),
    total_spent DECIMAL(10,2)
);

INSERT INTO gs9_customers VALUES
    (1, '  alice@example.com  ', '555-1234', NULL, 'Bronze', 150.00),
    (2, 'bob@example.com', '(555) 5678', 'US', 'Bronze', 850.00),
    (3, '  charlie@example.com', '555.9012', NULL, 'Silver', 1500.00),
    (4, 'diana@example.com  ', '5553456', 'UK', 'Bronze', 3200.00),
    (5, 'eve@example.com', '555-7890', NULL, 'Gold', 5500.00);
```

---

### Step 1: Clean Email Addresses (4 min)

**Task:** Remove leading/trailing spaces from all email addresses.

<details>
<summary>💡 Hint: TRIM Function</summary>

MySQL's TRIM removes spaces from both ends:
```sql
TRIM('  text  ')  -- Returns 'text'
UPDATE table SET column = TRIM(column);
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Preview what will change
SELECT 
    customer_id,
    email AS original_email,
    TRIM(email) AS cleaned_email,
    LENGTH(email) AS original_length,
    LENGTH(TRIM(email)) AS cleaned_length
FROM gs9_customers;

-- Expected Output:
-- +-------------+---------------------------+---------------------+-----------------+-----------------+
-- | customer_id | original_email            | cleaned_email       | original_length | cleaned_length  |
-- +-------------+---------------------------+---------------------+-----------------+-----------------+
-- |           1 | '  alice@example.com  '   | 'alice@example.com' |              23 |              18 |
-- |           2 | 'bob@example.com'         | 'bob@example.com'   |              16 |              16 |
-- |           3 | '  charlie@example.com'   | 'charlie@example.com'|             22 |              20 |
-- |           4 | 'diana@example.com  '     | 'diana@example.com' |              20 |              18 |
-- |           5 | 'eve@example.com'         | 'eve@example.com'   |              16 |              16 |
-- +-------------+---------------------------+---------------------+-----------------+-----------------+

-- Apply the cleanup
UPDATE gs9_customers
SET email = TRIM(email);

-- Verify
SELECT customer_id, email FROM gs9_customers;
```

**What Happened:**
- TRIM() removed spaces from customers 1, 3, 4
- Customers 2, 5 unchanged (no extra spaces)
- Emails are now standardized for comparisons

**Beginner Tip:** Always TRIM user input! Extra spaces cause issues when searching or comparing emails.
</details>

✅ **Checkpoint:** All emails should have no leading/trailing spaces.

---

### Step 2: Standardize Phone Numbers (5 min)

**Task:** Remove all formatting characters from phone numbers (keep only digits).

<details>
<summary>💡 Hint: REPLACE Function</summary>

Use REPLACE to remove unwanted characters:
```sql
REPLACE(column, '(', '')  -- Remove (
REPLACE(column, ')', '')  -- Remove )
REPLACE(column, '-', '')  -- Remove -
REPLACE(column, '.', '')  -- Remove .
REPLACE(column, ' ', '')  -- Remove spaces

-- Chain them together:
REPLACE(REPLACE(REPLACE(column, '(', ''), ')', ''), '-', '')
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Preview phone number cleanup
SELECT 
    customer_id,
    phone AS original_phone,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(phone, '(', ''), ')', ''), '-', ''), '.', ''), ' ', '') AS cleaned_phone
FROM gs9_customers;

-- Expected Output:
-- +-------------+----------------+---------------+
-- | customer_id | original_phone | cleaned_phone |
-- +-------------+----------------+---------------+
-- |           1 | '555-1234'     | '5551234'     |
-- |           2 | '(555) 5678'   | '5555678'     |
-- |           3 | '555.9012'     | '5559012'     |
-- |           4 | '5553456'      | '5553456'     |
-- |           5 | '555-7890'     | '5557890'     |
-- +-------------+----------------+---------------+

-- Apply the cleanup
UPDATE gs9_customers
SET phone = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(phone, '(', ''), ')', ''), '-', ''), '.', ''), ' ', '');

-- Verify
SELECT customer_id, phone FROM gs9_customers;
```

**What Happened:**
- Removed all formatting: parentheses, dashes, dots, spaces
- Now all phone numbers are pure digits
- Easier to validate, search, and format consistently later

**Beginner Tip:** Store data in its simplest form (digits only), then format for display in your application!
</details>

✅ **Checkpoint:** All phone numbers should be digits only (no special characters).

---

### Step 3: Set Default Country Codes (3 min)

**Task:** Set `country_code` to 'US' for any customer with NULL country.

<details>
<summary>💡 Hint: UPDATE WHERE IS NULL</summary>

```sql
UPDATE table 
SET column = 'value' 
WHERE column IS NULL;
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Check which customers need default country
SELECT customer_id, email, country_code 
FROM gs9_customers 
WHERE country_code IS NULL;

-- Expected: Customers 1, 3, 5 have NULL

-- Set default country code
UPDATE gs9_customers
SET country_code = 'US'
WHERE country_code IS NULL;

-- Verify all customers now have country codes
SELECT customer_id, email, country_code FROM gs9_customers;
```

**Expected Output (After UPDATE):**
```
+-------------+----------------------+--------------+
| customer_id | email                | country_code |
+-------------+----------------------+--------------+
|           1 | alice@example.com    | US           |  -- Was NULL
|           2 | bob@example.com      | US           |  -- Already US
|           3 | charlie@example.com  | US           |  -- Was NULL
|           4 | diana@example.com    | UK           |  -- Already UK
|           5 | eve@example.com      | US           |  -- Was NULL
+-------------+----------------------+--------------+
```

**What Happened:**
- NULL values replaced with 'US' default
- Existing values (US, UK) unchanged
- Now every customer has a country code

**Beginner Tip:** Setting defaults for NULL values is common in data migrations!
</details>

✅ **Checkpoint:** No NULL country codes should remain.

---

### Step 4: Update Loyalty Tiers Based on Spending (5 min)

**Task:** Recalculate loyalty tiers using CASE statement:
- Bronze: $0 - $999
- Silver: $1,000 - $2,999
- Gold: $3,000 - $4,999
- Platinum: $5,000+

<details>
<summary>💡 Hint: UPDATE with CASE</summary>

```sql
UPDATE table
SET column = CASE
    WHEN condition1 THEN 'value1'
    WHEN condition2 THEN 'value2'
    ELSE 'default_value'
END;
```
</details>

<details>
<summary>✅ Solution</summary>

```sql
-- Preview new tier assignments
SELECT 
    customer_id,
    email,
    total_spent,
    loyalty_tier AS current_tier,
    CASE
        WHEN total_spent >= 5000 THEN 'Platinum'
        WHEN total_spent >= 3000 THEN 'Gold'
        WHEN total_spent >= 1000 THEN 'Silver'
        ELSE 'Bronze'
    END AS new_tier
FROM gs9_customers
ORDER BY total_spent DESC;

-- Expected Output:
-- +-------------+----------------------+-------------+--------------+----------+
-- | customer_id | email                | total_spent | current_tier | new_tier |
-- +-------------+----------------------+-------------+--------------+----------+
-- |           5 | eve@example.com      |     5500.00 | Gold         | Platinum | ⬆
-- |           4 | diana@example.com    |     3200.00 | Bronze       | Gold     | ⬆
-- |           3 | charlie@example.com  |     1500.00 | Silver       | Silver   | ✓
-- |           2 | bob@example.com      |      850.00 | Bronze       | Bronze   | ✓
-- |           1 | alice@example.com    |      150.00 | Bronze       | Bronze   | ✓
-- +-------------+----------------------+-------------+--------------+----------+

-- Apply tier recalculation
UPDATE gs9_customers
SET loyalty_tier = CASE
    WHEN total_spent >= 5000 THEN 'Platinum'
    WHEN total_spent >= 3000 THEN 'Gold'
    WHEN total_spent >= 1000 THEN 'Silver'
    ELSE 'Bronze'
END;

-- Verify changes
SELECT customer_id, email, total_spent, loyalty_tier 
FROM gs9_customers 
ORDER BY total_spent DESC;
```

**Expected Output (After UPDATE):**
```
+-------------+----------------------+-------------+--------------+
| customer_id | email                | total_spent | loyalty_tier |
+-------------+----------------------+-------------+--------------+
|           5 | eve@example.com      |     5500.00 | Platinum     |  -- Upgraded!
|           4 | diana@example.com    |     3200.00 | Gold         |  -- Upgraded!
|           3 | charlie@example.com  |     1500.00 | Silver       |  -- Correct
|           2 | bob@example.com      |      850.00 | Bronze       |  -- Correct
|           1 | alice@example.com    |      150.00 | Bronze       |  -- Correct
+-------------+----------------------+-------------+--------------+
5 rows affected
```

**What Happened:**
- Eve upgraded: Gold → Platinum ($5,500 >= $5,000)
- Diana upgraded: Bronze → Gold ($3,200 >= $3,000)
- Others remain correct based on spending
- CASE evaluated top-to-bottom (order matters!)

**Beginner Tip:** CASE conditions are checked in order. Put the most specific conditions first!
```sql
-- ✅ RIGHT: Check >= 5000 first
WHEN total_spent >= 5000 THEN 'Platinum'
WHEN total_spent >= 3000 THEN 'Gold'

-- ❌ WRONG: Would assign everyone to Bronze!
WHEN total_spent >= 0 THEN 'Bronze'  -- Matches everyone!
WHEN total_spent >= 5000 THEN 'Platinum'  -- Never reached
```
</details>

✅ **Checkpoint:** Loyalty tiers should match spending brackets correctly.

---

### Step 5: Complete Data Cleansing Script (2 min)

**Task:** Here's the full production-ready cleansing script:

```sql
-- COMPLETE DATA CLEANSING PATTERN (Production-Ready)
START TRANSACTION;

-- Step 1: Clean emails
UPDATE gs9_customers
SET email = TRIM(email);

-- Step 2: Standardize phone numbers
UPDATE gs9_customers
SET phone = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    phone, '(', ''), ')', ''), '-', ''), '.', ''), ' ', '');

-- Step 3: Set default country codes
UPDATE gs9_customers
SET country_code = 'US'
WHERE country_code IS NULL;

-- Step 4: Recalculate loyalty tiers
UPDATE gs9_customers
SET loyalty_tier = CASE
    WHEN total_spent >= 5000 THEN 'Platinum'
    WHEN total_spent >= 3000 THEN 'Gold'
    WHEN total_spent >= 1000 THEN 'Silver'
    ELSE 'Bronze'
END;

-- Final verification
SELECT * FROM gs9_customers ORDER BY customer_id;

-- If correct: COMMIT
-- If wrong: ROLLBACK
COMMIT;
```

**Performance Tip:** Could combine some UPDATEs:
```sql
-- Multiple columns in one UPDATE
UPDATE gs9_customers
SET 
    email = TRIM(email),
    phone = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        phone, '(', ''), ')', ''), '-', ''), '.', ''), ' ', ''),
    country_code = COALESCE(country_code, 'US'),  -- Sets US if NULL
    loyalty_tier = CASE
        WHEN total_spent >= 5000 THEN 'Platinum'
        WHEN total_spent >= 3000 THEN 'Gold'
        WHEN total_spent >= 1000 THEN 'Silver'
        ELSE 'Bronze'
    END;
```

---

### Real-World Applications

Data cleansing patterns are used for:
- **User registration:** Normalize emails, phone numbers
- **Data imports:** Clean messy CSV/Excel data
- **Database migrations:** Standardize legacy data
- **Data quality:** Periodic cleanup jobs
- **API integrations:** Format data for external systems

**Common String Functions for Cleansing:**
```sql
TRIM(column)                    -- Remove leading/trailing spaces
LOWER(column)                   -- Convert to lowercase
UPPER(column)                   -- Convert to uppercase
REPLACE(column, 'old', 'new')   -- Replace substrings
SUBSTRING(column, start, len)   -- Extract portion
CONCAT(col1, ' ', col2)         -- Combine columns
COALESCE(col, 'default')        -- Replace NULL with default
```

**Key Takeaway:** Data cleansing with UPDATE + CASE + string functions is essential for maintaining data quality!

---

## 🎯 Module Wrap-Up: Advanced DML Patterns

Congratulations! You've mastered advanced DML operations:

✅ **UPDATE with JOIN:** Modify data using information from multiple tables
✅ **Data Archival:** INSERT...SELECT + DELETE pattern for moving data
✅ **Data Cleansing:** CASE statements + string functions for data quality
✅ **Transaction Safety:** Protecting data with START TRANSACTION / COMMIT / ROLLBACK
✅ **Data Integrity:** Verification patterns (SELECT first, count checks)

**Key Professional Patterns Learned:**
1. **SELECT → UPDATE → SELECT** - Preview, execute, verify
2. **INSERT...SELECT → Verify → DELETE** - Safe data migration
3. **Transaction wrapping** - Ability to rollback mistakes
4. **CASE for conditional logic** - Complex update rules
5. **String functions for cleansing** - Data standardization

**Next Steps:**
- Practice these patterns on your own data
- Combine patterns (UPDATE + JOIN + CASE)
- Try Independent Practice exercises
- Explore Real-World Project for complex scenarios

**Remember:** With DML operations:
- 🔄 Use transactions for safety
- 🔍 Always verify before committing
- 📊 Check affected row counts
- 💾 Backup before bulk changes
- 📝 Document your changes

Ready for more independent practice? Move on to **Independent Practice** exercises!
