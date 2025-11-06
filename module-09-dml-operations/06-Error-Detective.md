# Error Detective: Fix Broken DML Statements (6 challenges)

## 📋 Before You Start

### Learning Objectives
By completing these error detective challenges, you will:
- Develop debugging skills for INSERT, UPDATE, DELETE errors
- Practice identifying missing WHERE clauses and dangerous operations
- Learn to recognize data integrity violations
- Build troubleshooting skills for data modification queries
- Understand critical DML safety practices

### How to Approach Each Challenge
1. **READ THE WARNING** - these errors can destroy data!
2. **Run in transaction** - always START TRANSACTION first
3. **Test with SELECT** - verify WHERE clause before UPDATE/DELETE
4. **Check affected rows** - ensure count matches expectation
5. **ROLLBACK if wrong** - undo dangerous changes

**⚠️ CRITICAL SAFETY:** These examples show common mistakes that can PERMANENTLY damage data. Always use transactions when testing!

**Beginner Tip:** DML errors are the most dangerous because they modify data. ALWAYS test with SELECT first, use WHERE clauses, and work within transactions. Build safe habits now!

---

## Error Detective Challenges

**Format per challenge:** Scenario, sample data, broken query, error message/symptom, expected outcome, guiding questions, and fixed solution with explanation.

---

## Challenge 1: The Accidental DELETE ALL

**Scenario:** You want to delete only cancelled orders, but accidentally delete EVERYTHING.

### Sample Data
```sql
DROP TABLE IF EXISTS ed9_orders;
CREATE TABLE ed9_orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    status VARCHAR(20),
    total_amount DECIMAL(10,2)
);
INSERT INTO ed9_orders VALUES
(101, 'Alice', 'completed', 1200.00),
(102, 'Bob', 'cancelled', 50.00),
(103, 'Carol', 'shipped', 300.00),
(104, 'David', 'cancelled', 75.00),
(105, 'Eve', 'completed', 450.00);
```

### Broken Query
```sql
-- Programmer's intent: Delete only cancelled orders
-- But they wrote this:
DELETE FROM ed9_orders; -- BUG: Missing WHERE clause!
```

### Error Message or Symptom
- **No error thrown!** MySQL happily deletes all 5 rows
- Message: "5 rows affected" (when you only wanted 2!)
- Result: **ALL orders gone!**

### Expected Output
Should only delete orders 102 and 104 (the cancelled ones), leaving 3 orders in the table.

### Guiding Questions
1. What happens when you omit WHERE in DELETE?
2. How can you test which rows will be deleted before actually deleting?
3. What safety mechanism can prevent accidental deletion?

<details>
<summary>✅ Fixed Solution</summary>

```sql
-- ALWAYS test with SELECT first!
SELECT * FROM ed9_orders WHERE status = 'cancelled';
-- Should show orders 102 and 104

-- Use transaction for safety
START TRANSACTION;

-- NOW delete with proper WHERE clause
DELETE FROM ed9_orders
WHERE status = 'cancelled';

-- Verify: should show 2 rows affected
SELECT * FROM ed9_orders;  -- Should have 3 rows remaining

-- If correct, commit; otherwise rollback
COMMIT;  -- or ROLLBACK if something's wrong
```

**Explanation:**
- **WHERE clause is MANDATORY** for targeted deletes
- Without WHERE, DELETE affects **ALL rows**
- Always test with SELECT first
- Use transactions so you can ROLLBACK mistakes
- In production, consider "soft deletes" (UPDATE status = 'deleted') instead of actual DELETE

**Prevention:**
- Set `sql_safe_updates = 1` to prevent DELETE/UPDATE without WHERE
- Always use transactions
- Test on staging data first
</details>

---

## Challenge 2: UPDATE Without WHERE - Price Disaster

**Scenario:** You want to increase laptop prices by 10%, but accidentally change ALL product prices.

