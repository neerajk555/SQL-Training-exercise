# Error Detective — DDL & Schema Design

## 📋 Before You Start

### Learning Objectives
By completing these error detective challenges, you will:
- Develop debugging skills for DDL statements
- Practice identifying constraint errors, ordering issues, and type mismatches
- Learn to recognize foreign key dependency problems
- Build troubleshooting skills for schema creation
- Understand common DDL pitfalls

### How to Approach Each Challenge
1. **Read scenario** - understand table relationships
2. **Try broken DDL** - observe error message
3. **Identify dependency** - check FK requirements
4. **Answer guiding questions** - analyze creation order
5. **Check the fix** - see correct DDL sequence

**Beginner Tip:** DDL errors often involve creation order (parent before child) or constraint violations. Read error messages carefully - they usually tell you exactly what's wrong!

---

## Error Detective Challenges

Find and fix errors in DDL statements. Each exercise has intentional bugs!

---

## Error 1: Foreign Key Creation Order

**Beginner Context:**
One of the most common DDL mistakes is creating tables in the wrong order. A foreign key must reference a table that **already exists**. Think of it like building a house - you can't build the second floor before the first floor exists!

```sql
-- Bug: What's wrong here?
CREATE TABLE ed10_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  FOREIGN KEY (customer_id) REFERENCES ed10_customers(customer_id)  -- ❌ ed10_customers doesn't exist yet!
);

CREATE TABLE ed10_customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100)
);
```

**Error Message:** `Table 'ed10_customers' doesn't exist`

**Diagnosis:** Creating child table before parent table. The `orders` table tries to reference `customers`, but `customers` hasn't been created yet!

**Why This Happens:**
- Foreign keys create dependencies between tables
- You're saying "customer_id in orders must match a customer_id in customers"
- But if customers doesn't exist, MySQL doesn't know what you're referencing

**Fix:**
```sql
-- Create parent table FIRST (the table being referenced)
CREATE TABLE ed10_customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100)
);

-- Create child table SECOND (the table with the foreign key)
CREATE TABLE ed10_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  FOREIGN KEY (customer_id) REFERENCES ed10_customers(customer_id)  -- ✅ Now ed10_customers exists!
);
```

**Rule of Thumb:**
- **Parent tables** (referenced by others) → Create FIRST
- **Child tables** (reference others) → Create AFTER parents
- When in doubt, draw the arrows: `orders → customers` means create customers first

**Verification:**
```sql
-- This works now
INSERT INTO ed10_customers VALUES (1, 'Alice');
INSERT INTO ed10_orders VALUES (100, 1);

-- This still fails (customer 2 doesn't exist) - foreign key is working!
-- INSERT INTO ed10_orders VALUES (101, 2);
```

---

## Error 2: Data Type Mismatch in FK

**Beginner Context:**
Foreign key columns must have the **exact same data type** as the column they reference. This makes sense - if you're storing a department ID in employees, it needs to be the same type as the department ID in departments!

```sql
CREATE TABLE ed10_departments (
  dept_id VARCHAR(10) PRIMARY KEY,      -- ⚠️ VARCHAR(10)
  dept_name VARCHAR(100)
);

CREATE TABLE ed10_employees (
  emp_id INT PRIMARY KEY,
  dept_id INT,                          -- ❌ INT doesn't match VARCHAR(10)
  FOREIGN KEY (dept_id) REFERENCES ed10_departments(dept_id)
);
```

**Error Message:** `Foreign key constraint is incorrectly formed`

**Diagnosis:** FK column type (INT) doesn't match referenced column type (VARCHAR). You can't compare apples to oranges!

**Why This Fails:**
- `dept_id` in departments is `VARCHAR(10)` (can store 'SALES', 'IT', etc.)
- `dept_id` in employees is `INT` (can only store 1, 2, 3, etc.)
- MySQL can't verify if INT value 1 matches VARCHAR 'SALES'
- Types must match exactly: INT with INT, VARCHAR(10) with VARCHAR(10)

