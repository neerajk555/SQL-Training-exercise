# Quick Warm-Ups — DDL & Schema Design (5–10 min each)

Each exercise includes setup, task, expected output, and solution. Run each in its own session.

**Beginner Tip:** DDL creates database structure. CREATE makes tables, ALTER modifies them, DROP removes them. Always plan your schema before creating! Use constraints to enforce data integrity.

---

## 1) Create Simple Table — 5 min
Scenario: Create a products table with basic columns.

Task: Create a table with product_id (primary key, auto-increment), product_name (up to 100 chars, required), and price (decimal with 2 decimal places).

Expected structure:
```
product_id INT AUTO_INCREMENT PRIMARY KEY
product_name VARCHAR(100) NOT NULL
price DECIMAL(10,2)
```

Solution:
```sql
DROP TABLE IF EXISTS wu10_products;
CREATE TABLE wu10_products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  product_name VARCHAR(100) NOT NULL,
  price DECIMAL(10,2)
);

-- Verify structure
DESCRIBE wu10_products;
```

---

## 2) Add New Column — 6 min
Scenario: Add a stock quantity column to existing table.

Sample data:
```sql
DROP TABLE IF EXISTS wu10_inventory;
CREATE TABLE wu10_inventory (
  item_id INT PRIMARY KEY,
  item_name VARCHAR(100)
);
INSERT INTO wu10_inventory VALUES (1, 'Widget');
```

Task: Add a `quantity` column (INT, default 0, NOT NULL).

Solution:
```sql
-- Add column with default value
ALTER TABLE wu10_inventory 
ADD COLUMN quantity INT NOT NULL DEFAULT 0;

-- Verify
DESCRIBE wu10_inventory;
SELECT * FROM wu10_inventory;
```

---

## 3) Add Foreign Key Constraint — 7 min
Scenario: Link orders to customers with foreign key.

Sample data:
```sql
DROP TABLE IF EXISTS wu10_customers;
CREATE TABLE wu10_customers (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(100)
);

DROP TABLE IF EXISTS wu10_orders;
CREATE TABLE wu10_orders (
  order_id INT PRIMARY KEY,
  order_date DATE,
  customer_id INT
);
```

Task: Add foreign key constraint on wu10_orders.customer_id referencing wu10_customers.customer_id.

Solution:
```sql
-- Add foreign key constraint
ALTER TABLE wu10_orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id) REFERENCES wu10_customers(customer_id);

-- Verify constraint exists
SHOW CREATE TABLE wu10_orders;
```

---

## 4) Modify Column Data Type — 6 min
Scenario: Increase email field size.

Sample data:
```sql
DROP TABLE IF EXISTS wu10_users;
CREATE TABLE wu10_users (
  user_id INT PRIMARY KEY,
  email VARCHAR(50)
);
INSERT INTO wu10_users VALUES (1, 'user@example.com');
```

Task: Change email column to VARCHAR(150).

Solution:
```sql
-- Modify column type
ALTER TABLE wu10_users
MODIFY COLUMN email VARCHAR(150);

-- Verify
DESCRIBE wu10_users;
SELECT * FROM wu10_users;  -- Data preserved
```

---

## 5) Add UNIQUE Constraint — 7 min
Scenario: Ensure email addresses are unique.

Sample data:
```sql
DROP TABLE IF EXISTS wu10_members;
CREATE TABLE wu10_members (
  member_id INT PRIMARY KEY,
  email VARCHAR(100),
  username VARCHAR(50)
);
```

Task: Add UNIQUE constraint on email column.

Solution:
```sql
-- Add unique constraint
ALTER TABLE wu10_members
ADD CONSTRAINT uk_email UNIQUE (email);

-- Test it
INSERT INTO wu10_members VALUES (1, 'alice@example.com', 'alice');
-- This will fail:
-- INSERT INTO wu10_members VALUES (2, 'alice@example.com', 'bob');

-- Verify constraint
SHOW CREATE TABLE wu10_members;
```

---

## 6) Create Table with Multiple Constraints — 8 min
Scenario: Create employee table with various constraints.

Task: Create table with: emp_id (PK, auto-increment), email (unique, not null), salary (must be positive), hire_date (default today).

Solution:
```sql
DROP TABLE IF EXISTS wu10_employees;
CREATE TABLE wu10_employees (
  emp_id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(100) UNIQUE NOT NULL,
  salary DECIMAL(10,2) CHECK (salary > 0),
  hire_date DATE DEFAULT (CURDATE())
);

-- Test constraints
INSERT INTO wu10_employees (email, salary) VALUES ('emp1@company.com', 50000);
-- This inserts with today's date automatically

-- This will fail (negative salary):
-- INSERT INTO wu10_employees (email, salary) VALUES ('emp2@company.com', -1000);

SELECT * FROM wu10_employees;
```

---

## 7) Drop and Recreate Table — 6 min
Scenario: Completely replace a table structure.

Sample data:
```sql
DROP TABLE IF EXISTS wu10_old_table;
CREATE TABLE wu10_old_table (
  id INT,
  data VARCHAR(50)
);
INSERT INTO wu10_old_table VALUES (1, 'old data');
```

Task: Drop table and recreate with better structure (id as PRIMARY KEY, created_at timestamp).

Solution:
```sql
-- Drop old table
DROP TABLE wu10_old_table;

-- Create new structure
CREATE TABLE wu10_old_table (
  id INT PRIMARY KEY,
  data VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Verify
DESCRIBE wu10_old_table;
```

---

## 8) Composite Primary Key — 7 min
Scenario: Create enrollment table with composite key.

Task: Create course_enrollment table where combination of student_id and course_id is unique.

Solution:
```sql
DROP TABLE IF EXISTS wu10_course_enrollment;
CREATE TABLE wu10_course_enrollment (
  student_id INT,
  course_id INT,
  enrollment_date DATE,
  PRIMARY KEY (student_id, course_id)
);

-- Test: same student can enroll in multiple courses
INSERT INTO wu10_course_enrollment VALUES (1, 101, '2025-01-15');
INSERT INTO wu10_course_enrollment VALUES (1, 102, '2025-01-16');

-- This will fail (duplicate composite key):
-- INSERT INTO wu10_course_enrollment VALUES (1, 101, '2025-02-01');

SELECT * FROM wu10_course_enrollment;
```

---

**Key Takeaways:**
- Always use PRIMARY KEY for unique identifiers
- Use FOREIGN KEY to maintain referential integrity
- Add UNIQUE constraints for naturally unique data (emails, usernames)
- Use CHECK constraints for business rules (MySQL 8.0.16+)
- DEFAULT values reduce INSERT complexity
- MODIFY changes column definition, CHANGE renames and modifies
- Test constraints by trying to violate them

