# Error Detective — DDL & Schema Design

Find and fix errors in DDL statements. Each exercise has intentional bugs!

---

## Error 1: Foreign Key Creation Order

```sql
-- Bug: What's wrong here?
CREATE TABLE ed10_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  FOREIGN KEY (customer_id) REFERENCES ed10_customers(customer_id)
);

CREATE TABLE ed10_customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100)
);
```

**Error Message:** `Table 'ed10_customers' doesn't exist`

**Diagnosis:** Creating child table before parent table.

**Fix:**
```sql
-- Create parent first
CREATE TABLE ed10_customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE ed10_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  FOREIGN KEY (customer_id) REFERENCES ed10_customers(customer_id)
);
```

---

## Error 2: Data Type Mismatch in FK

```sql
CREATE TABLE ed10_departments (
  dept_id VARCHAR(10) PRIMARY KEY,
  dept_name VARCHAR(100)
);

CREATE TABLE ed10_employees (
  emp_id INT PRIMARY KEY,
  dept_id INT,
  FOREIGN KEY (dept_id) REFERENCES ed10_departments(dept_id)
);
```

**Error Message:** `Foreign key constraint is incorrectly formed`

**Diagnosis:** FK column type (INT) doesn't match referenced column type (VARCHAR).

**Fix:**
```sql
CREATE TABLE ed10_employees (
  emp_id INT PRIMARY KEY,
  dept_id VARCHAR(10),  -- Match the parent type
  FOREIGN KEY (dept_id) REFERENCES ed10_departments(dept_id)
);
```

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

```sql
CREATE TABLE ed10_authors (
  author_id INT PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE ed10_books (
  book_id INT PRIMARY KEY,
  author_id INT,
  FOREIGN KEY (author_id) REFERENCES ed10_authors(author_id)
);

-- Try to drop
DROP TABLE ed10_authors;
```

**Error Message:** `Cannot drop table 'ed10_authors': foreign key constraint fails`

**Diagnosis:** Can't drop table referenced by FK in another table.

**Fix:**
```sql
-- Drop child first, then parent
DROP TABLE ed10_books;
DROP TABLE ed10_authors;

-- Or drop FK constraint first
ALTER TABLE ed10_books DROP FOREIGN KEY fk_name;
DROP TABLE ed10_authors;
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

**Debugging Tips:**
1. Read error messages carefully—they tell you what's wrong
2. Create parent tables before child tables
3. Match FK data types exactly
4. Check column exists before referencing in constraints
5. Drop child tables before parent tables
6. Use NOT NULL for required fields
7. Test constraints by trying to violate them