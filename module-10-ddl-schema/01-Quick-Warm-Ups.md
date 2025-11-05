# Quick Warm-Ups — DDL & Schema Design (5–10 min each)

Each exercise includes setup, task, expected output, and solution. Run each in its own session.

## 📋 Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Create tables with appropriate data types
- Modify existing table structures with ALTER
- Add and manage constraints (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK)
- Understand referential integrity
- Drop tables and constraints safely

### Key DDL Concepts for Beginners
**DDL = Data Definition Language:**
- `CREATE`: Create new database objects (tables, indexes)
- `ALTER`: Modify existing structures
- `DROP`: Delete database objects
- These operations change the STRUCTURE, not the data

**Essential Constraints:**
- `PRIMARY KEY`: Unique identifier, not null, one per table
- `FOREIGN KEY`: Links to another table's primary key (enforces relationships)
- `UNIQUE`: No duplicate values allowed
- `NOT NULL`: Must have a value
- `CHECK`: Validates data (e.g., price > 0)
- `DEFAULT`: Provides default value if none specified

**Data Type Guidelines:**
- `INT`: Whole numbers (user IDs, counts)
- `VARCHAR(n)`: Variable-length text (names, emails)
- `DECIMAL(p,s)`: Exact numbers (prices: DECIMAL(10,2))
- `DATE/DATETIME`: Date and time values
- `TEXT`: Long text content
- `BOOLEAN/TINYINT(1)`: True/false flags

### Execution Tips
1. **Plan before creating**: Sketch table relationships on paper
2. **Create in order**: Parent tables before child tables (FK dependencies)
3. **Use DESCRIBE**: Verify table structure after creation
4. **Test constraints**: Try inserting invalid data to verify constraints work
5. **DROP safely**: Use IF EXISTS to avoid errors

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
**Scenario:** Link orders to customers with foreign key to enforce referential integrity.

**Beginner Context:** 
A **foreign key (FK)** creates a relationship between two tables. It ensures that the value in one table (child) must exist in another table (parent). This prevents "orphaned" records - like having an order that references a customer who doesn't exist!

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

**Task:** Add foreign key constraint on `wu10_orders.customer_id` referencing `wu10_customers.customer_id`.

**What This Does:**
- Prevents inserting an order with a `customer_id` that doesn't exist in the customers table
- Prevents deleting a customer who has orders (or you can configure CASCADE behavior)
- Maintains data integrity automatically

Solution:
```sql
-- Add foreign key constraint using ALTER TABLE
-- Syntax: FOREIGN KEY (column_in_this_table) REFERENCES other_table(column_in_other_table)
ALTER TABLE wu10_orders
ADD CONSTRAINT fk_customer                      -- Constraint name (for later reference)
FOREIGN KEY (customer_id)                       -- Column in wu10_orders
REFERENCES wu10_customers(customer_id);         -- Column in wu10_customers

-- Verify constraint exists
SHOW CREATE TABLE wu10_orders;

-- Test the constraint
INSERT INTO wu10_customers VALUES (1, 'Alice Smith');

-- This works (customer 1 exists):
INSERT INTO wu10_orders VALUES (100, '2025-11-06', 1);

-- This fails (customer 999 doesn't exist):
-- INSERT INTO wu10_orders VALUES (101, '2025-11-06', 999);
-- Error: Cannot add or update a child row: a foreign key constraint fails
```

**Key Points:**
- Foreign key column and referenced column must have **exactly the same data type**
- Referenced column must be a PRIMARY KEY or UNIQUE
- Named constraints (`fk_customer`) make it easier to drop them later: `ALTER TABLE wu10_orders DROP FOREIGN KEY fk_customer;`

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
**Scenario:** Create employee table with various constraints to enforce data quality.

**Beginner Context:**
Constraints are rules that protect your data. They prevent invalid data from entering the database. It's much better to enforce these rules at the database level than relying on application code alone!

**Task:** Create table with: emp_id (PK, auto-increment), email (unique, not null), salary (must be positive), hire_date (default today).

**What Each Constraint Does:**
- **PRIMARY KEY + AUTO_INCREMENT**: Automatically generates unique IDs (1, 2, 3...)
- **UNIQUE**: No two employees can have the same email address
- **NOT NULL**: Email is required - can't be left blank
- **CHECK**: Salary must be greater than 0 (prevents negative salaries)
- **DEFAULT**: If hire_date not provided, uses today's date automatically