### Sample Data
```sql
DROP TABLE IF EXISTS ed9_products;
CREATE TABLE ed9_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(8,2)
);
INSERT INTO ed9_products VALUES
(1, 'Laptop Pro', 'electronics', 1200.00),
(2, 'Mouse', 'electronics', 25.00),
(3, 'Desk Chair', 'furniture', 199.99),
(4, 'Notebook', 'stationery', 5.00),
(5, 'Monitor', 'electronics', 300.00);
```

### Broken Query
```sql
-- Intent: Increase only laptop prices by 10%
-- But wrote this:
UPDATE ed9_products
SET price = price * 1.10;  -- BUG: Missing WHERE clause!
```

### Error Message or Symptom
- **No error!** All 5 rows updated
- Message: "5 rows affected"
- Result: Mouse now costs $27.50, Chair $219.99, Notebook $5.50 (all increased!)

### Expected Output
Only product 1 (Laptop Pro) should be updated from $1200.00 to $1320.00.

### Guiding Questions
1. What happens when UPDATE has no WHERE clause?
2. How do you target specific rows in an UPDATE?
3. What if the product name changes later? Better to use product_id or category?

<details>
<summary>✅ Fixed Solution</summary>

```sql
-- Test first: see which rows match
SELECT product_id, product_name, price, price * 1.10 AS new_price
FROM ed9_products
WHERE product_name = 'Laptop Pro';
-- Should show only product 1

START TRANSACTION;

-- Update with proper WHERE clause
UPDATE ed9_products
SET price = price * 1.10
WHERE product_name = 'Laptop Pro';

-- Or better, use ID (more reliable):
-- UPDATE ed9_products
-- SET price = price * 1.10
-- WHERE product_id = 1;

-- Verify
SELECT * FROM ed9_products WHERE product_id = 1;

COMMIT;
```

**Explanation:**
- UPDATE without WHERE affects **ALL rows**
- Always specify WHERE to target specific rows
- Using `product_id` is safer than name (names can change)
- Test with SELECT first to verify target rows
- Calculations like `price * 1.10` are fine, but need proper WHERE

**Alternative Solutions:**
```sql
-- Update all laptops (if multiple):
UPDATE ed9_products
SET price = price * 1.10
WHERE category = 'electronics' AND product_name LIKE '%Laptop%';

-- Update by ID (safest):
UPDATE ed9_products
SET price = price * 1.10
WHERE product_id IN (1);
```
</details>

---

## Challenge 3: Foreign Key Violation - Orphaned Order

**Scenario:** Trying to insert an order for a customer who doesn't exist.

### Sample Data
```sql
DROP TABLE IF EXISTS ed9_customers;
CREATE TABLE ed9_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100)
);
INSERT INTO ed9_customers VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Carol');

DROP TABLE IF EXISTS ed9_customer_orders;
CREATE TABLE ed9_customer_orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_total DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES ed9_customers(customer_id)
);
INSERT INTO ed9_customer_orders VALUES
(101, 1, 500.00),
(102, 2, 300.00);
```

### Broken Query
```sql
-- Trying to insert order for customer_id 999 (doesn't exist!)
INSERT INTO ed9_customer_orders (order_id, customer_id, order_total)
VALUES (103, 999, 750.00);  -- BUG: customer 999 doesn't exist!
```

### Error Message
```
ERROR 1452 (23000): Cannot add or update a child row: 
a foreign key constraint fails (`database`.`ed9_customer_orders`, 
CONSTRAINT `ed9_customer_orders_ibfk_1` FOREIGN KEY (`customer_id`) 
REFERENCES `ed9_customers` (`customer_id`))
```

### Expected Output
Insert should succeed with a valid customer_id (1, 2, or 3).

### Guiding Questions
1. What is a foreign key constraint?
2. Why does MySQL reject this INSERT?
3. How can you check if a customer exists before inserting an order?

<details>
<summary>✅ Fixed Solution</summary>