**Fix Option 1 - Match the Parent (Recommended):**
```sql
CREATE TABLE ed10_employees (
  emp_id INT PRIMARY KEY,
  dept_id VARCHAR(10),                  -- ✅ Now matches parent table exactly
  FOREIGN KEY (dept_id) REFERENCES ed10_departments(dept_id)
);
```

**Fix Option 2 - Change Parent to INT (If Possible):**
```sql
-- Only do this if you haven't created child tables yet
DROP TABLE IF EXISTS ed10_departments;

CREATE TABLE ed10_departments (
  dept_id INT PRIMARY KEY,              -- Changed to INT
  dept_name VARCHAR(100)
);

CREATE TABLE ed10_employees (
  emp_id INT PRIMARY KEY,
  dept_id INT,                          -- Now matches
  FOREIGN KEY (dept_id) REFERENCES ed10_departments(dept_id)
);
```

**Common Type Mismatches to Avoid:**
- INT vs BIGINT (different sizes)
- VARCHAR(50) vs VARCHAR(100) (different lengths)
- INT vs INT UNSIGNED (signed vs unsigned)
- CHAR vs VARCHAR (fixed vs variable length)

**Rule:** Copy the EXACT data type from parent to child for foreign keys!

---

## Error 3: Invalid CHECK Constraint

```sql
CREATE TABLE ed10_products (
  product_id INT PRIMARY KEY,
  price DECIMAL(10,2) CHECK (price > 0 AND price < quantity)
);
```

**Error Message:** `Unknown column 'quantity' in 'check constraint'`

**Diagnosis:** CHECK references non-existent column.

**Fix:**
```sql
CREATE TABLE ed10_products (
  product_id INT PRIMARY KEY,
  price DECIMAL(10,2) CHECK (price > 0),
  quantity INT CHECK (quantity >= 0)
);
```

---

## Error 4: Duplicate Column Name

```sql
ALTER TABLE ed10_users
ADD COLUMN email VARCHAR(100);

ALTER TABLE ed10_users
ADD COLUMN email VARCHAR(150);
```

**Error Message:** `Duplicate column name 'email'`

**Diagnosis:** Trying to add column that already exists.

**Fix:**
```sql
-- Either modify existing column
ALTER TABLE ed10_users
MODIFY COLUMN email VARCHAR(150);

-- Or use different name
ALTER TABLE ed10_users
ADD COLUMN secondary_email VARCHAR(150);
```

---

## Error 5: Dropping Table with FK Dependencies

**Beginner Context:**
You can't delete a table if other tables depend on it via foreign keys. It's like trying to demolish a building's foundation while the upper floors are still standing - MySQL won't let you create orphaned tables!

```sql
CREATE TABLE ed10_authors (
  author_id INT PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE ed10_books (
  book_id INT PRIMARY KEY,
  author_id INT,
  FOREIGN KEY (author_id) REFERENCES ed10_authors(author_id)  -- books depends on authors
);

-- Try to drop the parent table
DROP TABLE ed10_authors;  -- ❌ FAILS!
```

**Error Message:** `Cannot drop table 'ed10_authors': foreign key constraint fails`  
Or: `Cannot delete or update a parent row: a foreign key constraint fails`

**Diagnosis:** Can't drop `authors` table because `books` table still references it via foreign key. The dependency must be removed first.

**Why This Protection Exists:**
- If you deleted `authors`, what would happen to `author_id` in `books`?
- The foreign key would point to nothing - an "orphaned" reference
- MySQL prevents this to maintain referential integrity

**Fix Option 1 - Drop in Correct Order (Most Common):**
```sql
-- Drop child tables first (tables with foreign keys)
DROP TABLE ed10_books;

-- Then drop parent tables (tables being referenced)
DROP TABLE ed10_authors;

-- Remember: Reverse order of creation!
-- Created: authors → books
-- Drop: books → authors
```

**Fix Option 2 - Drop Foreign Key Constraint First:**
```sql
-- Find the constraint name
SHOW CREATE TABLE ed10_books;
-- Output shows: CONSTRAINT `ed10_books_ibfk_1` FOREIGN KEY...

-- Drop the constraint
ALTER TABLE ed10_books DROP FOREIGN KEY ed10_books_ibfk_1;

-- Now you can drop authors
DROP TABLE ed10_authors;

-- Books table still exists but without FK constraint
```

