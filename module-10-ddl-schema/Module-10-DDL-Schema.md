# Module 10 · DDL & Schema Design

## What is DDL?

**DDL (Data Definition Language)** defines the structure of your database - the tables, columns, data types, and relationships. Think of it as the blueprint for your database.

Unlike DML (Data Manipulation Language) which works with the data itself (INSERT, UPDATE, DELETE, SELECT), DDL creates and modifies the containers that hold your data.

### Core DDL Commands:
- **CREATE**: Make new database objects (tables, indexes, views)
- **ALTER**: Modify existing structures (add/remove/change columns)
- **DROP**: Delete database objects permanently
- **TRUNCATE**: Remove all data from a table (keeps structure)

## Key Operations:

### Creating Tables with Constraints
```sql
-- Create a table with various constraints
-- Note: This example assumes departments table already exists
CREATE TABLE employees (
  emp_id INT PRIMARY KEY AUTO_INCREMENT,        -- Primary key, auto-generates values
  email VARCHAR(100) UNIQUE NOT NULL,           -- Must be unique and cannot be NULL
  dept_id INT,                                  -- Foreign key column
  salary DECIMAL(10,2) CHECK (salary > 0),      -- Must be positive (MySQL 8.0.16+)
  hired_date DATE DEFAULT (CURDATE()),          -- Defaults to today's date
  FOREIGN KEY (dept_id) REFERENCES departments(dept_id)  -- Links to departments table
);
```

**Beginner Explanation:**
- **AUTO_INCREMENT**: MySQL automatically assigns 1, 2, 3... for each new row
- **PRIMARY KEY**: Uniquely identifies each row (no duplicates, no NULLs)
- **UNIQUE**: No two rows can have the same value (but NULL is allowed unless NOT NULL is also specified)
- **NOT NULL**: Column must have a value - cannot be empty
- **CHECK**: Validates data meets a condition (requires MySQL 8.0.16 or higher)
- **DEFAULT**: Provides a value if none is specified during INSERT
- **FOREIGN KEY**: Creates relationship to another table, ensures referential integrity

### Altering Tables
```sql
-- Add a new column
ALTER TABLE employees ADD COLUMN phone VARCHAR(20);

-- Change column definition (data type or constraints)
ALTER TABLE employees MODIFY COLUMN email VARCHAR(150);

-- Remove a column
ALTER TABLE employees DROP COLUMN phone;

-- Add a constraint to existing table
ALTER TABLE employees ADD CONSTRAINT chk_salary CHECK (salary >= 30000);

-- Add foreign key to existing table
ALTER TABLE employees 
ADD CONSTRAINT fk_dept 
FOREIGN KEY (dept_id) REFERENCES departments(dept_id);
```

**Beginner Explanation:**
- Use **ALTER TABLE** to change existing tables without losing data
- **ADD COLUMN**: Adds new column to table (existing rows get NULL or DEFAULT value)
- **MODIFY COLUMN**: Changes data type or constraints (be careful with data compatibility!)
- **DROP COLUMN**: Permanently removes column and all its data
- Always backup data before altering table structure in production!

### Dropping Tables
```sql
-- Drop table safely (no error if it doesn't exist)
DROP TABLE IF EXISTS temp_data;

-- Drop multiple tables (order matters with foreign keys!)
DROP TABLE IF EXISTS order_items;    -- Child table first
DROP TABLE IF EXISTS orders;         -- Parent table second
```

**Beginner Explanation:**
- **DROP TABLE** permanently deletes the table and ALL its data - be very careful!
- Use **IF EXISTS** to avoid errors if table doesn't exist
- Must drop child tables (with foreign keys) before parent tables (referenced by foreign keys)

## Best Practices:

### 1. Choose Appropriate Data Types
```sql
-- Good: Specific, efficient types
user_id INT                          -- Whole numbers
email VARCHAR(100)                   -- Variable text up to 100 chars
price DECIMAL(10,2)                  -- Exact decimal: 10 digits, 2 after decimal
birth_date DATE                      -- Date only (YYYY-MM-DD)
created_at TIMESTAMP                 -- Date and time with timezone awareness

-- Avoid: Generic or oversized types
user_id VARCHAR(255)                 -- Wasteful for numbers
price FLOAT                          -- Can have rounding errors (use DECIMAL for money!)
description VARCHAR(10000)           -- Use TEXT for large content
```

### 2. Always Define Primary Keys
Every table should have a primary key to uniquely identify each row.
```sql
-- Option 1: Auto-incrementing integer (most common)
CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50)
);

-- Option 2: Composite primary key (for junction tables)
CREATE TABLE course_enrollments (
  student_id INT,
  course_id INT,
  PRIMARY KEY (student_id, course_id)
);
```

### 3. Use Foreign Keys for Relationships
Foreign keys maintain referential integrity - prevent orphaned records.
```sql
CREATE TABLE orders (
  order_id INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE RESTRICT      -- Prevents deleting customer with orders
    ON UPDATE CASCADE       -- Updates order if customer_id changes
);
```

### 4. Use NOT NULL for Required Fields
```sql
CREATE TABLE products (
  product_id INT PRIMARY KEY AUTO_INCREMENT,
  product_name VARCHAR(200) NOT NULL,     -- Required field
  description TEXT,                       -- Optional field
  price DECIMAL(10,2) NOT NULL            -- Required field
);
```

### 5. Index Frequently Queried Columns
```sql
CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(100) NOT NULL,
  last_name VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_email (email),                -- Faster email lookups
  INDEX idx_lastname (last_name),         -- Faster name searches
  INDEX idx_created (created_at)          -- Faster date range queries
);
```

**Note**: Indexes speed up SELECT queries but slow down INSERT/UPDATE/DELETE. Index strategically!

### 6. Plan for Schema Changes (Migrations)
```sql
-- Good: Use ALTER to evolve schema
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Avoid in production: Dropping and recreating loses data!
-- DROP TABLE users;
-- CREATE TABLE users (...);
```

## Common Pitfalls to Avoid:

1. **Creating child tables before parent tables**: Always create referenced tables first
2. **Mismatched foreign key data types**: FK column must exactly match PK column type
3. **No primary key**: Every table should have a primary key
4. **VARCHAR too small**: Email should be at least VARCHAR(100), not VARCHAR(50)
5. **Using FLOAT/DOUBLE for money**: Always use DECIMAL for currency to avoid rounding errors
6. **Forgetting NOT NULL on required fields**: Allows incomplete/invalid data
7. **Over-indexing**: Too many indexes slow down writes significantly

## MySQL Version Compatibility Note:

- **CHECK constraints** require MySQL 8.0.16 or higher
- **DEFAULT with expressions** like `DEFAULT (CURDATE())` requires MySQL 8.0.13+
- If using older MySQL, remove CHECK constraints or use triggers instead
- **AUTO_INCREMENT** is MySQL-specific (PostgreSQL uses SERIAL, SQL Server uses IDENTITY)