```sql
-- Option 1: Verify customer exists first
SELECT customer_id, customer_name 
FROM ed9_customers 
WHERE customer_id = 3;
-- Customer exists, safe to use

-- Insert with valid customer_id
INSERT INTO ed9_customer_orders (order_id, customer_id, order_total)
VALUES (103, 3, 750.00);  -- Use existing customer (1, 2, or 3)

-- Option 2: Use INSERT with validation (MySQL 8.0+)
-- Only insert if customer exists
INSERT INTO ed9_customer_orders (order_id, customer_id, order_total)
SELECT 103, customer_id, 750.00
FROM ed9_customers
WHERE customer_id = 3;

-- Option 3: Create customer first, then order
START TRANSACTION;

-- Insert new customer
INSERT INTO ed9_customers (customer_id, customer_name)
VALUES (4, 'David');

-- Now insert order
INSERT INTO ed9_customer_orders (order_id, customer_id, order_total)
VALUES (103, 4, 750.00);

COMMIT;
```

**Explanation:**
- **Foreign keys enforce referential integrity**
- customer_id in orders MUST exist in customers table
- MySQL rejects INSERTs that violate foreign key constraints
- Always verify parent record exists before inserting child
- Or insert parent first, then child

**Prevention:**
- Check for existing records before INSERT
- Handle validation in application layer
- Use transactions to ensure both parent and child inserted together
- Consider using INSERT...SELECT for safety
</details>

---

## Challenge 4: Duplicate Primary Key Error

**Scenario:** Trying to insert a product with an ID that already exists.

### Sample Data
```sql
DROP TABLE IF EXISTS ed9_inventory;
CREATE TABLE ed9_inventory (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    quantity INT
);
INSERT INTO ed9_inventory VALUES
(1, 'Laptop', 50),
(2, 'Mouse', 200),
(3, 'Keyboard', 150);
```

### Broken Query
```sql
-- Trying to insert product with ID 2 (already exists!)
INSERT INTO ed9_inventory (product_id, product_name, quantity)
VALUES (2, 'Monitor', 75);  -- BUG: product_id 2 already exists!
```

### Error Message
```
ERROR 1062 (23000): Duplicate entry '2' for key 'PRIMARY'
```

### Expected Output
Either skip the insert, update existing record, or use a new ID.

### Guiding Questions
1. Why can't you have duplicate primary keys?
2. What's the difference between INSERT, REPLACE, and INSERT...ON DUPLICATE KEY UPDATE?
3. When should you use AUTO_INCREMENT?

<details>
<summary>✅ Fixed Solutions</summary>

```sql
-- Solution 1: Use different ID
INSERT INTO ed9_inventory (product_id, product_name, quantity)
VALUES (4, 'Monitor', 75);  -- Use new ID

-- Solution 2: Use AUTO_INCREMENT (let MySQL assign ID)
ALTER TABLE ed9_inventory MODIFY product_id INT AUTO_INCREMENT;

INSERT INTO ed9_inventory (product_name, quantity)
VALUES ('Monitor', 75);  -- MySQL assigns next available ID

-- Solution 3: REPLACE (deletes old, inserts new)
REPLACE INTO ed9_inventory (product_id, product_name, quantity)
VALUES (2, 'Monitor', 75);  -- Deletes Mouse, inserts Monitor

-- Solution 4: INSERT...ON DUPLICATE KEY UPDATE (upsert)
INSERT INTO ed9_inventory (product_id, product_name, quantity)
VALUES (2, 'Monitor', 75)
ON DUPLICATE KEY UPDATE 
    product_name = VALUES(product_name),
    quantity = VALUES(quantity);
-- If ID 2 exists, update it; if not, insert

-- Solution 5: INSERT IGNORE (skip if exists)
INSERT IGNORE INTO ed9_inventory (product_id, product_name, quantity)
VALUES (2, 'Monitor', 75);  -- Silently skips if ID 2 exists
```

**Explanation:**
- **Primary keys must be unique**
- Attempting to insert duplicate key raises error
- Several strategies to handle:
  - **INSERT**: Fails on duplicate (strict)
  - **REPLACE**: Deletes old, inserts new (destructive)
  - **INSERT...ON DUPLICATE KEY UPDATE**: Update if exists, insert if not (upsert)
  - **INSERT IGNORE**: Skip duplicates silently
  - **AUTO_INCREMENT**: Let database assign unique IDs