**Fix Option 3 - Use CASCADE (Advanced):**
```sql
-- When creating the FK, you can specify CASCADE behavior
DROP TABLE IF EXISTS ed10_books;
DROP TABLE IF EXISTS ed10_authors;

CREATE TABLE ed10_authors (
  author_id INT PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE ed10_books (
  book_id INT PRIMARY KEY,
  author_id INT,
  FOREIGN KEY (author_id) REFERENCES ed10_authors(author_id)
    ON DELETE CASCADE  -- If author deleted, automatically delete their books
);

-- Now this works (and deletes all books by that author):
INSERT INTO ed10_authors VALUES (1, 'George Orwell');
INSERT INTO ed10_books VALUES (100, 1);
DELETE FROM ed10_authors WHERE author_id = 1;  -- Books also deleted!
```

**Best Practice:**
- Always drop tables in **reverse dependency order**
- Child tables (with FKs) first
- Parent tables (referenced) last
- Same as CREATE but backwards!

**Quick Rule:**
```
CREATE order: Parent → Child
DROP order:   Child → Parent
```

---

## Error 6: Missing NOT NULL on Required Field

```sql
CREATE TABLE ed10_users (
  user_id INT PRIMARY KEY,
  username VARCHAR(50) UNIQUE
);

INSERT INTO ed10_users (user_id) VALUES (1);
-- This succeeds but username is NULL!
```

**Issue:** Username should be required but isn't enforced.

**Fix:**
```sql
CREATE TABLE ed10_users (
  user_id INT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL  -- Add NOT NULL
);
```

---

## Additional Common Errors

### Error 7: Using Reserved Keywords as Names
```sql
-- ❌ This fails - "order" is a reserved keyword
CREATE TABLE order (
  order_id INT PRIMARY KEY
);
```
**Fix:** Use backticks or choose different name:
```sql
-- ✅ Option 1: Use backticks
CREATE TABLE `order` (
  order_id INT PRIMARY KEY
);

-- ✅ Option 2: Better - use plural or prefix
CREATE TABLE orders (
  order_id INT PRIMARY KEY
);
```

### Error 8: Forgetting AUTO_INCREMENT on PK
```sql
CREATE TABLE users (
  user_id INT PRIMARY KEY,  -- Must manually provide IDs
  username VARCHAR(50)
);

INSERT INTO users (username) VALUES ('alice');  -- ❌ Fails - user_id required
```
**Fix:** Add AUTO_INCREMENT:
```sql
CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50)
);

INSERT INTO users (username) VALUES ('alice');  -- ✅ Works - user_id auto-generated
```

### Error 9: CHECK Constraint on Older MySQL
```sql
-- On MySQL < 8.0.16, this silently does nothing!
CREATE TABLE products (
  price DECIMAL(10,2) CHECK (price > 0)
);

INSERT INTO products VALUES (-10.00);  -- Succeeds when it shouldn't!
```
**Fix:** Upgrade MySQL or use triggers for validation.

---

**DDL Debugging Checklist:**
- [ ] Read error messages carefully—they tell you what's wrong
- [ ] Create parent tables before child tables (follow dependency order)
- [ ] Match FK data types **exactly** (including size and signed/unsigned)
- [ ] Check column exists before referencing in constraints
- [ ] Drop child tables before parent tables (reverse of creation order)
- [ ] Use NOT NULL for required fields (don't rely on application validation alone)
- [ ] Test constraints by trying to violate them
- [ ] Use backticks for reserved keywords or avoid them entirely
- [ ] Verify MySQL version for CHECK constraint support (8.0.16+)
- [ ] Name constraints explicitly for easier maintenance
- [ ] Use `SHOW CREATE TABLE` to inspect constraints
- [ ] Use `DESCRIBE` or `SHOW COLUMNS` to verify column types

**Pro Tip:** Always test your schema with both valid and invalid data to ensure constraints work as expected!