Solution:
```sql
DROP TABLE IF EXISTS wu10_employees;

-- Create table with multiple constraints
CREATE TABLE wu10_employees (
  emp_id INT AUTO_INCREMENT PRIMARY KEY,        -- Auto-generates 1, 2, 3...
  email VARCHAR(100) UNIQUE NOT NULL,           -- Must be unique and required
  salary DECIMAL(10,2) CHECK (salary > 0),      -- Must be positive (MySQL 8.0.16+)
  hire_date DATE DEFAULT (CURDATE())            -- Defaults to today if not specified
);

-- Test constraints
-- Good insert: all constraints satisfied
INSERT INTO wu10_employees (email, salary) 
VALUES ('emp1@company.com', 50000);
-- Note: hire_date automatically set to today, emp_id automatically set to 1

-- Try to insert duplicate email (will fail due to UNIQUE):
-- INSERT INTO wu10_employees (email, salary) VALUES ('emp1@company.com', 60000);
-- Error: Duplicate entry 'emp1@company.com' for key 'email'

-- Try to insert negative salary (will fail due to CHECK):
-- INSERT INTO wu10_employees (email, salary) VALUES ('emp2@company.com', -1000);
-- Error: Check constraint 'wu10_employees_chk_1' is violated

-- Try to insert without email (will fail due to NOT NULL):
-- INSERT INTO wu10_employees (salary) VALUES (45000);
-- Error: Field 'email' doesn't have a default value

-- View the data
SELECT * FROM wu10_employees;

-- See the table structure
DESCRIBE wu10_employees;
```

**Important Notes:**
- **CHECK constraints** require MySQL 8.0.16+. If using older MySQL, the constraint will be ignored (no error, but no validation)
- **DEFAULT (CURDATE())** requires MySQL 8.0.13+. For older versions, use just `DEFAULT CURRENT_DATE` or handle in application
- Constraints prevent bad data BEFORE it enters the database - much safer than checking in code!

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
**Scenario:** Create enrollment table with composite primary key.

**Beginner Context:**
A **composite primary key** uses multiple columns together as the unique identifier. This is common in junction tables (many-to-many relationships) where the combination of two IDs must be unique, but each ID alone can repeat.

**Example:** A student can enroll in many courses, and a course can have many students. But the same student can't enroll in the same course twice - that combination must be unique!

**Task:** Create course_enrollment table where the combination of `student_id` and `course_id` is unique.

**What This Does:**
- `(student_id=1, course_id=101)` - allowed
- `(student_id=1, course_id=102)` - allowed (same student, different course)
- `(student_id=2, course_id=101)` - allowed (different student, same course)
- `(student_id=1, course_id=101)` again - **NOT allowed** (duplicate combination)

Solution:
```sql
DROP TABLE IF EXISTS wu10_course_enrollment;

-- Create table with composite primary key
CREATE TABLE wu10_course_enrollment (
  student_id INT,                               -- Part of composite PK
  course_id INT,                                -- Part of composite PK
  enrollment_date DATE,
  grade VARCHAR(2),
  PRIMARY KEY (student_id, course_id)          -- Both columns together form PK
);

-- Test: Same student can enroll in multiple courses
INSERT INTO wu10_course_enrollment VALUES (1, 101, '2025-01-15', NULL);
INSERT INTO wu10_course_enrollment VALUES (1, 102, '2025-01-16', NULL);

-- Same course can have multiple students
INSERT INTO wu10_course_enrollment VALUES (2, 101, '2025-01-17', NULL);

-- View all enrollments
SELECT * FROM wu10_course_enrollment;

-- This will fail (duplicate composite key - student 1 already enrolled in course 101):
-- INSERT INTO wu10_course_enrollment VALUES (1, 101, '2025-02-01', NULL);
-- Error: Duplicate entry '1-101' for key 'PRIMARY'

-- Query: Which courses is student 1 taking?
SELECT course_id, enrollment_date FROM wu10_course_enrollment WHERE student_id = 1;

-- Query: Who is enrolled in course 101?
SELECT student_id, enrollment_date FROM wu10_course_enrollment WHERE course_id = 101;
```

**Key Differences:**
```sql
-- Single column PK: Only student_id must be unique
PRIMARY KEY (student_id)              -- Each student can appear only once total

-- Composite PK: Combination must be unique
PRIMARY KEY (student_id, course_id)   -- Each student can appear multiple times (different courses)
```

**When to Use Composite PKs:**
- Junction tables (many-to-many relationships)
- Tables representing relationships between entities
- When no single column uniquely identifies a row

---

**Key Takeaways:**
- Always use **PRIMARY KEY** for unique identifiers (single or composite)
- Use **FOREIGN KEY** to maintain referential integrity between tables
- Add **UNIQUE** constraints for naturally unique data (emails, usernames, SKUs)
- Use **CHECK** constraints for business rules like positive numbers (MySQL 8.0.16+)
- **DEFAULT** values reduce INSERT complexity and ensure consistency
- **MODIFY** changes column definition; **CHANGE** renames and modifies simultaneously
- **Test constraints** by trying to violate them - helps verify they work correctly!
- **Composite primary keys** are perfect for junction tables in many-to-many relationships

**MySQL Version Notes:**
- CHECK constraints require MySQL 8.0.16 or higher
- DEFAULT with functions like CURDATE() requires MySQL 8.0.13+
- If using older versions, constraints may be ignored or cause syntax errors