**Best Practices:**
- Use AUTO_INCREMENT for surrogate keys
- Use INSERT...ON DUPLICATE KEY UPDATE for upserts
- Avoid REPLACE unless you want to delete existing data
- Check for existence before INSERT if unsure
</details>

---

## Challenge 5: Type Mismatch in INSERT

**Scenario:** Trying to insert incompatible data types.

### Sample Data
```sql
DROP TABLE IF EXISTS ed9_employees;
CREATE TABLE ed9_employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    salary DECIMAL(10,2),
    hire_date DATE
);
INSERT INTO ed9_employees VALUES
(1, 'Alice', 75000.00, '2023-01-15'),
(2, 'Bob', 68000.00, '2023-03-20');
```

### Broken Query
```sql
-- Trying to insert with wrong data types
INSERT INTO ed9_employees (emp_id, emp_name, salary, hire_date)
VALUES (3, 'Carol', 'seventy thousand', 'March 2024');  -- BUG: Wrong types!
```

### Error Message
```
ERROR 1366 (HY000): Incorrect decimal value: 'seventy thousand' for column 'salary'
-- Or similar type conversion error
```

### Expected Output
Insert Carol with salary 70000.00 and hire_date '2024-03-01'.

### Guiding Questions
1. What data types does each column expect?
2. How should dates be formatted in MySQL?
3. What happens when you try to insert string into numeric column?

<details>
<summary>✅ Fixed Solution</summary>

```sql
-- Correct data types
INSERT INTO ed9_employees (emp_id, emp_name, salary, hire_date)
VALUES (3, 'Carol', 70000.00, '2024-03-01');
-- emp_id: INT
-- emp_name: VARCHAR (string)
-- salary: DECIMAL (numeric, 2 decimals)
-- hire_date: DATE (format: 'YYYY-MM-DD')

-- Verify
SELECT * FROM ed9_employees;
```

**Explanation:**
- Each column has a specific data type
- MySQL expects values matching those types:
  - **INT**: Whole numbers (1, 2, 3)
  - **DECIMAL(10,2)**: Numbers with decimals (70000.00)
  - **VARCHAR**: Text strings ('Carol')
  - **DATE**: Dates in 'YYYY-MM-DD' format ('2024-03-01')
- Strings like 'seventy thousand' can't convert to DECIMAL
- Date strings must match 'YYYY-MM-DD' format

**Common Type Issues:**
```sql
-- ❌ Wrong date format
INSERT INTO ed9_employees VALUES (4, 'David', 65000.00, '03/01/2024');

-- ✅ Correct date format
INSERT INTO ed9_employees VALUES (4, 'David', 65000.00, '2024-03-01');

-- ❌ String in numeric column
INSERT INTO ed9_employees VALUES (5, 'Eve', 'sixty-five thousand', '2024-04-01');

-- ✅ Numeric value
INSERT INTO ed9_employees VALUES (5, 'Eve', 65000.00, '2024-04-01');

-- ❌ Number without decimal places (strict mode might complain)
INSERT INTO ed9_employees VALUES (6, 'Frank', 70000, '2024-05-01');

-- ✅ Explicit decimal
INSERT INTO ed9_employees VALUES (6, 'Frank', 70000.00, '2024-05-01');
```

**Best Practices:**
- Always match data types
- Use 'YYYY-MM-DD' for dates
- Include decimal places for DECIMAL columns
- Quote strings, don't quote numbers
- Test with sample data first
</details>

---

## Challenge 6: UPDATE with Wrong JOIN Logic

**Scenario:** Update product prices based on category, but the JOIN logic is wrong.

### Sample Data
```sql
DROP TABLE IF EXISTS ed9_products_v2;
CREATE TABLE ed9_products_v2 (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    price DECIMAL(8,2)
);
INSERT INTO ed9_products_v2 VALUES
(1, 'Laptop', 1, 1200.00),
(2, 'Mouse', 1, 25.00),
(3, 'Chair', 2, 199.99),
(4, 'Desk', 2, 350.00);

DROP TABLE IF EXISTS ed9_categories;
CREATE TABLE ed9_categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50),
    discount_rate DECIMAL(4,2)
);
INSERT INTO ed9_categories VALUES
(1, 'Electronics', 0.10),  -- 10% discount
(2, 'Furniture', 0.05);     -- 5% discount
```

