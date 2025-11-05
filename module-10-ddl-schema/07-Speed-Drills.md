# Speed Drills — DDL & Schema Design (2 min each)

**Purpose:** Build muscle memory for common DDL operations. Set a 2-minute timer for each drill!

**How to Practice:**
1. Read the task
2. Try to write the SQL from memory
3. Check your answer
4. If wrong, practice that drill 3 more times

**Beginner Tip:** These are the commands you'll use most often. Memorize the patterns!

---

## Drill 1: Create Basic Table
**Task:** Create `products` table with id (PK, auto-increment), name (VARCHAR 100), price (DECIMAL).

**Pattern to Remember:**
```
CREATE TABLE table_name (
  column_name data_type constraints
);
```

```sql
CREATE TABLE sd10_products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  price DECIMAL(10,2)
);
```

---

## Drill 2: Add Column
**Task:** Add `stock_quantity` (INT, default 0) to existing `products` table.

**Pattern to Remember:**
```
ALTER TABLE table_name ADD COLUMN column_name data_type constraints;
```

```sql
ALTER TABLE sd10_products ADD COLUMN stock_quantity INT DEFAULT 0;
```

**Note:** `COLUMN` keyword is optional in MySQL: `ADD stock_quantity INT DEFAULT 0` also works.

---

## Drill 3: Add UNIQUE Constraint
**Task:** Add UNIQUE constraint on `name` column in `products` table.

**Pattern to Remember:**
```
ALTER TABLE table_name ADD CONSTRAINT constraint_name UNIQUE (column_name);
```

```sql
ALTER TABLE sd10_products ADD CONSTRAINT uk_name UNIQUE (name);
```

**Alternative (without naming):**
```sql
ALTER TABLE sd10_products ADD UNIQUE (name);
-- MySQL auto-generates constraint name
```

---

## Drill 4: Add Foreign Key
**Task:** Create `orders` table with order_id and customer_id (FK to customers(customer_id)).

**Pattern to Remember:**
```
FOREIGN KEY (local_column) REFERENCES other_table(other_column)
```

```sql
-- Assumes customers table already exists!
CREATE TABLE sd10_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

---

## Drill 5: Modify Column Type
**Task:** Change `name` column in `products` to VARCHAR(200).

**Pattern to Remember:**
```
ALTER TABLE table_name MODIFY COLUMN column_name new_data_type;
```

```sql
ALTER TABLE sd10_products MODIFY COLUMN name VARCHAR(200);
```

**Note:** MODIFY keeps the same column name. Use CHANGE to rename: `CHANGE old_name new_name data_type`

---

## Drill 6: Drop Column
**Task:** Remove `stock_quantity` column from `products`.

**Pattern to Remember:**
```
ALTER TABLE table_name DROP COLUMN column_name;
```

```sql
ALTER TABLE sd10_products DROP COLUMN stock_quantity;
```

**Warning:** This permanently deletes the column and ALL its data. No undo!

---

## Drill 7: Create with CHECK Constraint
**Task:** Create `employees` table with salary that must be > 0.

**Pattern to Remember:**
```
column_name data_type CHECK (condition)
```

```sql
CREATE TABLE sd10_employees (
  emp_id INT PRIMARY KEY,
  salary DECIMAL(10,2) CHECK (salary > 0)  -- MySQL 8.0.16+
);
```

---

## Drill 8: Add ENUM Column
**Task:** Add `status` column to `orders` (ENUM: pending, shipped, delivered).

**Pattern to Remember:**
```
ENUM('value1', 'value2', 'value3')
```

```sql
ALTER TABLE sd10_orders 
ADD COLUMN status ENUM('pending', 'shipped', 'delivered') DEFAULT 'pending';
```

**Use Case:** ENUM for fixed set of values (status, type, category)

---

## Drill 9: Composite Primary Key
**Task:** Create `enrollment` table with composite PK on (student_id, course_id).

**Pattern to Remember:**
```
PRIMARY KEY (column1, column2)
```

```sql
CREATE TABLE sd10_enrollment (
  student_id INT,
  course_id INT,
  PRIMARY KEY (student_id, course_id)
);
```

**Use Case:** Junction tables for many-to-many relationships

---

## Drill 10: Drop Table Safely
**Task:** Drop `old_data` table only if it exists.

**Pattern to Remember:**
```
DROP TABLE IF EXISTS table_name;
```

```sql
DROP TABLE IF EXISTS old_data;
```

**Why IF EXISTS:** Prevents error if table doesn't exist (useful in scripts)

---

## Bonus Drill 11: Add Index
**Task:** Add index on `email` column in `users` table.

```sql
CREATE INDEX idx_email ON users(email);
-- Or using ALTER: ALTER TABLE users ADD INDEX idx_email (email);
```

---

## Bonus Drill 12: Add NOT NULL Constraint
**Task:** Make `email` column required (NOT NULL) in existing `users` table.

```sql
ALTER TABLE users MODIFY COLUMN email VARCHAR(100) NOT NULL;
```

---

**Speed Tips for Mastery:**
- **Memorize patterns**: CREATE, ALTER, DROP + their specific syntax
- **Practice typing** constraints without looking at reference
- **Use IF EXISTS** for DROP statements (prevents errors)
- **Remember**: AUTO_INCREMENT and PRIMARY KEY typically go together
- **Foreign keys**: Always match data types exactly
- **Test immediately**: After creating, run DESCRIBE or SHOW CREATE TABLE
- **Keyboard shortcuts**: Learn your IDE's autocomplete features

**Common Command Structure:**
```
Action What  Details
CREATE TABLE schema
ALTER  TABLE changes
DROP   TABLE conditionally
```

**Practice Schedule:**
- Day 1: Drills 1-5
- Day 2: Drills 6-10
- Day 3: All drills, random order
- Day 4: Time yourself - can you do each in under 30 seconds?