### Broken Query
```sql
-- Intent: Apply category-specific discounts
-- But wrote this:
UPDATE ed9_products_v2 p, ed9_categories c
SET p.price = p.price * (1 - c.discount_rate);
-- BUG: Missing JOIN condition! Creates Cartesian product
```

### Error Message or Symptom
- No error, but **wrong results!**
- Every product gets updated multiple times (Cartesian product)
- Prices become nonsensical
- Example: Laptop might become $1080 → $1026 → ... (applied discount twice!)

### Expected Output
- Electronics (Laptop, Mouse): 10% discount
- Furniture (Chair, Desk): 5% discount

### Guiding Questions
1. What happens when you JOIN tables without ON condition?
2. What is a Cartesian product?
3. How should UPDATE with JOIN be written?

<details>
<summary>✅ Fixed Solution</summary>

```sql
-- Test SELECT first to verify JOIN logic
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    p.price AS old_price,
    p.price * (1 - c.discount_rate) AS new_price,
    c.discount_rate
FROM ed9_products_v2 p
INNER JOIN ed9_categories c ON p.category_id = c.category_id;

-- Start transaction
START TRANSACTION;

-- UPDATE with proper JOIN condition
UPDATE ed9_products_v2 p
INNER JOIN ed9_categories c ON p.category_id = c.category_id
SET p.price = p.price * (1 - c.discount_rate);

-- Verify results
SELECT * FROM ed9_products_v2;
-- Laptop: 1080.00 (10% off 1200)
-- Mouse: 22.50 (10% off 25)
-- Chair: 189.99 (5% off 199.99)
-- Desk: 332.50 (5% off 350)

COMMIT;
```

**Explanation:**
- **Missing JOIN condition creates Cartesian product**: Every product matched with every category
- Without `ON p.category_id = c.category_id`, each product updated multiple times
- Proper JOIN condition ensures each product matched with correct category only
- Always test UPDATE...JOIN with SELECT first
- Use INNER JOIN for clarity

**Warning Signs:**
- More rows affected than expected
- "4 rows affected" becomes "8 rows affected" (each row hit twice!)
- Prices don't match expected calculations

**Alternative Syntax:**
```sql
-- Using WHERE instead of ON (older style)
UPDATE ed9_products_v2 p, ed9_categories c
SET p.price = p.price * (1 - c.discount_rate)
WHERE p.category_id = c.category_id;  -- JOIN condition in WHERE

-- More explicit (recommended)
UPDATE ed9_products_v2 p
INNER JOIN ed9_categories c 
    ON p.category_id = c.category_id
SET p.price = p.price * (1 - c.discount_rate);
```
</details>

---

## 🎯 Key Takeaways from All Challenges

1. **Always use WHERE with UPDATE/DELETE** (or you'll affect ALL rows!)
2. **Test with SELECT first** before running UPDATE/DELETE
3. **Use transactions** (START TRANSACTION, COMMIT, ROLLBACK)
4. **Verify foreign key constraints** before INSERT
5. **Check for duplicate keys** before INSERT
6. **Match data types** (INT, DECIMAL, VARCHAR, DATE)
7. **Use proper JOIN conditions** in UPDATE...JOIN
8. **Enable safe_updates mode** to prevent accidents
9. **Verify affected row count** after operations
10. **Always have backups** before bulk changes!

## 🛡️ Safety Commands

```sql
-- Enable safe update mode (prevents UPDATE/DELETE without WHERE or LIMIT)
SET sql_safe_updates = 1;

-- Transaction template
START TRANSACTION;
    -- Your DML here
    -- Check results
COMMIT;  -- or ROLLBACK;

-- Dry run template (test before executing)
-- 1. Write SELECT to see target rows
SELECT * FROM table WHERE condition;
-- 2. Convert to UPDATE/DELETE
-- UPDATE table SET ... WHERE condition;
-- 3. Verify row count matches expectation
```

**Remember:** DML operations are permanent! Measure twice, cut once!